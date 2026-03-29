import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/providers/avatar_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CheckManApp()));
}

class CheckManApp extends ConsumerStatefulWidget {
  const CheckManApp({super.key});

  @override
  ConsumerState<CheckManApp> createState() => _CheckManAppState();
}

class _CheckManAppState extends ConsumerState<CheckManApp> {
  @override
  void initState() {
    super.initState();
    // 设置 API 客户端强制登出回调（401 时触发）
    ApiClient().onForceLogout = () => ref.read(authProvider.notifier).logout();
    // 初始化认证状态
    Future.microtask(() => ref.read(authProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // 认证状态变化时加载/清空头像
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        ref.read(avatarProvider.notifier).loadForUser(next.user!.username);
      } else if (next.status == AuthStatus.unauthenticated) {
        ref.read(avatarProvider.notifier).clear();
      }
    });

    // 等待初始化完成
    if (auth.status == AuthStatus.initial) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = createRouter(ref);

    return MaterialApp.router(
      title: 'ENDPAGE',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
