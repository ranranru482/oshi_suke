import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/mock_events.dart';
import '../models/oshi_event.dart';
import 'event_repository.dart';
import 'json_parsers.dart';

/// `assets/data/events.json` からイベント一覧を読み込むリポジトリ。
///
/// 失敗時 (asset 未登録 / JSON 不正 / フィールド欠落) は
/// メモリ上の [buildMockEvents] にフォールバックする。
///
/// ログタグ: `[Asset/events]`
class JsonAssetEventRepository implements EventRepository {
  JsonAssetEventRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/events.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;

  static const _tag = '[Asset/events]';

  @override
  Future<List<OshiEvent>> fetchAll() async {
    final sw = Stopwatch()..start();
    try {
      final raw = await _bundle.loadString(assetPath);
      final events = parseEventsJson(raw);
      debugPrint(
          '$_tag OK   ${events.length}件 ${sw.elapsedMilliseconds}ms ← $assetPath');
      return events;
    } catch (e) {
      debugPrint(
          '$_tag FAIL ${sw.elapsedMilliseconds}ms ← $assetPath (reason: $e)');
      final mocks = buildMockEvents();
      debugPrint('[Mock/events] → buildMockEvents ${mocks.length}件 にフォールバック');
      return mocks;
    }
  }
}
