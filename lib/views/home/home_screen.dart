import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/event_status.dart';
import '../../models/oshi_event.dart';
import '../../providers/event_provider.dart';
import '../../providers/work_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../../widgets/featured_event_card.dart';
import '../detail/event_detail_screen.dart';
import '../settings/notification_settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newly = ref.watch(newlyAddedEventsProvider);
    final deadline = ref.watch(deadlineSoonEventsProvider);
    final active = ref.watch(activeEventsProvider);
    final upcoming = ref.watch(upcomingEventsProvider);
    final allEvents = ref.watch(eventsProvider);
    final favoriteCount = ref.watch(favoriteWorksProvider).length;

    final reservationOpen = allEvents
        .where((e) =>
            ref.read(eventStatusServiceProvider).statusOf(e) ==
            EventStatus.reservationOpen)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              favoriteCount: favoriteCount,
              onOpenSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _SummaryCard(
              deadlineCount: deadline.length,
              activeCount: active.length,
              reservationCount: reservationOpen.length,
            ),
          ),
          if (deadline.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: '締切間近',
                subtitle: '見逃したくない予約締切',
                icon: Icons.local_fire_department_rounded,
                accent: AppColors.statusDeadline,
              ),
            ),
            SliverToBoxAdapter(
              child: _FeaturedRail(events: deadline),
            ),
          ],
          if (active.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: '開催中',
                subtitle: '今行ける・今買える',
                icon: Icons.celebration_rounded,
                accent: AppColors.statusActive,
              ),
            ),
            ..._buildEventSliverList(context, active),
          ],
          if (upcoming.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: '近日開始',
                subtitle: 'これから始まる推し関連',
                icon: Icons.schedule_rounded,
                accent: AppColors.statusUpcoming,
              ),
            ),
            ..._buildEventSliverList(context, upcoming),
          ],
          if (newly.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: '今日の新着',
                subtitle: '直近で追加された情報',
                icon: Icons.fiber_new_rounded,
                accent: AppColors.primary,
              ),
            ),
            ..._buildEventSliverList(context, newly.take(4).toList()),
          ],
          const SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'おすすめ',
              subtitle: 'ピックアップ',
              icon: Icons.auto_awesome_rounded,
              accent: AppColors.tertiary,
            ),
          ),
          ..._buildEventSliverList(
              context, _pickRecommendation(allEvents)),
          if (deadline.isEmpty && active.isEmpty && upcoming.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.movie_filter_outlined,
                message: '今は表示できる情報がありません',
                subtitle: 'マイ作品から推しを登録すると、関連イベントがここに集まります。',
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<Widget> _buildEventSliverList(
      BuildContext context, List<OshiEvent> events) {
    if (events.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'まだ情報がありません',
              style: TextStyle(color: Color(0xFF8A7A93), fontSize: 12),
            ),
          ),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: events.length,
        itemBuilder: (_, i) {
          final e = events[i];
          return EventCard(
            event: e,
            onTap: () => _openDetail(context, e.id),
          );
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];
  }

  static void _openDetail(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(eventId: eventId),
      ),
    );
  }

  // TODO(future): ユーザー嗜好を学習して並び替え
  List<OshiEvent> _pickRecommendation(List<OshiEvent> all) {
    final sorted = [...all]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.favoriteCount,
    required this.onOpenSettings,
  });

  final int favoriteCount;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateText = DateFormat('yyyy.MM.dd (E)', 'ja_JP').format(today);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  const Text(
                    '推しスケ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onOpenSettings,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    tooltip: '通知設定',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '今日も推しの予定を\nチェックしよう。',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'お気に入り作品 $favoriteCount 件',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.deadlineCount,
    required this.activeCount,
    required this.reservationCount,
  });

  final int deadlineCount;
  final int activeCount;
  final int reservationCount;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _SummaryStat(
                color: AppColors.statusDeadline,
                icon: Icons.local_fire_department_rounded,
                count: deadlineCount,
                label: '締切間近',
              ),
              _Divider(),
              _SummaryStat(
                color: AppColors.statusActive,
                icon: Icons.celebration_rounded,
                count: activeCount,
                label: '開催中',
              ),
              _Divider(),
              _SummaryStat(
                color: AppColors.statusReservation,
                icon: Icons.event_available_rounded,
                count: reservationCount,
                label: '予約受付中',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.outline,
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.color,
    required this.icon,
    required this.count,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B5C72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1F33),
                  ),
                ),
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
        ],
      ),
    );
  }
}

class _FeaturedRail extends StatelessWidget {
  const _FeaturedRail({required this.events});
  final List<OshiEvent> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 244,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final e = events[i];
          return FeaturedEventCard(
            event: e,
            onTap: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(eventId: e.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
