import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/providers/avatar_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// 个人中心页面 — Botanical Ledger 设计风格
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              // 顶部栏
              _buildTopBar(cs, tt),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部资料区（居中）
                    _buildProfileHeader(context, ref, cs, tt, user),
                    const SizedBox(height: 32),

                    // 系统设置
                    _buildSectionTitle('系统设置', tt, cs),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(context, ref, cs, tt),
                    const SizedBox(height: 32),

                    // 退出登录按钮
                    _buildLogoutButton(context, ref, cs, tt),
                    const SizedBox(height: 24),

                    // 版本号
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.40),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                Image.asset('assets/images/logo.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'ENDPAGE',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 头部资料区域 — 居中布局 + 点击头像选择
  Widget _buildProfileHeader(BuildContext context, WidgetRef ref,
      ColorScheme cs, TextTheme tt, dynamic user) {
    final name = user?.name ?? '未知用户';
    final initials = name.isNotEmpty ? name[0] : '?';
    final isActive = user?.isActive ?? false;
    final avatarState = ref.watch(avatarProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像 — 点击弹出选择面板
          GestureDetector(
            onTap: () => _showAvatarPicker(context, ref, cs, tt),
            child: Stack(
              children: [
                buildAvatarWidget(
                  avatarState: avatarState,
                  fallbackInitial: initials,
                  radius: 48,
                  cs: cs,
                  tt: tt,
                ),
                // 相机图标
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.surfaceContainerLow,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: cs.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
                // 激活标签
                if (isActive)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: cs.surfaceContainerLow,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '已激活',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: cs.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 姓名 — 点击可修改
          GestureDetector(
            onTap: () => _editNickname(context, ref, name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit, size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 修改昵称
  void _editNickname(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新昵称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                Navigator.pop(ctx);
                final success = await ref
                    .read(authProvider.notifier)
                    .updateDisplayName(newName);
                if (context.mounted) {
                  final error = ref.read(authProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? '昵称已更新'
                          : '更新失败${error != null ? ': $error' : ''}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                Navigator.pop(ctx);
              }
            },
            child: Text('确定', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  /// 头像选择面板（BottomSheet）
  void _showAvatarPicker(
      BuildContext context, WidgetRef ref, ColorScheme cs, TextTheme tt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '选择头像',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // 预设头像网格
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: presetAvatars.length,
                itemBuilder: (context, index) {
                  final path = presetAvatars[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(avatarProvider.notifier).selectPreset(path);
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      backgroundImage: AssetImage(path),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 从相册选择
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 85,
                    );
                    if (picked != null) {
                      ref
                          .read(avatarProvider.notifier)
                          .selectCustom(picked.path);
                    }
                  },
                  icon: Icon(Icons.photo_library, color: cs.primary, size: 20),
                  label: Text(
                    '从相册选择',
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme tt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: tt.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
      BuildContext context, WidgetRef ref, ColorScheme cs, TextTheme tt) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildSettingItem(cs, tt,
              icon: Icons.lock_reset,
              label: '修改密码',
              onTap: () => context.push('/change-password')),
          Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: cs.surfaceContainer),
          _buildSettingItem(cs, tt,
              icon: Icons.face_retouching_natural,
              label: '人脸重录',
              onTap: () => context.push('/face-enrollment')),
        ],
      ),
    );
  }

  Widget _buildSettingItem(ColorScheme cs, TextTheme tt,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: cs.onSurfaceVariant, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    )),
              ),
              Icon(Icons.chevron_right, color: cs.outlineVariant, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, WidgetRef ref, ColorScheme cs, TextTheme tt) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('确认退出'),
              content: const Text('确定要退出登录吗？'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child:
                        Text('退出', style: TextStyle(color: cs.error))),
              ],
            ),
          );
          if (confirmed == true) {
            ref.read(authProvider.notifier).logout();
          }
        },
        icon: Icon(Icons.logout, size: 18, color: cs.error),
        label: Text('退出登录',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: cs.error,
            )),
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: cs.error.withValues(alpha: 0.20)),
          backgroundColor: cs.errorContainer.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}
