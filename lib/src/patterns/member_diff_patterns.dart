import '../conditions/policy_condition.dart';
import '../rules/helper_function.dart';

/// Reusable Firestore helpers for `members` map invite / kick / self-leave diffs.
///
/// Matches common collaborative-document patterns (see NoteTogether `firestore.rules`).
abstract final class MemberDiffPatterns {
  /// `resource.data.members.diff(request.resource.data.members)`.
  static const membersDiffVariable = 'listMembersDiff';

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

  static HelperFunction listUpdateKeepsFieldHelper({
    String field = 'createdBy',
    String functionName = 'listUpdateKeepsField',
  }) =>
      HelperFunction(
        name: functionName,
        body: '''
return request.resource.data.$field == resource.data.$field;''',
      );

  static PolicyCondition membersUnchanged({String membersField = 'members'}) =>
      RulesExpression(
        'request.resource.data.$membersField == resource.data.$membersField',
      );

  static PolicyCondition selfLeave({
    String diffFunction = membersDiffVariable,
    String membersField = 'members',
  }) =>
      RulesExpression('''$diffFunction().addedKeys().size() == 0
          && $diffFunction().changedKeys().size() == 0
          && $diffFunction().removedKeys().size() == 1
          && request.auth.uid in $diffFunction().removedKeys()''');

  static PolicyCondition ownerRemovedOneMember({
    String ownerField = 'createdBy',
    String diffFunction = membersDiffVariable,
  }) =>
      RulesExpression('''request.auth.uid == resource.data.$ownerField
          && $diffFunction().addedKeys().size() == 0
          && $diffFunction().changedKeys().size() == 0
          && $diffFunction().removedKeys().size() == 1
          && !(resource.data.$ownerField in $diffFunction().removedKeys())''');

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
