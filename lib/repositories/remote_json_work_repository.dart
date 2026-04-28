import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/remote_data_config.dart';
import '../models/work.dart';
import 'json_parsers.dart';
import 'work_repository.dart';

/// 外部 URL から works.json を取得する WorkRepository。
///
/// チェーン:
///   1. HTTP GET → 200 + パース成功なら返す
///   2. それ以外 (タイムアウト / 非200 / JSON不正 / 空) は [fallback.fetchAll] へ委譲
///
/// すべての結果は `[Remote/works] OK ...` 形式のログを残す
/// (取得元・件数・経過時間・URL がひと目で分かるようにするため)。
///
/// テストでは [client] にモックを差し込んで挙動を検証する。
class RemoteJsonWorkRepository implements WorkRepository {
  RemoteJsonWorkRepository({
    required this.url,
    required this.fallback,
    http.Client? client,
    this.timeout = RemoteDataConfig.networkTimeout,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  /// 取得先 URL。
  final Uri url;

  /// 取得失敗時に委譲する次段リポジトリ (通常は JsonAssetWorkRepository)。
  final WorkRepository fallback;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  static const _tag = '[Remote/works]';

  @override
  Future<List<Work>> fetchAll() async {
    final sw = Stopwatch()..start();
    try {
      final res = await _client
          .get(url, headers: const {
            'Accept': 'application/json',
            'User-Agent': RemoteDataConfig.userAgent,
          })
          .timeout(timeout);
      if (res.statusCode != 200) {
        throw _RemoteFetchException('HTTP ${res.statusCode}');
      }
      // bodyBytes → utf8 で安全に decode (Content-Type の charset 欠落対策)
      final raw = utf8.decode(res.bodyBytes);
      final works = parseWorksJson(raw);
      debugPrint(
          '$_tag OK   ${works.length}件 ${sw.elapsedMilliseconds}ms ← $url');
      return works;
    } catch (e) {
      debugPrint(
          '$_tag FAIL ${sw.elapsedMilliseconds}ms ← $url (reason: $e)');
      debugPrint('$_tag → fallback (asset/mock) へ委譲');
      return fallback.fetchAll();
    }
  }

  /// 自分で生成した http.Client を解放する。テスト等で外部から注入された場合は閉じない。
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class _RemoteFetchException implements Exception {
  _RemoteFetchException(this.message);
  final String message;
  @override
  String toString() => message;
}
