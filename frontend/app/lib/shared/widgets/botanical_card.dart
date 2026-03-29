import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 设计系统标准卡片组件
///
/// 遵循 "Botanical Ledger" 设计规范：
/// - 使用色调层级（Tonal Layering）替代传统阴影
/// - 禁止 1px 边框分区
/// - 默认圆角 16px (lg=32px)
class BotanicalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final bool hasShadow;
  final VoidCallback? onTap;
  final Border? border;

  const BotanicalCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 16,
    this.hasShadow = false,
    this.onTap,
    this.border,
  });

  /// 大号卡片（圆角 32px）
  const BotanicalCard.large({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.hasShadow = false,
    this.onTap,
    this.border,
  }) : borderRadius = 32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.surfaceContainerLowest;

    final decoration = BoxDecoration(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
            ]
          : null,
    );

    final content = Container(
      decoration: decoration,
      padding: padding ?? const EdgeInsets.all(24),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// 渐变英雄卡片（用于打卡按钮等主要操作区域）
///
/// 使用 primary → primaryDim 渐变
class GradientHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GradientHeroCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            BotanicalColors.primaryDim,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(32),
      child: child,
    );
  }
}
