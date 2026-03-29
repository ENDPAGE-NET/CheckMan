import 'package:flutter/material.dart';

/// 状态徽章组件
///
/// Pill 形状的状态指示器，用于显示激活状态、打卡状态等
/// 使用色调背景而非边框来区分状态
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool showDot;
  final bool animate;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.showDot = false,
    this.animate = false,
  });

  /// 成功/已激活 状态
  factory StatusBadge.active({String label = '已激活'}) {
    return StatusBadge(
      label: label,
      showDot: true,
      animate: true,
    );
  }

  /// 未激活 状态
  factory StatusBadge.inactive({String label = '未激活'}) {
    return StatusBadge(
      label: label,
      showDot: true,
    );
  }

  /// 正常打卡
  factory StatusBadge.normal({String label = '正常'}) {
    return StatusBadge(
      label: label,
      icon: Icons.check_circle_outline,
    );
  }

  /// 迟到
  factory StatusBadge.late({String label = '迟到'}) {
    return StatusBadge(
      label: label,
      icon: Icons.schedule,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bgColor = backgroundColor ?? cs.primaryContainer;
    final fgColor = textColor ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            _AnimatedDot(color: fgColor, animate: animate),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 带脉冲动画的圆点
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _AnimatedDot({required this.color, required this.animate});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.5 + 0.5 * _controller.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
