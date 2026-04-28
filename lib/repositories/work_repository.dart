import '../models/work.dart';

/// 作品リポジトリの抽象インターフェース。
///
/// 実装:
///   - [JsonAssetWorkRepository]    : assets/data/works.json から読む（MVP既定）
///   - 将来: FirestoreWorkRepository, ApiWorkRepository, etc.
///
/// 抽象化することで、上位層(Provider/UI)はデータソースに依存しない。
abstract class WorkRepository {
  Future<List<Work>> fetchAll();
}
