import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/oshi_event.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../detail/event_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final svc = ref.watch(eventStatusServiceProvider);
    final selected = _selectedDay ?? _focusedDay;
    final dayEvents = svc.eventsOn(events, selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        // TODO(future): Googleカレンダー連携、予約開始日のみ/締切のみ等のフィルタ
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline, width: 0.6),
              ),
              child: TableCalendar<OshiEvent>(
                locale: 'ja_JP',
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) =>
                    _selectedDay != null && isSameDay(_selectedDay, d),
                calendarFormat: _format,
                availableCalendarFormats: const {
                  CalendarFormat.month: '月',
                  CalendarFormat.twoWeeks: '2週間',
                  CalendarFormat.week: '週',
                },
                onFormatChanged: (f) => setState(() => _format = f),
                onPageChanged: (d) => _focusedDay = d,
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  });
                },
                eventLoader: (day) => svc.eventsOn(events, day),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2A1F33),
                  ),
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left_rounded,
                      color: AppColors.primary),
                  rightChevronIcon: Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B5C72),
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 3,
                  markerSize: 5,
                  markerMargin:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedDecoration: const BoxDecoration(
                    gradient: AppGradients.hero,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  defaultTextStyle: const TextStyle(
                    color: Color(0xFF2A1F33),
                    fontWeight: FontWeight.w600,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          _DayHeader(
            day: selected,
            count: dayEvents.length,
          ),
          Expanded(
            child: dayEvents.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy_rounded,
                    message: 'この日に関連するイベントはありません',
                    subtitle: '別の日を選んだり、検索から探してみましょう。',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: dayEvents.length,
                    itemBuilder: (_, i) {
                      final e = dayEvents[i];
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
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.count});
  final DateTime day;
  final int count;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('M月d日 (E)', 'ja_JP');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              fmt.format(day),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '関連 $count 件',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B5C72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
