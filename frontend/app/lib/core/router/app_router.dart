import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/check_in/presentation/check_in_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/face_enrollment_screen.dart';
import '../../features/onboarding/presentation/pending_screen.dart';
import '../../features/onboarding/presentation/rejected_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// 全局导航键
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// 用户模式分支键
final _userKeyHome = GlobalKey<NavigatorState>(debugLabel: 'home');
final _userKeyHistory = GlobalKey<NavigatorState>(debugLabel: 'history');
final _userKeyProfile = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// 路由配置
GoRouter createRouter(WidgetRef ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = auth.status == AuthStatus.authenticated;
      final path = state.uri.path;
      final isLoginPage = path == '/login';
      final isRegisterPage = path == '/register';
      final user = auth.user;

      // 未认证 -> 允许登录和注册页
      if (!isAuth) {
        if (isLoginPage || isRegisterPage) return null;
        return '/login';
      }

      // 已认证但在登录/注册页 -> 按状态跳转
      if (isLoginPage || isRegisterPage) {
        if (user?.mustChangePassword == true) return '/change-password-forced';
        if (user?.isPending == true) return '/pending';
        if (user?.isRejected == true) return '/rejected';
        if (user?.faceRegistered == false) return '/face-enrollment';
        return '/home';
      }

      // 需要改密但不在改密页
      if (user?.mustChangePassword == true &&
          !path.contains('change-password')) {
        return '/change-password-forced';
      }

      // pending 状态但不在 pending 页
      if (user?.isPending == true && path != '/pending') {
        return '/pending';
      }

      // rejected 状态但不在 rejected 页
      if (user?.isRejected == true && path != '/rejected') {
        return '/rejected';
      }

      // 人脸未录入 — 不强制拦截，仅在登录后首次进入时提示
      // 用户可以在个人中心自行录入

      return null;
    },
    routes: [
      // ================================================================
      // 认证路由（全局页面）
      // ================================================================
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/change-password-forced',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ChangePasswordScreen(isForced: true),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) =>
            const ChangePasswordScreen(isForced: false),
      ),

      // ================================================================
      // Onboarding 路由
      // ================================================================
      GoRoute(
        path: '/pending',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PendingScreen()),
      ),
      GoRoute(
        path: '/rejected',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: RejectedScreen()),
      ),
      GoRoute(
        path: '/face-enrollment',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: FaceEnrollmentScreen()),
      ),

      // ================================================================
      // 用户模式 — StatefulShellRoute（3 Tab：打卡/历史/个人）
      // ================================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _userKeyHome,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CheckInScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _userKeyHistory,
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _userKeyProfile,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
