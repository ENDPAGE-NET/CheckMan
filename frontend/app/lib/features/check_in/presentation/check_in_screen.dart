import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/models/check_record.dart';
import '../../../shared/widgets/botanical_card.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/providers/avatar_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/check_provider.dart';
import 'camera_screen.dart';

/// 打卡主页面 — "The Botanical Ledger" 设计系统
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _loading = false;
  CheckRecord? _lastResult;
  String? _error;
  double? _distanceMeters; // 打卡时计算的距离（米）

  @override
  void initState() {
    super.initState();
    // 加载今日打卡状态
    Future.microtask(() => ref.read(checkProvider.notifier).fetchToday());
  }

  // ---------------------------------------------------------------------------
  // 定位逻辑
  // ---------------------------------------------------------------------------
  Future<Position?> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          return null;
        }
      }
      return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  /// 计算两个经纬度之间的距离（米）— Haversine 公式
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0; // 地球半径（米）
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // ---------------------------------------------------------------------------
  // 打卡核心流程
  // ---------------------------------------------------------------------------
  Future<void> _performCheck(String checkType) async {
    setState(() {
      _loading = true;
      _error = null;
      _lastResult = null;
      _distanceMeters = null;
    });

    try {
      // 0. 先刷新用户信息，获取最新的打卡要求
      await ref.read(authProvider.notifier).refreshUser();
      final user = ref.read(authProvider).user;

      // 1. 如需人脸验证，打开相机
      List<int>? faceBytes;
      if (user?.requireFace == true) {
        final result = await Navigator.push<List<int>>(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (result == null) {
          setState(() => _loading = false);
          return;
        }
        faceBytes = result;
      }

      // 2. 如需位置验证，获取定位
      double? lat, lng;
      if (user?.requireLocation == true) {
        final position = await _getLocation();
        lat = position?.latitude;
        lng = position?.longitude;

        // 计算距离
        if (lat != null &&
            lng != null &&
            user?.locationLat != null &&
            user?.locationLng != null) {
          _distanceMeters = _calculateDistance(
            lat,
            lng,
            user!.locationLat!,
            user.locationLng!,
          );
        }
      }

      // 3. 提交打卡
      final record = await ref.read(checkProvider.notifier).performCheck(
            checkType: checkType,
            faceImageBytes: faceBytes,
            locationLat: lat,
            locationLng: lng,
          );

      if (record != null && mounted) {
        setState(() => _lastResult = record);
      }
    } catch (e) {
      if (mounted) {
        String msg = '打卡失败，请重试';
        if (e is Exception) {
          msg = e.toString().replaceAll('Exception: ', '');
        }
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI 构建
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final checkState = ref.watch(checkProvider);
    final avatarState = ref.watch(avatarProvider);
    final user = authState.user;
    final displayName = user?.name ?? '用户';
    final initials = displayName.isNotEmpty ? displayName[0] : 'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // AppBar 区域
              // ============================================================
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/images/logo.png',
                              width: 24, height: 24),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'ENDPAGE',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // 用户头像
                    buildAvatarWidget(
                      avatarState: avatarState,
                      fallbackInitial: initials,
                      radius: 20,
                      cs: cs,
                      tt: theme.textTheme,
                    ),
                  ],
                ),
              ),

              // 分隔线
              Divider(height: 1, color: cs.surfaceContainer),

              // ============================================================
              // 主内容区域
              // ============================================================
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ======================================================
                    // Hero 身份区域
                    // ======================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前身份',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3.0,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style:
                                  theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                        StatusBadge.active(label: '已激活'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // 主打卡卡片（渐变英雄卡片）
                    // ======================================================
                    GradientHeroCard(
                      child: Stack(
                        children: [
                          // 装饰性半透明圆
                          Positioned(
                            right: -48,
                            top: -48,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          // 内容
                          Column(
                            children: [
                              // "今日进度" 标签
                              Text(
                                '今日进度',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      cs.onPrimary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 实时时钟
                              StreamBuilder(
                                stream: Stream.periodic(
                                    const Duration(seconds: 1)),
                                builder: (context, _) {
                                  final now = DateTime.now();
                                  return Text(
                                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -2.0,
                                      fontSize: 48,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 4),

                              // 副标签：签到/签退状态
                              _buildStatusSubtitle(theme, cs, checkState),

                              const SizedBox(height: 24),

                              // 签到/签退按钮
                              _buildActionButton(theme, cs, checkState),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // 状态摘要网格（2列：签到 + 签退）
                    // ======================================================
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.login,
                            label: '签到',
                            value: checkState.currentCycleClockIn != null
                                ? '${checkState.currentCycleClockIn!.checkTime.hour.toString().padLeft(2, '0')}:${checkState.currentCycleClockIn!.checkTime.minute.toString().padLeft(2, '0')}'
                                : '--',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            icon: Icons.logout,
                            label: '签退',
                            value: checkState.currentCycleClockOut != null
                                ? '${checkState.currentCycleClockOut!.checkTime.hour.toString().padLeft(2, '0')}:${checkState.currentCycleClockOut!.checkTime.minute.toString().padLeft(2, '0')}'
                                : '--',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // 打卡结果 / 错误区域
                    // ======================================================
                    if (_lastResult != null) _buildResultCard(theme, cs),
                    if (_error != null || checkState.error != null)
                      _buildErrorCard(
                          theme, cs, _error ?? checkState.error!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 状态副标题
  // ---------------------------------------------------------------------------
  Widget _buildStatusSubtitle(
      ThemeData theme, ColorScheme cs, CheckState checkState) {
    String text;
    if (checkState.currentCycleClockIn != null && checkState.currentCycleClockOut != null) {
      text =
          '已签退 · 工时 ${checkState.workedDurationText}';
    } else if (checkState.currentCycleClockIn != null) {
      text =
          '签到于 ${checkState.currentCycleClockIn!.checkTime.hour.toString().padLeft(2, '0')}:${checkState.currentCycleClockIn!.checkTime.minute.toString().padLeft(2, '0')}';
    } else {
      text = '尚未签到';
    }

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onPrimary.withValues(alpha: 0.6),
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 10,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 签到/签退按钮 — 始终可用，根据最后一条记录自动切换
  // ---------------------------------------------------------------------------
  Widget _buildActionButton(
      ThemeData theme, ColorScheme cs, CheckState checkState) {
    final bool isNextClockIn = checkState.isNextClockIn;
    final bool isSubmitting = checkState.status == CheckStatus.submitting;

    final String label;
    final IconData icon;
    final Color bgColor;
    final Color fgColor;
    final VoidCallback? onPressed;

    if (isNextClockIn) {
      label = '签到';
      icon = Icons.timer;
      bgColor = cs.surfaceContainerLowest;
      fgColor = cs.primary;
      onPressed = (_loading || isSubmitting)
          ? null
          : () => _performCheck('clock_in');
    } else {
      label = '签退';
      icon = Icons.logout;
      bgColor = cs.secondaryContainer;
      fgColor = cs.onSecondaryContainer;
      onPressed = (_loading || isSubmitting)
          ? null
          : () => _performCheck('clock_out');
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: const StadiumBorder(),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.15),
        ),
        child: (_loading || isSubmitting)
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22, color: fgColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 打卡结果卡片
  // ---------------------------------------------------------------------------
  Widget _buildResultCard(ThemeData theme, ColorScheme cs) {
    final record = _lastResult!;
    final passed =
        record.facePassed != false && record.locationPassed != false;

    return BotanicalCard(
      color: passed ? cs.tertiaryContainer : cs.errorContainer,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 28,
                color: passed
                    ? cs.onTertiaryContainer
                    : cs.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  passed
                      ? (record.isClockIn ? '签到成功' : '签退成功')
                      : (record.isClockIn ? '签到异常' : '签退异常'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: passed
                        ? cs.onTertiaryContainer
                        : cs.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (record.facePassed != null)
            _verificationRow(
              theme,
              cs,
              icon: Icons.face,
              label: '人脸验证',
              passed: record.facePassed!,
            ),
          if (record.locationPassed != null)
            _verificationRow(
              theme,
              cs,
              icon: Icons.location_on,
              label: '位置验证',
              passed: record.locationPassed!,
              detail: _distanceMeters != null
                  ? '距离 ${_formatDistance(_distanceMeters!)}'
                  : null,
            ),
        ],
      ),
    );
  }

  /// 格式化距离显示
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}米';
    }
    return '${(meters / 1000).toStringAsFixed(1)}公里';
  }

  /// 单行验证结果
  Widget _verificationRow(
    ThemeData theme,
    ColorScheme cs, {
    required IconData icon,
    required String label,
    required bool passed,
    String? detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: passed ? cs.primary : cs.error,
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(width: 8),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          Text(
            passed ? '通过' : '未通过',
            style: theme.textTheme.bodySmall?.copyWith(
              color: passed ? cs.primary : cs.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 错误卡片
  // ---------------------------------------------------------------------------
  Widget _buildErrorCard(ThemeData theme, ColorScheme cs, String error) {
    return BotanicalCard(
      color: cs.errorContainer.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
