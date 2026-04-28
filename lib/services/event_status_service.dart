import '../models/event_status.dart';
import '../models/oshi_event.dart';

/// 「締切間近」と判定する閾値（日数）。
const int kDeadlineSoonThresholdDays = 7;

/// 「近日開始」と判定する閾値（日数）。
const int kUpcomingThresholdDays = 30;

/// 日付からイベントの現在ステータスを自動判定する。
///
/// 優先順位:
///   1. 開催中 (active): startDate <= today <= endDate
///   2. 締切間近 (deadlineSoon): 予約締切が今日含めて threshold 日以内
///   3. 予約受付中 (reservationOpen): 予約開始 <= today <= 予約締切
///   4. 近日開始 (upcoming): 開催/発売予定が今日含めて upcoming 日以内
///   5. 予約受付前 (reservationBefore): 予約開始がまだ未来
///   6. 終了 (ended): 全期日が過去
class EventStatusService {
  const EventStatusService();

  EventStatus statusOf(OshiEvent e, {DateTime? now}) {
    final today = _truncate(now ?? DateTime.now());

    final start = _truncateOrNull(e.startDate);
    final end = _truncateOrNull(e.endDate);
    final resStart = _truncateOrNull(e.reservationStartDate);
    final resEnd = _truncateOrNull(e.reservationEndDate);
    final release = _truncateOrNull(e.releaseDate);

    // 開催中
    if (start != null && end != null) {
      if (!today.isBefore(start) && !today.isAfter(end)) {
        return EventStatus.active;
      }
    } else if (start != null && end == null) {
      if (today.isAtSameMomentAs(start)) return EventStatus.active;
    }

    // 予約期間判定
    if (resStart != null && resEnd != null) {
      if (!today.isBefore(resStart) && !today.isAfter(resEnd)) {
        final daysLeft = resEnd.difference(today).inDays;
        if (daysLeft <= kDeadlineSoonThresholdDays) {
          return EventStatus.deadlineSoon;
        }
        return EventStatus.reservationOpen;
      }
      if (today.isBefore(resStart)) {
        return EventStatus.reservationBefore;
      }
    } else if (resEnd != null && today.isBefore(resEnd) || today.isAtSameMomentAs(resEnd ?? today.add(const Duration(days: 1)))) {
      // resStart 未指定で resEnd だけある場合のフォールバック
      if (resEnd != null) {
        final daysLeft = resEnd.difference(today).inDays;
        if (daysLeft >= 0 && daysLeft <= kDeadlineSoonThresholdDays) {
          return EventStatus.deadlineSoon;
        }
        if (daysLeft >= 0) return EventStatus.reservationOpen;
      }
    } else if (resStart != null && today.isBefore(resStart)) {
      return EventStatus.reservationBefore;
    }

    // 近日開始 / 発売
    final upcomingAnchor = start ?? release;
    if (upcomingAnchor != null && upcomingAnchor.isAfter(today)) {
      final daysUntil = upcomingAnchor.difference(today).inDays;
      if (daysUntil <= kUpcomingThresholdDays) {
        return EventStatus.upcoming;
      }
      return EventStatus.reservationBefore;
    }

    // 全部過去 → 終了
    return EventStatus.ended;
  }

  /// 「締切間近」イベントを抽出。
  List<OshiEvent> deadlineSoon(List<OshiEvent> events, {DateTime? now}) {
    return events
        .where((e) => statusOf(e, now: now) == EventStatus.deadlineSoon)
        .toList();
  }

  /// 「開催中」イベントを抽出。
  List<OshiEvent> active(List<OshiEvent> events, {DateTime? now}) {
    return events
        .where((e) => statusOf(e, now: now) == EventStatus.active)
        .toList();
  }

  /// 「近日開始」イベントを抽出。
  List<OshiEvent> upcoming(List<OshiEvent> events, {DateTime? now}) {
    return events
        .where((e) => statusOf(e, now: now) == EventStatus.upcoming)
        .toList();
  }

  /// 「今日の新着」: createdAt が直近 X 日以内。
  List<OshiEvent> newlyAdded(
    List<OshiEvent> events, {
    DateTime? now,
    int withinDays = 7,
  }) {
    final today = _truncate(now ?? DateTime.now());
    final from = today.subtract(Duration(days: withinDays));
    return events.where((e) => !e.createdAt.isBefore(from)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 指定日に「関連する」イベント（開催期間内 / 予約期間内 / 発売日が一致）を返す。
  List<OshiEvent> eventsOn(
    List<OshiEvent> events,
    DateTime day,
  ) {
    final target = _truncate(day);
    return events.where((e) {
      final start = _truncateOrNull(e.startDate);
      final end = _truncateOrNull(e.endDate);
      final resStart = _truncateOrNull(e.reservationStartDate);
      final resEnd = _truncateOrNull(e.reservationEndDate);
      final release = _truncateOrNull(e.releaseDate);

      bool inRange(DateTime? s, DateTime? e2) {
        if (s == null || e2 == null) return false;
        return !target.isBefore(s) && !target.isAfter(e2);
      }

      if (inRange(start, end)) return true;
      if (inRange(resStart, resEnd)) return true;
      if (release != null && release.isAtSameMomentAs(target)) return true;
      if (start != null &&
          end == null &&
          start.isAtSameMomentAs(target)) {
        return true;
      }
      return false;
    }).toList();
  }

  DateTime _truncate(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime? _truncateOrNull(DateTime? d) => d == null ? null : _truncate(d);
}
