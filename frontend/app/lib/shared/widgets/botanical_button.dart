import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 设计系统按钮组件
///
/// 遵循 "Botanical Ledger" 设计规范：
/// - Primary: pill 形状, primary 色, on_primary 文字
/// - Secondary: pill 形状, surface_container_highest 色, on_surface 文字
/// - Gradient: primary→primaryDim 渐变
class BotanicalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final _BotanicalButtonVariant _variant;
  final double? width;
  final double height;

  /// Primary 按钮（实心 pill）
  const BotanicalButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
  }) : _variant = _BotanicalButtonVariant.primary;

  /// Secondary 按钮（浅色 pill）
  const BotanicalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
  }) : _variant = _BotanicalButtonVariant.secondary;

  /// 文字按钮
  const BotanicalButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
  }) : _variant = _BotanicalButtonVariant.text;

  /// 危险操作按钮
  const BotanicalButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
  }) : _variant = _BotanicalButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _variant == _BotanicalButtonVariant.primary
                  ? cs.onPrimary
                  : cs.primary,
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final effectiveOnPressed = isLoading ? null : onPressed;

    switch (_variant) {
      case _BotanicalButtonVariant.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: const StadiumBorder(),
              elevation: 0,
              shadowColor: cs.primary.withValues(alpha: 0.2),
            ),
            child: child,
          ),
        );

      case _BotanicalButtonVariant.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.surfaceContainerHighest,
              foregroundColor: cs.onSurface,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: child,
          ),
        );

      case _BotanicalButtonVariant.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              shape: const StadiumBorder(),
            ),
            child: child,
          ),
        );

      case _BotanicalButtonVariant.danger:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.errorContainer,
              foregroundColor: cs.onErrorContainer,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: child,
          ),
        );
    }
  }
}

/// 渐变按钮（用于主要 CTA）
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 56,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, BotanicalColors.primaryDim],
          ),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.20),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(9999),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: cs.onPrimary, size: 22),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _BotanicalButtonVariant { primary, secondary, text, danger }
