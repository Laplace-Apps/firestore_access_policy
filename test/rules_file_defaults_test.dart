import 'package:firestore_access_policy/firestore_access_policy.dart';
import 'package:test/test.dart';

void main() {
  test('RulesFileDefaults provides non-empty header strings', () {
    expect(RulesFileDefaults.firestoreHeaderComment, isNotEmpty);
    expect(RulesFileDefaults.storageHeaderComment, isNotEmpty);
  });
}
