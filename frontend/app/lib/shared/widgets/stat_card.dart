import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 统计数据卡片组件
///
/// 用于展示大号数字 + 标签的统计信息
/// 遵循 "Botanical Ledger" 编辑式排版：大字号数据 + 小字号标签
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 22,
              color: iconColor ?? cs.primary,
            ),
            const SizedBox(height: 12),
          ],
          // 标签（上方小字）
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // 大号数字
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: valueColor ?? cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 大号英雄统计卡片（用于仪表盘主区域）
class HeroStatCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final Color? backgroundColor;

  const HeroStatCard({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.trailing,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: BotanicalColors.primaryDim,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              if (trailing != null) ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
