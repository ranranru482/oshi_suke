import '../models/oshi_event.dart';

/// イベント/商品リポジトリの抽象インターフェース。
///
/// 実装:
///   - [JsonAssetEventRepository]    : assets/data/events.json から読む（MVP既定）
///   - 将来: FirestoreEventRepository, ScrapingEventRepository, etc.
///
/// 抽象化することで、上位層(Provider/UI)はデータソースに依存しない。
abstract class EventRepository {
  Future<List<OshiEvent>> fetchAll();
}
