import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/remote_data_config.dart';
import '../models/oshi_event.dart';
import 'event_repository.dart';
import 'json_parsers.dart';

/// 外部 URL から events.json を取得する EventRepository。
///
/// チェーン:
///   1. HTTP GET → 200 + パース成功なら返す
///   2. それ以外 (タイムアウト / 非200 / JSON不正 / 空) は [fallback.fetchAll] へ委譲
///
/// すべての結果は `[Remote/events] OK ...` 形式のログを残す。
class RemoteJsonEventRepository implements EventRepository {
  RemoteJsonEventRepository({
    required this.url,
    required this.fallback,
    http.Client? client,
    this.timeout = RemoteDataConfig.networkTimeout,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final Uri url;
  final EventRepository fallback;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  static const _tag = '[Remote/events]';

  @override
  Future<List<OshiEvent>> fetchAll() async {
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
      final raw = utf8.decode(res.bodyBytes);
      final events = parseEventsJson(raw);
      debugPrint(
          '$_tag OK   ${events.length}件 ${sw.elapsedMilliseconds}ms ← $url');
      return events;
    } catch (e) {
      debugPrint(
          '$_tag FAIL ${sw.elapsedMilliseconds}ms ← $url (reason: $e)');
      debugPrint('$_tag → fallback (asset/mock) へ委譲');
      return fallback.fetchAll();
    }
  }

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
