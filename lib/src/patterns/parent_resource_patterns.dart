import '../conditions/policy_condition.dart';
import '../rules/helper_function.dart';

/// Access via a parent document (e.g. list `groupId` → `groups/{id}` membership).
abstract final class ParentResourcePatterns {
  /// Helper that loads a group doc and checks membership by id.
  static HelperFunction groupMemberByIdHelper({
    String functionName = 'isGroupMemberById',
    String groupsCollection = 'groups',
  }) =>
      HelperFunction(
        name: functionName,
        comment: 'True when request.auth.uid is in group members / memberIds.',
        parameters: ['groupId'],
        body: '''
let g = get(/databases/\$(database)/documents/$groupsCollection/\$(groupId));
return g != null && (
    (g.data.memberIds is list && g.data.memberIds.hasAny([request.auth.uid]))
    || (g.data.members is map && g.data.members[request.auth.uid] != null)
);''',
      );

  /// List access via direct members or parent [groupIdField] group membership.
  static PolicyCondition listMemberOrParentGroup({
    String membersField = 'members',
    String groupIdField = 'groupId',
    String groupMemberHelper = 'isGroupMemberById',
  }) =>
      Or([
        RulesExpression(
          '''request.auth.uid in resource.data.$membersField.keys()''',
        ),
        And([
          RulesExpression(
            '''resource.data.get('$groupIdField', '') is string
                && resource.data.get('$groupIdField', '').size() > 0''',
          ),
          CallHelper(groupMemberHelper, ['resource.data.get(\'$groupIdField\', \'\')']),
        ]),
      ]);
}
