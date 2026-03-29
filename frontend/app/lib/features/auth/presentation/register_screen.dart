import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/botanical_input.dart';
import '../../check_in/presentation/camera_screen.dart';
import '../providers/auth_provider.dart';

/// 注册页面 — Botanical Ledger 设计风格
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  List<int>? _faceImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null && mounted) {
      setState(() => _faceImageBytes = result);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_faceImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先拍摄人脸照片')),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          faceImageBytes: _faceImageBytes!,
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
                    const SizedBox(height: 36),

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
                            // 姓名
                            BotanicalInput(
                              controller: _nameController,
                              labelText: '姓名',
                              hintText: '输入您的姓名',
                              suffixIcon: Icons.badge,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? '请输入姓名' : null,
                            ),
                            const SizedBox(height: 20),

                            // 用户名
                            BotanicalInput(
                              controller: _usernameController,
                              labelText: '用户名',
                              hintText: '输入用户名',
                              suffixIcon: Icons.person,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? '请输入用户名' : null,
                            ),
                            const SizedBox(height: 20),

                            // 密码
                            BotanicalInput(
                              controller: _passwordController,
                              labelText: '密码',
                              hintText: '至少6个字符',
                              obscureText: _obscurePassword,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onSuffixTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              validator: (v) {
                                if (v == null || v.length < 6) {
                                  return '密码至少6位';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // 人脸拍照区域
                            _buildFacePhotoArea(cs, tt),
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

                            // 提交按钮
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleRegister,
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
                                    : Text(
                                        '注册',
                                        style: tt.titleMedium?.copyWith(
                                          color: cs.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 返回登录链接
                            Center(
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Text.rich(
                                  TextSpan(
                                    text: '已有账号？',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '返回登录',
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

  /// 人脸拍照区域
  Widget _buildFacePhotoArea(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '人脸照片',
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),

        // 预览 / 占位
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: _faceImageBytes == null
                  ? Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                  : null,
            ),
            child: _faceImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      Uint8List.fromList(_faceImageBytes!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击拍摄人脸照片',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (_faceImageBytes != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重新拍摄'),
            ),
          ),
        ],
      ],
    );
  }

  /// 品牌头部
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
          '创建您的账户',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
