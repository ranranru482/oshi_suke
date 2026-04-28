import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/remote_data_config.dart';
import '../models/work.dart';
import '../repositories/json_asset_work_repository.dart';
import '../repositories/remote_json_work_repository.dart';
import '../repositories/work_repository.dart';

/// 作品リポジトリの提供。
///
/// 取得チェーン:
///   1. [RemoteDataConfig.worksJsonUrl] が設定されていれば外部 URL から取得
///   2. 失敗 (タイムアウト / 非200 / JSON 不正) → assets/data/works.json
///   3. それも失敗 → mockWorks
///
/// 将来 Firestore / API に差し替える場合はここを書き換えるだけでよい。
final workRepositoryProvider = Provider<WorkRepository>((ref) {
  final asset = JsonAssetWorkRepository();
  final urlStr = RemoteDataConfig.worksJsonUrl;
  if (urlStr == null || urlStr.isEmpty) {
    return asset;
  }
  final repo = RemoteJsonWorkRepository(
    url: Uri.parse(urlStr),
    fallback: asset,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// 作品一覧の状態管理。
/// お気に入りON/OFF、通知ON/OFF、追加・削除をローカル状態で行う。
class WorksNotifier extends StateNotifier<List<Work>> {
  WorksNotifier(this._repository) : super(const []) {
    _load();
  }

  final WorkRepository _repository;

  Future<void> _load() async {
    state = await _repository.fetchAll();
  }

  void toggleFavorite(String workId) {
    state = [
      for (final w in state)
        if (w.id == workId) w.copyWith(isFavorite: !w.isFavorite) else w,
    ];
  }

  void toggleNotification(String workId) {
    state = [
      for (final w in state)
        if (w.id == workId)
          w.copyWith(notificationEnabled: !w.notificationEnabled)
        else
          w,
    ];
  }

  void addWork(Work work) {
    state = [...state, work];
  }

  void removeWork(String workId) {
    state = state.where((w) => w.id != workId).toList();
  }

  Work? findById(String workId) {
    for (final w in state) {
      if (w.id == workId) return w;
    }
    return null;
  }
}

final worksProvider =
    StateNotifierProvider<WorksNotifier, List<Work>>((ref) {
  return WorksNotifier(ref.watch(workRepositoryProvider));
});

/// お気に入り作品だけ。
final favoriteWorksProvider = Provider<List<Work>>((ref) {
  return ref.watch(worksProvider).where((w) => w.isFavorite).toList();
});
