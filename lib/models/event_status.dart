import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// イベント/商品のステータス。日付から自動判定する。
enum EventStatus {
  reservationBefore,
  reservationOpen,
  deadlineSoon,
  active,
  upcoming,
  ended,
}

extension EventStatusX on EventStatus {
  String get label {
    switch (this) {
      case EventStatus.reservationBefore:
        return '予約受付前';
      case EventStatus.reservationOpen:
        return '予約受付中';
      case EventStatus.deadlineSoon:
        return '締切間近';
      case EventStatus.active:
        return '開催中';
      case EventStatus.upcoming:
        return '近日開始';
      case EventStatus.ended:
        return '終了';
    }
  }

  /// カードバッジ等で使う色。
  Color get color {
    switch (this) {
      case EventStatus.deadlineSoon:
        return AppColors.statusDeadline;
      case EventStatus.reservationOpen:
        return AppColors.statusReservation;
      case EventStatus.active:
        return AppColors.statusActive;
      case EventStatus.upcoming:
        return AppColors.statusUpcoming;
      case EventStatus.reservationBefore:
        return AppColors.statusBefore;
      case EventStatus.ended:
        return AppColors.statusEnded;
    }
  }

  IconData get icon {
    switch (this) {
      case EventStatus.deadlineSoon:
        return Icons.local_fire_department_rounded;
      case EventStatus.reservationOpen:
        return Icons.event_available_rounded;
      case EventStatus.active:
        return Icons.celebration_rounded;
      case EventStatus.upcoming:
        return Icons.schedule_rounded;
      case EventStatus.reservationBefore:
        return Icons.lock_clock_rounded;
      case EventStatus.ended:
        return Icons.check_circle_outline_rounded;
    }
  }

  /// ホーム画面の優先度（小さいほど目立たせる）
  int get sortPriority {
    switch (this) {
      case EventStatus.deadlineSoon:
        return 0;
      case EventStatus.active:
        return 1;
      case EventStatus.reservationOpen:
        return 2;
      case EventStatus.upcoming:
        return 3;
      case EventStatus.reservationBefore:
        return 4;
      case EventStatus.ended:
        return 5;
    }
  }
}
