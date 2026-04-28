import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/event_provider.dart';
import '../../services/notification_setting_service.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('通知設定')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _Hint(),
          const SizedBox(height: 12),
          _Group(
            title: '通知タイミング',
            icon: Icons.notifications_active_rounded,
            children: [
              _SettingTile(
                icon: Icons.event_available_outlined,
                title: '予約開始前に通知',
                subtitle: '予約が始まる前にお知らせします',
                value: settings.notifyBeforeReservationStart,
                onChanged: notifier.setNotifyBeforeReservationStart,
              ),
              _Divider(),
              _SettingTile(
                icon: Icons.alarm_outlined,
                title: '予約締切前に通知',
                subtitle: '予約締切が近づいたらお知らせします',
                value: settings.notifyBeforeReservationEnd,
                onChanged: notifier.setNotifyBeforeReservationEnd,
              ),
              _Divider(),
              _SettingTile(
                icon: Icons.celebration_outlined,
                title: '開催開始前に通知',
                subtitle: 'イベント開催・発売前にお知らせします',
                value: settings.notifyBeforeEventStart,
                onChanged: notifier.setNotifyBeforeEventStart,
              ),
              _Divider(),
              _SettingTile(
                icon: Icons.today_outlined,
                title: '当日に通知',
                subtitle: '開催日・発売日当日にお知らせします',
                value: settings.notifyOnEventDay,
                onChanged: notifier.setNotifyOnEventDay,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            title: '締切何日前に通知するか',
            icon: Icons.schedule_rounded,
            children: [
              RadioGroup<DeadlineLeadTime>(
                groupValue: settings.deadlineLeadTime,
                onChanged: (next) {
                  if (next != null) notifier.setDeadlineLeadTime(next);
                },
                child: Column(
                  children: [
                    for (final v in DeadlineLeadTime.values)
                      _LeadTimeTile(
                        value: v,
                        selected: settings.deadlineLeadTime == v,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'プッシュ通知は次バージョンで対応',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'いまはここで設定値を保存できます。次回アップデートで実際の通知に反映されます。',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 0.6),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: value ? AppColors.primary : const Color(0xFF6B5C72),
                size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF231A2A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF8A7A93),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LeadTimeTile extends StatelessWidget {
  const _LeadTimeTile({required this.value, required this.selected});
  final DeadlineLeadTime value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: RadioListTile<DeadlineLeadTime>(
          value: value,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          title: Text(
            value.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppColors.primaryDark
                  : const Color(0xFF231A2A),
            ),
          ),
        ),
      ),
    );
  }
}
