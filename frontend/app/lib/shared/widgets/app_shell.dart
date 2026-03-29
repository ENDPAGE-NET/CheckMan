import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'glass_bottom_nav.dart';

/// 应用壳 — 底部导航包装
///
/// 简单封装：Scaffold + body(navigationShell) + bottomNavigationBar(GlassBottomNav)
/// 仅支持员工模式（无 admin 切换）
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
