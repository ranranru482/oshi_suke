import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/work.dart';
import '../../providers/event_provider.dart';
import '../../providers/work_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import 'work_detail_screen.dart';

class WorksScreen extends ConsumerWidget {
  const WorksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final works = ref.watch(worksProvider);
    final events = ref.watch(eventsProvider);
    final favoriteOnly = ref.watch(_favoriteFilterProvider);

    final visible =
        favoriteOnly ? works.where((w) => w.isFavorite).toList() : works;

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ作品'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterToggle(
              label: 'お気に入り',
              value: favoriteOnly,
              onChanged: (v) =>
                  ref.read(_favoriteFilterProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: visible.isEmpty
          ? EmptyState(
              icon: Icons.movie_filter_outlined,
              message: favoriteOnly
                  ? 'お気に入り作品はまだありません'
                  : '作品が登録されていません',
              subtitle: '右下のボタンから推し作品を追加して、関連イベントを集めましょう。',
              actionLabel: '作品を追加',
              onAction: () => _showAddWorkDialog(context, ref),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: visible.length,
              itemBuilder: (_, i) {
                final w = visible[i];
                final count = events.where((e) => e.workId == w.id).length;
                return _WorkCard(work: w, eventCount: count);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('作品を追加'),
      ),
    );
  }

  Future<void> _showAddWorkDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final genreCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('作品を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: '作品名'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: genreCtrl,
                decoration: const InputDecoration(labelText: 'ジャンル'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size(96, 40)),
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) return;
                final w = Work(
                  id: 'w_user_${DateTime.now().microsecondsSinceEpoch}',
                  title: t,
                  genre: genreCtrl.text.trim().isEmpty
                      ? 'その他'
                      : genreCtrl.text.trim(),
                  isFavorite: true,
                );
                ref.read(worksProvider.notifier).addWork(w);
                Navigator.pop(ctx);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }
}

final _favoriteFilterProvider = StateProvider<bool>((ref) => false);

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 14,
              color: value ? AppColors.primary : const Color(0xFF6B5C72),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: value ? AppColors.primary : const Color(0xFF6B5C72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkCard extends ConsumerWidget {
  const _WorkCard({required this.work, required this.eventCount});

  final Work work;
  final int eventCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppGradients.categoryPalette[
        work.id.hashCode.abs() % AppGradients.categoryPalette.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkDetailScreen(workId: work.id),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline, width: 0.6),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: palette,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      work.title.characters.first,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF231A2A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        work.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF8A7A93),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Stat(
                            icon: Icons.event_outlined,
                            text: '関連 $eventCount 件',
                          ),
                          const SizedBox(width: 8),
                          _Stat(
                            icon: work.notificationEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_outlined,
                            text:
                                work.notificationEnabled ? '通知ON' : '通知OFF',
                            color: work.notificationEnabled
                                ? AppColors.primary
                                : const Color(0xFF8A7A93),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _RoundIconButton(
                      tooltip: 'お気に入り',
                      icon: work.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: work.isFavorite
                          ? Colors.pinkAccent
                          : const Color(0xFFB1A4B8),
                      onPressed: () => ref
                          .read(worksProvider.notifier)
                          .toggleFavorite(work.id),
                    ),
                    const SizedBox(height: 4),
                    _RoundIconButton(
                      tooltip: '通知',
                      icon: work.notificationEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_outlined,
                      color: work.notificationEnabled
                          ? AppColors.primary
                          : const Color(0xFFB1A4B8),
                      onPressed: () => ref
                          .read(worksProvider.notifier)
                          .toggleNotification(work.id),
                    ),
                    const SizedBox(height: 4),
                    _RoundIconButton(
                      tooltip: '削除',
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFB1A4B8),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${work.title} を削除しますか？'),
        content: const Text('登録解除すると、この作品の関連イベント抽出やお気に入りからも外れます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusDeadline,
              minimumSize: const Size(96, 40),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(worksProvider.notifier).removeWork(work.id);
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6B5C72);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
