import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/check_record.dart';
import '../../../shared/widgets/botanical_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../check_in/data/check_repository.dart';

/// 打卡历史记录 Provider
final historyProvider =
    FutureProvider.autoDispose<List<CheckRecord>>((ref) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return CheckRepository().getHistory(startDate: startOfMonth);
});

/// 当前选中的日期筛选索引
final _selectedDateIndex = StateProvider.autoDispose<int>((ref) => 0);

/// 打卡历史页面 — "The Botanical Ledger" 设计系统
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final records = ref.watch(historyProvider);

    return Scaffold(
      body: SafeArea(
        child: records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text('加载失败',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$e',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          data: (list) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(historyProvider),
            child: _HistoryContent(records: list),
          ),
        ),
      ),
    );
  }
}

/// 历史页面主内容
class _HistoryContent extends ConsumerStatefulWidget {
  final List<CheckRecord> records;
  const _HistoryContent({required this.records});

  @override
  ConsumerState<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends ConsumerState<_HistoryContent> {
  /// 按日期分组记录
  Map<String, List<CheckRecord>> _groupByDate(List<CheckRecord> records) {
    final map = <String, List<CheckRecord>>{};
    for (final r in records) {
      final key = DateFormat('yyyy-MM-dd').format(r.checkTime);
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  /// 获取唯一日期列表（已排序，最新在前）
  List<DateTime> _getUniqueDates(List<CheckRecord> records) {
    final dates = <String, DateTime>{};
    for (final r in records) {
      final key = DateFormat('yyyy-MM-dd').format(r.checkTime);
      dates.putIfAbsent(key, () => r.checkTime);
    }
    final sorted = dates.values.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final records = widget.records;
    final selectedIndex = ref.watch(_selectedDateIndex);
    final uniqueDates = _getUniqueDates(records);
    final grouped = _groupByDate(records);

    // 计算统计数据
    final totalDays = uniqueDates.length;
    final clockIns = records.where((r) => r.isClockIn).toList();
    final clockOuts = records.where((r) => r.isClockOut).toList();

    // 计算本月总工时（按签到-签退配对）
    final totalWorkedMinutes = _calculateTotalWorkedMinutes(records, grouped);
    final workedHoursText = _formatWorkedTime(totalWorkedMinutes);

    // 当前选中日期的记录
    List<CheckRecord> filteredRecords;
    if (uniqueDates.isEmpty) {
      filteredRecords = [];
    } else {
      final safeIndex = selectedIndex.clamp(0, uniqueDates.length - 1);
      final selectedKey =
          DateFormat('yyyy-MM-dd').format(uniqueDates[safeIndex]);
      filteredRecords = grouped[selectedKey] ?? [];
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ==================================================================
        // AppBar 区域
        // ==================================================================
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/logo.png', width: 24, height: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ENDPAGE',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => ref.invalidate(historyProvider),
                  icon: Icon(Icons.refresh, color: cs.primary),
                ),
              ],
            ),
          ),
        ),

        // ==================================================================
        // 顶部总结卡片
        // ==================================================================
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 主统计卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // 装饰圆
                      Positioned(
                        right: -32,
                        top: -32,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy年M月').format(DateTime.now()),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$totalDays',
                                style:
                                    theme.textTheme.displayLarge?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 48,
                                  letterSpacing: -2.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8, left: 4),
                                child: Text(
                                  '/ 天',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Text(
                            '本月出勤天数',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 工时 — 整合在大卡片内
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 18,
                                    color: cs.onPrimaryContainer
                                        .withValues(alpha: 0.7)),
                                const SizedBox(width: 8),
                                Text(
                                  '本月总工时',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  workedHoursText,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 进度条
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: LinearProgressIndicator(
                              value: totalDays > 0
                                  ? (totalDays / 22).clamp(0.0, 1.0)
                                  : 0,
                              minHeight: 8,
                              backgroundColor:
                                  cs.surface.withValues(alpha: 0.4),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(cs.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 双列统计网格
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.login,
                        label: '签到次数',
                        value: '${clockIns.length}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.logout,
                        label: '签退次数',
                        value: '${clockOuts.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ==================================================================
        // 历史记录标题
        // ==================================================================
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionHeader(
              title: '历史记录',
              actionLabel: '刷新',
              onAction: () => ref.invalidate(historyProvider),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ==================================================================
        // 水平日期选择器
        // ==================================================================
        if (uniqueDates.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: uniqueDates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = uniqueDates[index];
                  final isSelected = index == selectedIndex;
                  final weekday = _weekdayLabel(date.weekday);
                  final day = date.day.toString();

                  return GestureDetector(
                    onTap: () =>
                        ref.read(_selectedDateIndex.notifier).state = index,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekday,
                            style:
                                theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? cs.onPrimary.withValues(alpha: 0.8)
                                  : cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day,
                            style:
                                theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? cs.onPrimary
                                  : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // ==================================================================
        // 日志卡片列表
        // ==================================================================
        if (records.isEmpty || filteredRecords.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history,
                        size: 56, color: cs.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      records.isEmpty ? '暂无打卡记录' : '该日期暂无记录',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= filteredRecords.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecordCard(record: filteredRecords[index]),
                  );
                },
                childCount: filteredRecords.length,
              ),
            ),
          ),

        // 底部留白
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  /// 星期标签
  String _weekdayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(weekday - 1) % 7];
  }

  /// 计算总工时（分钟）— 按天分组配对签到-签退
  int _calculateTotalWorkedMinutes(
      List<CheckRecord> allRecords, Map<String, List<CheckRecord>> grouped) {
    int total = 0;
    for (final dayRecords in grouped.values) {
      // 每天的记录按时间排序
      final sorted = List<CheckRecord>.from(dayRecords)
        ..sort((a, b) => a.checkTime.compareTo(b.checkTime));
      CheckRecord? pendingClockIn;
      for (final r in sorted) {
        if (r.isClockIn) {
          pendingClockIn = r;
        } else if (r.isClockOut && pendingClockIn != null) {
          total += r.checkTime.difference(pendingClockIn.checkTime).inMinutes;
          pendingClockIn = null;
        }
      }
    }
    return total;
  }

  /// 格式化工时显示（中文格式）
  String _formatWorkedTime(int minutes) {
    if (minutes <= 0) return '0分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '$h小时$m分钟';
    if (h > 0) return '$h小时';
    return '$m分钟';
  }
}

/// 单条打卡记录卡片
class _RecordCard extends StatelessWidget {
  final CheckRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('M月d日');
    final timeStr = timeFormat.format(record.checkTime);
    final dateStr = dateFormat.format(record.checkTime);

    final isClockIn = record.isClockIn;

    return BotanicalCard(
      color: cs.surfaceContainerLowest,
      hasShadow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：日期 + 类型标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isClockIn
                              ? cs.tertiaryContainer
                              : cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          isClockIn ? '签到' : '签退',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isClockIn
                                ? cs.onTertiaryContainer
                                : cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _weekdayName(record.checkTime.weekday),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20),
            ],
          ),

          const SizedBox(height: 16),

          // 时间
          Row(
            children: [
              Icon(
                isClockIn ? Icons.login : Icons.logout,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${isClockIn ? '签到' : '签退'}时间',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            timeStr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 星期几名称
  String _weekdayName(int weekday) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[(weekday - 1) % 7];
  }
}
