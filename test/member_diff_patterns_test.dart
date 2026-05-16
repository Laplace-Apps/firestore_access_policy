import 'package:firestore_access_policy/firestore_access_policy.dart';
import 'package:test/test.dart';

void main() {
  test('allowedMemberMapUpdate emits or-chain', () {
    final expr = MemberDiffPatterns.allowedMemberMapUpdate().emit();
    expect(expr, contains('listMembersDiff()'));
    expect(expr, contains('||'));
  });

  test('standard helpers include diff and createdBy guard', () {
    final helpers = MemberDiffPatterns.standardListMemberHelpers();
    expect(helpers, hasLength(2));
    expect(helpers.first.name, 'listMembersDiff');
  });
}
