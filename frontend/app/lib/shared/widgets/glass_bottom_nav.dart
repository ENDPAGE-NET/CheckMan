import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 玻璃拟态底部导航栏（窄屏使用）
///
/// 遵循 "Botanical Ledger" 设计规范：
/// - 半透明背景 + backdrop-blur（原生端）
/// - Web 端降级为不透明背景（避免 BackdropFilter 性能问题）
/// - 圆角顶部 (32px)
/// - 选中态：底部圆点指示器
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// 用户模式导航项
  static const _userItems = [
    _NavItem(icon: Icons.timer_outlined, activeIcon: Icons.timer, label: '打卡'),
    _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: '历史'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '个人'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final items = _userItems;

    final navContent = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return Expanded(
              child: _NavItemWidget(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap(index),
                colorScheme: cs,
                textTheme: theme.textTheme,
              ),
            );
          }),
        ),
      ),
    );

    // Web 端不使用 BackdropFilter（性能差），改用不透明背景
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: navContent,
      );
    }

    // 原生端使用玻璃拟态
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: cs.onSurface.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: navContent,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // 标签
            Text(
              item.label,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            // 底部圆点指示器（选中态）— 固定占位，避免高度变化
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
