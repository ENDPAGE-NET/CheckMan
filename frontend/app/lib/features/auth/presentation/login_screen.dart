import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/botanical_input.dart';
import '../providers/auth_provider.dart';

/// 登录页面 — Botanical Ledger 设计风格
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.status == AuthStatus.loading;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // 背景装饰光晕
          Positioned(
            top: -96,
            left: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primaryContainer.withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            bottom: -96,
            right: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.secondaryContainer.withValues(alpha: 0.10),
              ),
            ),
          ),

          // 主体内容
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 品牌头部
                    _buildBrandHeader(cs, tt),
                    const SizedBox(height: 48),

                    // 白色卡片容器
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: cs.onSurface.withValues(alpha: 0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 用户名输入
                            BotanicalInput(
                              controller: _usernameController,
                              labelText: '用户名',
                              hintText: '输入您的用户名',
                              suffixIcon: Icons.person,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? '请输入用户名' : null,
                            ),
                            const SizedBox(height: 24),

                            // 密码输入
                            BotanicalInput(
                              controller: _passwordController,
                              labelText: '密码',
                              hintText: '输入您的密码',
                              obscureText: _obscurePassword,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onSuffixTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              validator: (v) =>
                                  v == null || v.isEmpty ? '请输入密码' : null,
                            ),
                            const SizedBox(height: 8),

                            // 错误提示
                            if (auth.error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                auth.error!,
                                style: tt.bodySmall?.copyWith(color: cs.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),

                            // 登录按钮
                            SizedBox(
                              height: 64,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  shape: const StadiumBorder(),
                                  elevation: 4,
                                  shadowColor:
                                      cs.primary.withValues(alpha: 0.20),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: cs.onPrimary,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '登录',
                                            style: tt.titleMedium?.copyWith(
                                              color: cs.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.arrow_forward,
                                              size: 20, color: cs.onPrimary),
                                        ],
                                      ),
                              ),
                            ),

                            // 注册链接
                            const SizedBox(height: 24),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.push('/register'),
                                child: Text.rich(
                                  TextSpan(
                                    text: '没有账号？',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '立即注册',
                                        style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 品牌头部区域
  Widget _buildBrandHeader(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        // 图标
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/logo.png', width: 64, height: 64),
        ),
        const SizedBox(height: 24),
        Text(
          'ENDPAGE',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '智能打卡管理',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
