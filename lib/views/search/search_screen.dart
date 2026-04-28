import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/event_status.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../detail/event_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  // フィルター
  final Set<OshiCategory> _categoryFilter = {};
  bool _filterActive = false;
  bool _filterReservationOpen = false;
  bool _filterDeadlineSoon = false;
  bool _filterOnline = false;
  bool _filterPhysical = false;
  String _regionFilter = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _activeAdvancedCount {
    var n = 0;
    if (_filterActive) n++;
    if (_filterReservationOpen) n++;
    if (_filterDeadlineSoon) n++;
    if (_filterOnline) n++;
    if (_filterPhysical) n++;
    if (_regionFilter.isNotEmpty) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final svc = ref.watch(eventStatusServiceProvider);

    final results = events.where((e) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final hay = [
          e.title,
          e.workTitle,
          e.shopName ?? '',
          e.location ?? '',
          e.category.label,
          ...e.tags,
        ].join(' ').toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (_categoryFilter.isNotEmpty &&
          !_categoryFilter.contains(e.category)) {
        return false;
      }
      final status = svc.statusOf(e);
      if (_filterActive && status != EventStatus.active) return false;
      if (_filterReservationOpen &&
          status != EventStatus.reservationOpen &&
          status != EventStatus.deadlineSoon) {
        return false;
      }
      if (_filterDeadlineSoon && status != EventStatus.deadlineSoon) {
        return false;
      }
      if (_filterOnline && !e.hasOnlineShop) return false;
      if (_filterPhysical && !e.hasPhysicalEvent) return false;
      if (_regionFilter.isNotEmpty) {
        final loc = (e.location ?? '').toLowerCase();
        if (!loc.contains(_regionFilter.toLowerCase())) return false;
      }
      return true;
    }).toList();

    final hasAnyFilter =
        _query.isNotEmpty || _categoryFilter.isNotEmpty || _activeAdvancedCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
        actions: [
          if (hasAnyFilter)
            TextButton(
              onPressed: () {
                setState(() {
                  _ctrl.clear();
                  _query = '';
                  _categoryFilter.clear();
                  _filterActive = false;
                  _filterReservationOpen = false;
                  _filterDeadlineSoon = false;
                  _filterOnline = false;
                  _filterPhysical = false;
                  _regionFilter = '';
                });
              },
              child: const Text(
                'クリア',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '作品・イベント・店舗・地域で検索',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.primary, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          _QuickStatusRow(
            active: _filterActive,
            reservationOpen: _filterReservationOpen,
            deadlineSoon: _filterDeadlineSoon,
            onChanged: (a, r, d) {
              setState(() {
                _filterActive = a;
                _filterReservationOpen = r;
                _filterDeadlineSoon = d;
              });
            },
          ),
          _CategoryRow(
            selected: _categoryFilter,
            onToggle: (c) {
              setState(() {
                if (_categoryFilter.contains(c)) {
                  _categoryFilter.remove(c);
                } else {
                  _categoryFilter.add(c);
                }
              });
            },
            onOpenAdvanced: _openAdvancedFilters,
            advancedCount: _activeAdvancedCount,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${results.length} 件',
                  style: const TextStyle(
                    color: Color(0xFF6B5C72),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                if (hasAnyFilter)
                  const Text(
                    '・絞り込み中',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    message: '条件に合うイベントが見つかりませんでした',
                    subtitle: 'キーワードを変えるか、フィルターを緩めて再検索してみましょう。',
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final e = results[i];
                      return EventCard(
                        event: e,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EventDetailScreen(eventId: e.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdvancedFilters() async {
    final regionCtrl = TextEditingController(text: _regionFilter);
    bool localOnline = _filterOnline;
    bool localPhysical = _filterPhysical;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (_, setSheet) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const Text(
                      '詳細フィルター',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SheetSwitch(
                      title: '通販ありのみ',
                      icon: Icons.shopping_cart_outlined,
                      value: localOnline,
                      onChanged: (v) => setSheet(() => localOnline = v),
                    ),
                    _SheetSwitch(
                      title: '現地イベントありのみ',
                      icon: Icons.place_outlined,
                      value: localPhysical,
                      onChanged: (v) => setSheet(() => localPhysical = v),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '地域 / 都市名',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B5C72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: regionCtrl,
                      decoration: const InputDecoration(
                        hintText: '例: 渋谷、大阪、名古屋',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheet(() {
                                localOnline = false;
                                localPhysical = false;
                                regionCtrl.clear();
                              });
                            },
                            child: const Text('リセット'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _filterOnline = localOnline;
                                _filterPhysical = localPhysical;
                                _regionFilter = regionCtrl.text.trim();
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('適用'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QuickStatusRow extends StatelessWidget {
  const _QuickStatusRow({
    required this.active,
    required this.reservationOpen,
    required this.deadlineSoon,
    required this.onChanged,
  });
  final bool active;
  final bool reservationOpen;
  final bool deadlineSoon;
  final void Function(bool active, bool reservation, bool deadline) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatusFilterChip(
            label: '締切間近',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.statusDeadline,
            selected: deadlineSoon,
            onTap: () => onChanged(active, reservationOpen, !deadlineSoon),
          ),
          const SizedBox(width: 8),
          _StatusFilterChip(
            label: '開催中',
            icon: Icons.celebration_rounded,
            color: AppColors.statusActive,
            selected: active,
            onTap: () => onChanged(!active, reservationOpen, deadlineSoon),
          ),
          const SizedBox(width: 8),
          _StatusFilterChip(
            label: '予約受付中',
            icon: Icons.event_available_rounded,
            color: AppColors.statusReservation,
            selected: reservationOpen,
            onTap: () => onChanged(active, !reservationOpen, deadlineSoon),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : AppColors.outline,
            width: selected ? 1.4 : 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.selected,
    required this.onToggle,
    required this.onOpenAdvanced,
    required this.advancedCount,
  });

  final Set<OshiCategory> selected;
  final ValueChanged<OshiCategory> onToggle;
  final VoidCallback onOpenAdvanced;
  final int advancedCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onOpenAdvanced,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: advancedCount > 0
                    ? AppColors.primary
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: advancedCount > 0
                        ? Colors.white
                        : const Color(0xFF6B5C72),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    advancedCount > 0 ? '詳細 $advancedCount' : '詳細',
                    style: TextStyle(
                      fontSize: 12,
                      color: advancedCount > 0
                          ? Colors.white
                          : const Color(0xFF6B5C72),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          for (final c in OshiCategory.values) ...[
            _CategoryFilterChip(
              category: c,
              selected: selected.contains(c),
              onTap: () => onToggle(c),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final OshiCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 1.4 : 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 14,
              color: selected ? Colors.white : AppColors.primaryDark,
            ),
            const SizedBox(width: 4),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSwitch extends StatelessWidget {
  const _SheetSwitch({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              child: Icon(
                icon,
                color: value
                    ? AppColors.primary
                    : const Color(0xFF6B5C72),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
