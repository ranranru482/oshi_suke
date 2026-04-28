import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/oshi_event.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../detail/event_detail_screen.dart';

enum _BookmarkSort {
  deadlineSoonest,
  startSoonest,
  registered,
}

extension _BookmarkSortX on _BookmarkSort {
  String get label {
    switch (this) {
      case _BookmarkSort.deadlineSoonest:
        return '締切が近い順';
      case _BookmarkSort.startSoonest:
        return '開始日が近い順';
      case _BookmarkSort.registered:
        return '登録順';
    }
  }

  IconData get icon {
    switch (this) {
      case _BookmarkSort.deadlineSoonest:
        return Icons.local_fire_department_rounded;
      case _BookmarkSort.startSoonest:
        return Icons.schedule_rounded;
      case _BookmarkSort.registered:
        return Icons.bookmark_added_rounded;
    }
  }
}

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  _BookmarkSort _sort = _BookmarkSort.deadlineSoonest;

  @override
  Widget build(BuildContext context) {
    final bookmarks = [...ref.watch(bookmarkedEventsProvider)];
    _applySort(bookmarks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ブックマーク'),
      ),
      body: bookmarks.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_add_rounded,
              message: 'ブックマークはまだありません',
              subtitle: '気になるイベントや商品の右上にあるブックマークボタンを\nタップすると、ここに集まります。',
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      _SummaryPill(count: bookmarks.length),
                      const Spacer(),
                      _SortButton(
                        current: _sort,
                        onSelected: (v) => setState(() => _sort = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: bookmarks.length,
                    itemBuilder: (_, i) {
                      final e = bookmarks[i];
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

  void _applySort(List<OshiEvent> list) {
    switch (_sort) {
      case _BookmarkSort.deadlineSoonest:
        list.sort((a, b) {
          final ad = a.reservationEndDate ?? a.endDate ?? a.releaseDate;
          final bd = b.reservationEndDate ?? b.endDate ?? b.releaseDate;
          return _cmp(ad, bd);
        });
        break;
      case _BookmarkSort.startSoonest:
        list.sort((a, b) {
          final ad = a.startDate ?? a.releaseDate;
          final bd = b.startDate ?? b.releaseDate;
          return _cmp(ad, bd);
        });
        break;
      case _BookmarkSort.registered:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  int _cmp(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$count件保存中',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.current, required this.onSelected});
  final _BookmarkSort current;
  final ValueChanged<_BookmarkSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BookmarkSort>(
      tooltip: '並び替え',
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final m in _BookmarkSort.values)
          PopupMenuItem(
            value: m,
            child: Row(
              children: [
                Icon(
                  current == m
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(current.icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(Icons.expand_more_rounded,
                size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
