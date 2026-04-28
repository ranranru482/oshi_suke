import 'package:flutter/foundation.dart';

/// 締切通知のリードタイム（日数）。
enum DeadlineLeadTime {
  oneDay,
  threeDays,
  sevenDays,
}

extension DeadlineLeadTimeX on DeadlineLeadTime {
  int get days {
    switch (this) {
      case DeadlineLeadTime.oneDay:
        return 1;
      case DeadlineLeadTime.threeDays:
        return 3;
      case DeadlineLeadTime.sevenDays:
        return 7;
    }
  }

  String get label => '$days日前';
}

/// 通知設定。MVPではローカル状態に保持するのみ。
/// TODO(future): Firebase Cloud Messaging + ローカル通知に接続する。
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.notifyBeforeReservationStart = true,
    this.notifyBeforeReservationEnd = true,
    this.notifyBeforeEventStart = true,
    this.notifyOnEventDay = true,
    this.deadlineLeadTime = DeadlineLeadTime.threeDays,
  });

  final bool notifyBeforeReservationStart;
  final bool notifyBeforeReservationEnd;
  final bool notifyBeforeEventStart;
  final bool notifyOnEventDay;
  final DeadlineLeadTime deadlineLeadTime;

  NotificationSettings copyWith({
    bool? notifyBeforeReservationStart,
    bool? notifyBeforeReservationEnd,
    bool? notifyBeforeEventStart,
    bool? notifyOnEventDay,
    DeadlineLeadTime? deadlineLeadTime,
  }) {
    return NotificationSettings(
      notifyBeforeReservationStart:
          notifyBeforeReservationStart ?? this.notifyBeforeReservationStart,
      notifyBeforeReservationEnd:
          notifyBeforeReservationEnd ?? this.notifyBeforeReservationEnd,
      notifyBeforeEventStart:
          notifyBeforeEventStart ?? this.notifyBeforeEventStart,
      notifyOnEventDay: notifyOnEventDay ?? this.notifyOnEventDay,
      deadlineLeadTime: deadlineLeadTime ?? this.deadlineLeadTime,
    );
  }
}
