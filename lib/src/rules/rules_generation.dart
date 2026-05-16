import '../storage/storage_rules_file.dart';
import '../storage/storage_rules_generator.dart';
import 'firestore_rules_generator.dart';
import 'rules_file.dart';
import 'rules_file_writer.dart';
import 'rules_output_target.dart';
import 'rules_write_result.dart';

/// Firestore + Storage generation and optional file output.
final class RulesGeneration {
  const RulesGeneration({
    this.firestoreGenerator = const FirestoreRulesGenerator(),
    this.storageGenerator = const StorageRulesGenerator(),
    this.writer = const RulesFileWriter(),
  });

  final FirestoreRulesGenerator firestoreGenerator;
  final StorageRulesGenerator storageGenerator;
  final RulesFileWriter writer;

  /// Returns `firestore.rules` source text.
  String generateFirestore(FirestoreRulesFile file) =>
      firestoreGenerator.generate(file);

  /// Returns `storage.rules` source text.
  String generateStorage(StorageRulesFile file) =>
      storageGenerator.generate(file);

  /// Generates and writes Firestore rules to [target] (default: fail if exists).
  Future<RulesWriteResult> writeFirestore(
    FirestoreRulesFile file,
    RulesOutputTarget target,
  ) async {
    final content = generateFirestore(file);
    return writer.writeString(content, target);
  }

  /// Generates and writes Storage rules to [target].
  Future<RulesWriteResult> writeStorage(
    StorageRulesFile file,
    RulesOutputTarget target,
  ) async {
    final content = generateStorage(file);
    return writer.writeString(content, target);
  }
}
