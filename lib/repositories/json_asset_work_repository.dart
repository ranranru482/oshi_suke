import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/mock_works.dart';
import '../models/work.dart';
import 'json_parsers.dart';
import 'work_repository.dart';

/// `assets/data/works.json` から作品一覧を読み込むリポジトリ。
///
/// 失敗時 (asset 未登録 / JSON 不正 / フィールド欠落) は
/// メモリ上の [mockWorks] にフォールバックする。
///
/// ログタグ: `[Asset/works]`
class JsonAssetWorkRepository implements WorkRepository {
  JsonAssetWorkRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/works.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;

  static const _tag = '[Asset/works]';

  @override
  Future<List<Work>> fetchAll() async {
    final sw = Stopwatch()..start();
    try {
      final raw = await _bundle.loadString(assetPath);
      final works = parseWorksJson(raw);
      debugPrint(
          '$_tag OK   ${works.length}件 ${sw.elapsedMilliseconds}ms ← $assetPath');
      return works;
    } catch (e) {
      debugPrint(
          '$_tag FAIL ${sw.elapsedMilliseconds}ms ← $assetPath (reason: $e)');
      debugPrint('[Mock/works] → mockWorks ${mockWorks.length}件 にフォールバック');
      return List<Work>.from(mockWorks);
    }
  }
}
