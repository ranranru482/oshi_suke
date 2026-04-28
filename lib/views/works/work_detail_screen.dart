import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/oshi_event.dart';
import '../../providers/event_provider.dart';
import '../../providers/work_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../detail/event_detail_screen.dart';

enum _SortMode {
  deadlineSoonest,
  startSoonest,
  newest,
}

extension _SortModeX on _SortMode {
  String get label {
    switch (this) {
      case _SortMode.deadlineSoonest:
        return '締切が近い順';
      case _SortMode.startSoonest:
        return '開始日が近い順';
      case _SortMode.newest:
        return '新着順';
    }
  }
}

class WorkDetailScreen extends ConsumerStatefulWidget {
  const WorkDetailScreen({super.key, required this.workId});

  final String workId;

  @override
  ConsumerState<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends ConsumerState<WorkDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = <_WorkTab>[
    _WorkTab(label: 'すべて', categories: null),
    _WorkTab(label: 'グッズ', categories: [
      OshiCategory.goods,
      OshiCategory.preorder,
      OshiCategory.madeToOrder,
      OshiCategory.lottery,
    ]),
    _WorkTab(label: 'カフェ', categories: [
      OshiCategory.cafe,
      OshiCategory.popupStore,
    ]),
    _WorkTab(label: 'イベント', categories: [
      OshiCategory.exhibition,
      OshiCategory.live,
      OshiCategory.stage,
      OshiCategory.campaign,
    ]),
    _WorkTab(label: '予約販売', categories: [
      OshiCategory.preorder,
      OshiCategory.madeToOrder,
    ]),
    _WorkTab(label: '配信/発売', categories: [
      OshiCategory.streaming,
      OshiCategory.bluRay,
    ]),
  ];

  late final TabController _tabController =
      TabController(length: _tabs.length, vsync: this);

  _SortMode _sort = _SortMode.deadlineSoonest;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final works = ref.watch(worksProvider);
    final work = works.where((w) => w.id == widget.workId).firstOrNull;
    if (work == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          message: '作品が見つかりませんでした',
        ),
      );
    }

    final allEvents = ref
        .watch(eventsProvider)
        .where((e) => e.workId == widget.workId)
        .toList();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: _WorkHero(
                  workTitle: work.title,
                  workGenre: work.genre,
                  eventCount: allEvents.length,
                  isFavorite: work.isFavorite,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'お気に入り',
                  icon: Icon(
                    work.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => ref
                      .read(worksProvider.notifier)
                      .toggleFavorite(work.id),
                ),
                PopupMenuButton<_SortMode>(
                  tooltip: '並び替え',
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => [
                    for (final m in _SortMode.values)
                      PopupMenuItem(
                        value: m,
                        child: Row(
                          children: [
                            Icon(
                              _sort == m
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(m.label),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppColors.background,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: const Color(0xFF8A7A93),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [for (final t in _tabs) Tab(text: t.label)],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              for (final t in _tabs)
                _buildList(_filter(allEvents, t.categories)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<OshiEvent> events) {
    final sorted = [...events];
    switch (_sort) {
      case _SortMode.deadlineSoonest:
        sorted.sort((a, b) {
          final ad = a.reservationEndDate ?? a.endDate ?? a.releaseDate;
          final bd = b.reservationEndDate ?? b.endDate ?? b.releaseDate;
          return _compareNullable(ad, bd);
        });
        break;
      case _SortMode.startSoonest:
        sorted.sort((a, b) {
          final ad = a.startDate ?? a.releaseDate;
          final bd = b.startDate ?? b.releaseDate;
          return _compareNullable(ad, bd);
        });
        break;
      case _SortMode.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    if (sorted.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        message: 'このカテゴリの情報はまだありません',
        subtitle: '別のタブを覗いてみるか、新しい情報が追加されるのをお待ちください。',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final e = sorted[i];
        return EventCard(
          event: e,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(eventId: e.id),
              ),
            );
          },
        );
      },
    );
  }

  List<OshiEvent> _filter(List<OshiEvent> events, List<OshiCategory>? cats) {
    if (cats == null) return events;
    return events.where((e) => cats.contains(e.category)).toList();
  }

  int _compareNullable(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}

class _WorkHero extends StatelessWidget {
  const _WorkHero({
    required this.workTitle,
    required this.workGenre,
    required this.eventCount,
    required this.isFavorite,
  });

  final String workTitle;
  final String workGenre;
  final int eventCount;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  workGenre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                workTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  shadows: [
                    Shadow(color: Color(0x33000000), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _HeroStat(
                    icon: Icons.event_outlined,
                    text: '関連 $eventCount 件',
                  ),
                  const SizedBox(width: 8),
                  _HeroStat(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    text: isFavorite ? 'お気に入り中' : '未登録',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkTab {
  const _WorkTab({required this.label, required this.categories});
  final String label;
  final List<OshiCategory>? categories;
}
