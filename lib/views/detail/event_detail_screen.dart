import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/category.dart';
import '../../models/event_status.dart';
import '../../models/oshi_event.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../settings/notification_settings_screen.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    OshiEvent? event;
    for (final e in events) {
      if (e.id == eventId) {
        event = e;
        break;
      }
    }
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          message: 'イベントが見つかりませんでした',
        ),
      );
    }

    final ev = event;
    final status = ref.watch(eventStatusProvider(ev));
    final fmt = DateFormat('yyyy/MM/dd (E)', 'ja_JP');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'ブックマーク',
                icon: Icon(
                  ev.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  ref.read(eventsProvider.notifier).toggleBookmark(ev.id);
                },
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _Hero(event: ev, status: status),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.workTitle,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ev.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      color: Color(0xFF231A2A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(status: status),
                      CategoryChip(category: ev.category),
                      if (ev.hasOnlineShop)
                        const _PillChip(
                          icon: Icons.shopping_cart_outlined,
                          label: '通販あり',
                        ),
                      if (ev.hasPhysicalEvent)
                        const _PillChip(
                          icon: Icons.place_outlined,
                          label: '現地開催あり',
                        ),
                      if (ev.isOfficial)
                        const _PillChip(
                          icon: Icons.verified_rounded,
                          label: '公式情報',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (ev.description.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: '概要',
                icon: Icons.description_outlined,
                child: Text(
                  ev.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF3A2D40),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: _Section(
              title: '日程',
              icon: Icons.event_outlined,
              child: Column(
                children: [
                  _DateTile(
                    label: '開催期間',
                    value: _rangeText(ev.startDate, ev.endDate, fmt),
                    icon: Icons.event_outlined,
                  ),
                  _DateTile(
                    label: '予約開始日',
                    value: ev.reservationStartDate == null
                        ? null
                        : fmt.format(ev.reservationStartDate!),
                    icon: Icons.event_available_outlined,
                  ),
                  _DateTile(
                    label: '予約締切日',
                    value: ev.reservationEndDate == null
                        ? null
                        : fmt.format(ev.reservationEndDate!),
                    icon: Icons.alarm_outlined,
                    highlight: status == EventStatus.deadlineSoon,
                  ),
                  _DateTile(
                    label: '発売日',
                    value: ev.releaseDate == null
                        ? null
                        : fmt.format(ev.releaseDate!),
                    icon: Icons.local_shipping_outlined,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: '場所 / 運営',
              icon: Icons.store_mall_directory_outlined,
              child: Column(
                children: [
                  _InfoTile(
                    label: '場所',
                    value: ev.location,
                    icon: Icons.place_outlined,
                  ),
                  _InfoTile(
                    label: '店舗 / 運営',
                    value: ev.shopName,
                    icon: Icons.storefront_outlined,
                  ),
                  _InfoTile(
                    label: '価格',
                    value: ev.price == null
                        ? null
                        : '¥${NumberFormat.decimalPattern('ja').format(ev.price)}',
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
            ),
          ),
          if (ev.tags.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: 'タグ',
                icon: Icons.sell_outlined,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in ev.tags) _TagChip(label: t),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              _CircleActionButton(
                icon: ev.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: ev.isBookmarked ? AppColors.primary : null,
                tooltip: 'ブックマーク',
                onPressed: () {
                  ref.read(eventsProvider.notifier).toggleBookmark(ev.id);
                },
              ),
              const SizedBox(width: 8),
              _CircleActionButton(
                icon: Icons.notifications_outlined,
                tooltip: '通知',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: ev.officialUrl == null
                      ? null
                      : () => _openUrl(context, ev.officialUrl!),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('公式サイトを開く'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _rangeText(DateTime? s, DateTime? e, DateFormat fmt) {
    if (s == null && e == null) return null;
    if (s != null && e != null) return '${fmt.format(s)}\n〜 ${fmt.format(e)}';
    if (s != null) return fmt.format(s);
    return fmt.format(e!);
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.event, required this.status});
  final OshiEvent event;
  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = AppGradients.categoryPalette[
        event.id.hashCode.abs() % AppGradients.categoryPalette.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
          ),
        ),
        Center(
          child: Icon(
            event.category.icon,
            size: 110,
            color: AppColors.primaryDark.withValues(alpha: 0.45),
          ),
        ),
        // 下方向のグラデーションでテキストを読みやすく
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x66000000)],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: StatusBadge(status: status, solid: true),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline, width: 0.6),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String? value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null;
    final color = highlight
        ? AppColors.statusDeadline
        : (isEmpty ? const Color(0xFFB1A4B8) : const Color(0xFF231A2A));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.statusDeadline.withValues(alpha: 0.14)
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: highlight
                  ? AppColors.statusDeadline
                  : const Color(0xFF6B5C72),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B5C72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '未定',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: color,
                    fontWeight:
                        highlight ? FontWeight.w800 : FontWeight.w700,
                    height: 1.3,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, size: 16, color: const Color(0xFF6B5C72)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B5C72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '—',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: value == null
                        ? const Color(0xFFB1A4B8)
                        : const Color(0xFF231A2A),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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

class _PillChip extends StatelessWidget {
  const _PillChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF7A4F00)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF7A4F00),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$label',
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B5C72),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color ?? const Color(0xFF6B5C72),
            size: 22,
          ),
        ),
      ),
    );
  }
}
