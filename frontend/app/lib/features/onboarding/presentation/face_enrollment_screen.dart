import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/botanical_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../check_in/presentation/camera_screen.dart';

/// 人脸录入页面 — 使用 camera 包直接拍照
class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  ConsumerState<FaceEnrollmentScreen> createState() =>
      _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen> {
  bool _loading = false;
  String? _error;
  String? _successMessage;

  Future<void> _registerFace() async {
    // 打开相机拍照
    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (result == null || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    final success = await ref.read(authProvider.notifier).registerFace(result);

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      setState(() => _successMessage = '人脸录入成功');
      // 短暂延迟后跳转到首页
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go('/home');
    } else {
      final authError = ref.read(authProvider).error;
      setState(() => _error = authError ?? '人脸录入失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // 顶部：返回/退出
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // 无法返回时提供登出选项
                        ref.read(authProvider.notifier).logout();
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text('跳过', style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '人脸识别设置',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '设置生物识别身份验证，实现更快速的打卡。',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 成功消息
              if (_successMessage != null) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 40, color: cs.tertiary),
                ),
                const SizedBox(height: 16),
                Text(
                  _successMessage!,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.tertiary,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 相机预览占位区
              if (_successMessage == null) ...[
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cs.onSurface.withValues(alpha: 0.06),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 圆形引导框
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.primary, width: 3),
                        ),
                      ),
                      // 外环
                      Container(
                        width: 236,
                        height: 236,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.primaryContainer.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                      ),
                      // 中央图标
                      Icon(
                        Icons.face_retouching_natural,
                        size: 64,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.30),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 提示徽章
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: cs.onSurface.withValues(alpha: 0.06),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        '请将面部置于圆圈内进行录入',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 错误信息
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: tt.bodySmall?.copyWith(color: cs.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 录制面部按钮
              GradientButton(
                label: _loading ? '处理中...' : '录制面部',
                icon: Icons.photo_camera,
                isLoading: _loading,
                onPressed: _loading ? null : _registerFace,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
