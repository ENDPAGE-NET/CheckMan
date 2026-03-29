import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/botanical_input.dart';
import '../providers/auth_provider.dart';

/// 修改密码页面 — Botanical Ledger 设计风格
class ChangePasswordScreen extends ConsumerStatefulWidget {
  /// 是否为首次登录强制修改
  final bool isForced;

  const ChangePasswordScreen({super.key, this.isForced = false});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final success = await ref.read(authProvider.notifier).changePassword(
          _oldPasswordCtrl.text,
          _newPasswordCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码修改成功')),
      );
      if (widget.isForced) {
        // 强制改密后，检查是否需要人脸录入
        final user = ref.read(authProvider).user;
        if (user != null && !user.faceRegistered) {
          context.go('/face-enrollment');
        } else {
          context.go('/home');
        }
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(authProvider).error;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: widget.isForced
          ? null
          : AppBar(
              title: const Text('修改密码'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Stack(
        children: [
          // 背景装饰光晕
          if (widget.isForced) ...[
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
          ],

          // 主体内容
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 品牌头部（仅强制改密模式）
                    if (widget.isForced) ...[
                      _buildBrandHeader(cs, tt),
                      const SizedBox(height: 48),
                    ],

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
                            if (widget.isForced) ...[
                              Text(
                                '首次登录，请修改密码',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                            ],

                            // 原密码
                            BotanicalInput(
                              controller: _oldPasswordCtrl,
                              labelText: '原密码',
                              hintText: '输入原密码',
                              obscureText: true,
                              suffixIcon: Icons.lock_outline,
                              validator: (v) =>
                                  v == null || v.isEmpty ? '请输入原密码' : null,
                            ),
                            const SizedBox(height: 20),

                            // 新密码
                            BotanicalInput(
                              controller: _newPasswordCtrl,
                              labelText: '新密码',
                              hintText: '至少 6 个字符',
                              obscureText: true,
                              suffixIcon: Icons.lock,
                              validator: (v) {
                                if (v == null || v.length < 6) {
                                  return '密码至少6位';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // 确认新密码
                            BotanicalInput(
                              controller: _confirmCtrl,
                              labelText: '确认新密码',
                              hintText: '请再次输入新密码',
                              obscureText: true,
                              suffixIcon: Icons.verified_user,
                              validator: (v) {
                                if (v != _newPasswordCtrl.text) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                            ),

                            // 错误提示
                            if (error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                error,
                                style:
                                    tt.bodySmall?.copyWith(color: cs.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 28),

                            // 提交按钮
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                  shadowColor:
                                      cs.primary.withValues(alpha: 0.2),
                                ),
                                child: _loading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: cs.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        '确认修改',
                                        style: tt.titleMedium?.copyWith(
                                          color: cs.onPrimary,
                                          fontWeight: FontWeight.bold,
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

  /// 品牌头部（强制改密模式）
  Widget _buildBrandHeader(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
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
          '安全设置 — 请修改初始密码',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
