import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/oshi_event.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// ホーム画面の横スクロール用ヒーローカード。
class FeaturedEventCard extends ConsumerWidget {
  const FeaturedEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final OshiEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(eventStatusProvider(event));
    final fmt = DateFormat('M/d');
    final palette = AppGradients.categoryPalette[
        event.id.hashCode.abs() % AppGradients.categoryPalette.length];

    String? subDate;
    if (event.startDate != null && event.endDate != null) {
      subDate =
          '${fmt.format(event.startDate!)} 〜 ${fmt.format(event.endDate!)}';
    } else if (event.releaseDate != null) {
      subDate = '発売 ${fmt.format(event.releaseDate!)}';
    } else if (event.reservationEndDate != null) {
      subDate = '予約締切 ${fmt.format(event.reservationEndDate!)}';
    }

    return SizedBox(
      width: 240,
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline, width: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ヘッダー画像エリア
                Stack(
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: palette,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          event.category.icon,
                          size: 56,
                          color: AppColors.primaryDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: StatusBadge(status: status, solid: true, dense: true),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                          tooltip: 'ブックマーク',
                          icon: Icon(
                            event.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: event.isBookmarked
                                ? AppColors.primary
                                : const Color(0xFF6B5C72),
                            size: 18,
                          ),
                          onPressed: () {
                            ref
                                .read(eventsProvider.notifier)
                                .toggleBookmark(event.id);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.workTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: Color(0xFF231A2A),
                        ),
                      ),
                      if (subDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: Color(0xFF8A7A93),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subDate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF8A7A93),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
