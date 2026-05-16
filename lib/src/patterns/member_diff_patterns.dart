import '../conditions/policy_condition.dart';
import '../rules/helper_function.dart';

/// Reusable Firestore helpers for `members` map invite / kick / self-leave diffs.
///
/// Matches common collaborative-document `members` map diff patterns.
abstract final class MemberDiffPatterns {
  /// Default helper name for the members map diff (`listMembersDiff`).
  static const membersDiffVariable = 'listMembersDiff';

  /// Helper that returns `resource.data.<membersField>.diff(...)`.
  static HelperFunction listMembersDiffHelper({
    String functionName = membersDiffVariable,
    String membersField = 'members',
  }) =>
      HelperFunction(
        name: functionName,
        comment: 'Diff on $membersField map between request and resource.',
        body: '''
return resource.data.$membersField.diff(request.resource.data.$membersField);''',
      );

  /// Helper ensuring [field] is unchanged on update.
  static HelperFunction listUpdateKeepsFieldHelper({
    String field = 'createdBy',
    String functionName = 'listUpdateKeepsField',
  }) =>
      HelperFunction(
        name: functionName,
        body: '''
return request.resource.data.$field == resource.data.$field;''',
      );

  /// Condition: [membersField] map is unchanged.
  static PolicyCondition membersUnchanged({String membersField = 'members'}) =>
      RulesExpression(
        'request.resource.data.$membersField == resource.data.$membersField',
      );

  /// Condition: caller removes only themselves from [membersField].
  static PolicyCondition selfLeave({
    String diffFunction = membersDiffVariable,
    String membersField = 'members',
  }) =>
      RulesExpression('''$diffFunction().addedKeys().size() == 0
          && $diffFunction().changedKeys().size() == 0
          && $diffFunction().removedKeys().size() == 1
          && request.auth.uid in $diffFunction().removedKeys()''');

  /// Condition: owner removes exactly one member (not themselves).
  static PolicyCondition ownerRemovedOneMember({
    String ownerField = 'createdBy',
    String diffFunction = membersDiffVariable,
  }) =>
      RulesExpression('''request.auth.uid == resource.data.$ownerField
          && $diffFunction().addedKeys().size() == 0
          && $diffFunction().changedKeys().size() == 0
          && $diffFunction().removedKeys().size() == 1
          && !(resource.data.$ownerField in $diffFunction().removedKeys())''');

  /// Condition: member adds one or more keys without removals.
  static PolicyCondition memberInvite({
    String diffFunction = membersDiffVariable,
    String membersField = 'members',
  }) =>
      RulesExpression('''request.auth.uid in resource.data.$membersField
          && $diffFunction().removedKeys().size() == 0
          && $diffFunction().changedKeys().size() == 0
          && $diffFunction().addedKeys().size() >= 1''');

  /// Typical list `allow update` member-change guard.
  static PolicyCondition allowedMemberMapUpdate({
    String membersField = 'members',
    String ownerField = 'createdBy',
    String diffFunction = membersDiffVariable,
    String keepsFieldFunction = 'listUpdateKeepsField',
  }) =>
      Or([
        membersUnchanged(membersField: membersField),
        selfLeave(diffFunction: diffFunction, membersField: membersField),
        ownerRemovedOneMember(
          ownerField: ownerField,
          diffFunction: diffFunction,
        ),
        memberInvite(diffFunction: diffFunction, membersField: membersField),
      ]);

  /// Helpers to register on [FirestoreRulesFile.helpers] for list update rules.
  static List<HelperFunction> standardListMemberHelpers({
    String membersField = 'members',
    String ownerField = 'createdBy',
  }) =>
      [
        listMembersDiffHelper(membersField: membersField),
        listUpdateKeepsFieldHelper(field: ownerField),
      ];
}
