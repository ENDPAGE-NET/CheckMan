import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 预设头像列表
const List<String> presetAvatars = [
  'assets/avatars/avatar_1.png',
  'assets/avatars/avatar_2.png',
  'assets/avatars/avatar_3.png',
  'assets/avatars/avatar_4.png',
  'assets/avatars/avatar_5.png',
  'assets/avatars/avatar_6.png',
];

/// 头像状态
class AvatarState {
  /// 预设头像的 asset 路径
  final String? presetPath;

  /// 自定义图片的本地文件路径
  final String? customPath;

  const AvatarState({this.presetPath, this.customPath});

  bool get hasAvatar => presetPath != null || customPath != null;
  bool get isPreset => presetPath != null;
  bool get isCustom => customPath != null && presetPath == null;
}

class AvatarNotifier extends StateNotifier<AvatarState> {
  AvatarNotifier() : super(const AvatarState());

  String? _username;

  String get _keyPreset => 'avatar_preset_${_username ?? ''}';
  String get _keyCustom => 'avatar_custom_${_username ?? ''}';

  /// 为指定用户加载头像（登录后调用）
  Future<void> loadForUser(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    final preset = prefs.getString(_keyPreset);
    final custom = prefs.getString(_keyCustom);
    state = AvatarState(presetPath: preset, customPath: custom);
  }

  /// 登出时清空显示（不删除存储）
  void clear() {
    _username = null;
    state = const AvatarState();
  }

  /// 选择预设头像
  Future<void> selectPreset(String assetPath) async {
    if (_username == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreset, assetPath);
    await prefs.remove(_keyCustom);
    state = AvatarState(presetPath: assetPath);
  }

  /// 选择自定义图片
  Future<void> selectCustom(String filePath) async {
    if (_username == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPreset);
    await prefs.setString(_keyCustom, filePath);
    state = AvatarState(customPath: filePath);
  }
}

final avatarProvider =
    StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  return AvatarNotifier();
});

/// 构建头像 Widget（用于各页面复用）
Widget buildAvatarWidget({
  required AvatarState avatarState,
  required String fallbackInitial,
  required double radius,
  required ColorScheme cs,
  required TextTheme tt,
}) {
  if (avatarState.isPreset) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(avatarState.presetPath!),
    );
  }
  if (avatarState.isCustom) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: FileImage(File(avatarState.customPath!)),
    );
  }
  // 默认：首字母
  return CircleAvatar(
    radius: radius,
    backgroundColor: cs.surfaceContainerLowest,
    child: Text(
      fallbackInitial,
      style: tt.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: cs.primary,
        fontSize: radius * 0.8,
      ),
    ),
  );
}
