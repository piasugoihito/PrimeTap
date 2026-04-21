import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'game_models.dart';

enum RecordRange { day, month, year }

class RecordDashboard extends StatefulWidget {
  const RecordDashboard({super.key, required this.records});

  final List<DailyTapRecord> records;

  @override
  State<RecordDashboard> createState() => _RecordDashboardState();
}

class _RecordDashboardState extends State<RecordDashboard> {
  late final Map<DateTime, DailyTapRecord> _recordMap;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  RecordRange _range = RecordRange.day;

  @override
  void initState() {
    super.initState();
    _recordMap = {
      for (final record in widget.records)
        _normalizeDate(DateTime.parse(record.dateKey)): record,
    };
    _focusedDay = _recordMap.keys.isNotEmpty
        ? _recordMap.keys.last
        : _normalizeDate(DateTime.now());
    _selectedDay = _focusedDay;
  }

  @override
  void didUpdateWidget(covariant RecordDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records == widget.records) {
      return;
    }
    _recordMap = {
      for (final record in widget.records)
        _normalizeDate(DateTime.parse(record.dateKey)): record,
    };
    final normalizedNow = _normalizeDate(DateTime.now());
    _focusedDay = _recordMap.keys.isNotEmpty ? _recordMap.keys.last : normalizedNow;
    _selectedDay ??= _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecord = _selectedDay == null
        ? null
        : _recordMap[_normalizeDate(_selectedDay!)];
    final dayItems = _buildDayItems();
    final monthItems = _buildMonthItems();
    final yearItems = _buildYearItems();
    final chartItems = switch (_range) {
      RecordRange.day => dayItems,
      RecordRange.month => monthItems,
      RecordRange.year => yearItems,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TableCalendar<DailyTapRecord>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(day, _selectedDay),
            locale: 'ja_JP',
            eventLoader: (day) {
              final record = _recordMap[_normalizeDate(day)];
              return record == null ? <DailyTapRecord>[] : [record];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF7B61FF),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF2A9D8F),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _selectedDay == null
                    ? '選択中の記録はありません'
                    : '${DateFormat('yyyy年M月d日').format(_selectedDay!)} の記録',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RecordSummaryCard(
                      label: 'タップ回数',
                      value: '${selectedRecord?.tapCount ?? 0}',
                      color: const Color(0xFF7B61FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RecordSummaryCard(
                      label: '最高速度',
                      value:
                          (selectedRecord?.highestTapsPerSecond ?? 0).toStringAsFixed(1),
                      color: const Color(0xFFFF9F1C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RecordSummaryCard(
                      label: 'ポイント',
                      value: '${selectedRecord?.tapPoints ?? 0}',
                      color: const Color(0xFF2A9D8F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final range in RecordRange.values)
              ChoiceChip(
                label: Text(_rangeLabel(range)),
                selected: _range == range,
                onSelected: (_) {
                  setState(() {
                    _range = range;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricChartCard(
          title: '${_rangeLabel(_range)}別タップ回数',
          color: const Color(0xFF7B61FF),
          items: chartItems,
          valueBuilder: (item) => item.tapCount.toDouble(),
        ),
        const SizedBox(height: 12),
        _MetricChartCard(
          title: '${_rangeLabel(_range)}別最高タップ速度',
          color: const Color(0xFFFF9F1C),
          items: chartItems,
          valueBuilder: (item) => item.highestTapsPerSecond,
        ),
        const SizedBox(height: 12),
        _MetricChartCard(
          title: '${_rangeLabel(_range)}別タップポイント',
          color: const Color(0xFF2A9D8F),
          items: chartItems,
          valueBuilder: (item) => item.tapPoints.toDouble(),
        ),
      ],
    );
  }

  List<RecordChartItem> _buildDayItems() {
    final sorted = widget.records.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    final lastItems = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return lastItems
        .map(
          (record) => RecordChartItem(
            label: DateFormat('M/d').format(DateTime.parse(record.dateKey)),
            tapCount: record.tapCount,
            highestTapsPerSecond: record.highestTapsPerSecond,
            tapPoints: record.tapPoints,
          ),
        )
        .toList();
  }

  List<RecordChartItem> _buildMonthItems() {
    final bucket = <String, List<DailyTapRecord>>{};
    for (final record in widget.records) {
      final date = DateTime.parse(record.dateKey);
      final key = DateFormat('yyyy-MM').format(date);
      bucket.putIfAbsent(key, () => <DailyTapRecord>[]).add(record);
    }
    final keys = bucket.keys.toList()..sort();
    final lastKeys = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;
    return lastKeys.map((key) {
      final values = bucket[key]!;
      return RecordChartItem(
        label: DateFormat('yy/MM').format(DateTime.parse('$key-01')),
        tapCount: values.fold(0, (sum, item) => sum + item.tapCount),
        highestTapsPerSecond: values.fold(
          0,
          (maxValue, item) => math.max(maxValue, item.highestTapsPerSecond),
        ),
        tapPoints: values.fold(0, (sum, item) => sum + item.tapPoints),
      );
    }).toList();
  }

  List<RecordChartItem> _buildYearItems() {
    final bucket = <String, List<DailyTapRecord>>{};
    for (final record in widget.records) {
      final date = DateTime.parse(record.dateKey);
      final key = DateFormat('yyyy').format(date);
      bucket.putIfAbsent(key, () => <DailyTapRecord>[]).add(record);
    }
    final keys = bucket.keys.toList()..sort();
    final lastKeys = keys.length > 5 ? keys.sublist(keys.length - 5) : keys;
    return lastKeys.map((key) {
      final values = bucket[key]!;
      return RecordChartItem(
        label: key,
        tapCount: values.fold(0, (sum, item) => sum + item.tapCount),
        highestTapsPerSecond: values.fold(
          0,
          (maxValue, item) => math.max(maxValue, item.highestTapsPerSecond),
        ),
        tapPoints: values.fold(0, (sum, item) => sum + item.tapPoints),
      );
    }).toList();
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  String _rangeLabel(RecordRange range) {
    switch (range) {
      case RecordRange.day:
        return '日';
      case RecordRange.month:
        return '月';
      case RecordRange.year:
        return '年';
    }
  }
}

class RecordChartItem {
  const RecordChartItem({
    required this.label,
    required this.tapCount,
    required this.highestTapsPerSecond,
    required this.tapPoints,
  });

  final String label;
  final int tapCount;
  final double highestTapsPerSecond;
  final int tapPoints;
}

class _RecordSummaryCard extends StatelessWidget {
  const _RecordSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard({
    required this.title,
    required this.color,
    required this.items,
    required this.valueBuilder,
  });

  final String title;
  final Color color;
  final List<RecordChartItem> items;
  final double Function(RecordChartItem item) valueBuilder;

  @override
  Widget build(BuildContext context) {
    final safeItems = items.isEmpty
        ? const [
            RecordChartItem(
              label: '-',
              tapCount: 0,
              highestTapsPerSecond: 0,
              tapPoints: 0,
            ),
          ]
        : items;
    final maxY = safeItems
            .map(valueBuilder)
            .fold<double>(0, (maxValue, value) => math.max(maxValue, value)) +
        1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= safeItems.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            safeItems[index].label,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < safeItems.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: valueBuilder(safeItems[i]),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: color,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
