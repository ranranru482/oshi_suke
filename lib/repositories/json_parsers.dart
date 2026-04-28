import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/oshi_event.dart';
import '../models/work.dart';

/// JSON 文字列を [Work] のリストにパース。
///
/// - ルートが List でない / 1件もパースできない場合は [FormatException] を投げる。
/// - 個々の Map に欠落フィールドがある場合は [Work.fromJson] 内で `?? デフォルト`が効くため、
///   ここではアイテム単位の try/catch は不要。
List<Work> parseWorksJson(String raw) {
  final decoded = json.decode(raw);
  if (decoded is! List) {
    throw FormatException(
        'works JSON のルートは List である必要があります (got ${decoded.runtimeType})');
  }
  final works = <Work>[];
  for (final item in decoded) {
    if (item is! Map<String, dynamic>) continue;
    works.add(Work.fromJson(item));
  }
  if (works.isEmpty) {
    throw const FormatException('works JSON から1件もパースできませんでした');
  }
  return works;
}

/// JSON 文字列を [OshiEvent] のリストにパース。
///
/// - ルートが List でない / 1件もパースできない場合は [FormatException] を投げる。
/// - 個別の要素のパースが失敗してもその1件をスキップして処理を続行する
///   (公開後の JSON 1行不正でアプリ全体が落ちることを防ぐため)。
List<OshiEvent> parseEventsJson(String raw) {
  final decoded = json.decode(raw);
  if (decoded is! List) {
    throw FormatException(
        'events JSON のルートは List である必要があります (got ${decoded.runtimeType})');
  }
  final events = <OshiEvent>[];
  for (final item in decoded) {
    if (item is! Map<String, dynamic>) continue;
    try {
      events.add(OshiEvent.fromJson(item));
    } catch (e) {
      debugPrint(
          '[parseEventsJson] 1件のパースに失敗しスキップ: id=${item['id']}: $e');
    }
  }
  if (events.isEmpty) {
    throw const FormatException('events JSON から1件もパースできませんでした');
  }
  return events;
}
