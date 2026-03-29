import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/check_record.dart';
import '../data/check_repository.dart';

enum CheckStatus { loading, idle, submitting }

class CheckState {
  final CheckStatus status;
  final List<CheckRecord> todayRecords;
  final String? error;

  const CheckState({
    this.status = CheckStatus.loading,
    this.todayRecords = const [],
    this.error,
  });

  CheckState copyWith({
    CheckStatus? status,
    List<CheckRecord>? todayRecords,
    String? error,
  }) =>
      CheckState(
        status: status ?? this.status,
        todayRecords: todayRecords ?? this.todayRecords,
        error: error,
      );

  bool get hasClockIn => todayRecords.any((r) => r.isClockIn);
  bool get hasClockOut => todayRecords.any((r) => r.isClockOut);

  /// 获取最近一次打卡记录（不分类型）
  CheckRecord? get latestRecord {
    if (todayRecords.isEmpty) return null;
    return todayRecords.last;
  }

  /// 判断下一次打卡应该是签到还是签退
  /// 逻辑：根据最后一条记录类型判断
  /// - 无记录 → 签到
  /// - 最后是签到 → 签退
  /// - 最后是签退 → 签到
  String get nextCheckType {
    final last = latestRecord;
    if (last == null || last.isClockOut) return 'clock_in';
    return 'clock_out';
  }

  /// 下一次操作是否是签到
  bool get isNextClockIn => nextCheckType == 'clock_in';

  CheckRecord? get lastClockIn {
    final clockIns = todayRecords.where((r) => r.isClockIn).toList();
    return clockIns.isNotEmpty ? clockIns.last : null;
  }

  CheckRecord? get lastClockOut {
    final clockOuts = todayRecords.where((r) => r.isClockOut).toList();
    return clockOuts.isNotEmpty ? clockOuts.last : null;
  }

  /// 今日最近一次签到时间
  CheckRecord? get latestClockIn {
    final clockIns = todayRecords.where((r) => r.isClockIn).toList();
    return clockIns.isNotEmpty ? clockIns.last : null;
  }

  /// 当前周期的签到记录（配对显示用）
  /// - 最后是 clock_in → 返回它（新周期刚开始）
  /// - 最后是 clock_out → 从后往前找与之配对的 clock_in
  CheckRecord? get currentCycleClockIn {
    if (todayRecords.isEmpty) return null;
    final last = todayRecords.last;
    if (last.isClockIn) return last;
    // 最后是 clock_out，往前找最近的 clock_in
    for (int i = todayRecords.length - 2; i >= 0; i--) {
      if (todayRecords[i].isClockIn) return todayRecords[i];
    }
    return null;
  }

  /// 当前周期的签退记录（配对显示用）
  /// - 最后是 clock_out → 返回它
  /// - 最后是 clock_in → 返回 null（当前周期还没签退）
  CheckRecord? get currentCycleClockOut {
    if (todayRecords.isEmpty) return null;
    final last = todayRecords.last;
    if (last.isClockOut) return last;
    return null; // 当前周期还没签退
  }

  /// 计算今日已工作时长（分钟）
  /// 只计算已配对的签到-签退组合
  int get workedMinutes {
    int total = 0;
    CheckRecord? pendingClockIn;

    for (final record in todayRecords) {
      if (record.isClockIn) {
        pendingClockIn = record;
      } else if (record.isClockOut && pendingClockIn != null) {
        total += record.checkTime.difference(pendingClockIn.checkTime).inMinutes;
        pendingClockIn = null;
      }
    }
    return total;
  }

  /// 格式化工作时长（中文格式）
  String get workedDurationText {
    final mins = workedMinutes;
    if (mins <= 0) return '0分钟';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '$h小时$m分钟';
    if (h > 0) return '$h小时';
    return '$m分钟';
  }
}

class CheckNotifier extends StateNotifier<CheckState> {
  final CheckRepository _repo = CheckRepository();

  CheckNotifier() : super(const CheckState());

  Future<void> fetchToday() async {
    try {
      final records = await _repo.getTodayRecords();
      state = CheckState(status: CheckStatus.idle, todayRecords: records);
    } catch (e) {
      state = CheckState(status: CheckStatus.idle, error: '加载失败');
    }
  }

  Future<CheckRecord?> performCheck({
    required String checkType,
    List<int>? faceImageBytes,
    double? locationLat,
    double? locationLng,
  }) async {
    state = state.copyWith(status: CheckStatus.submitting, error: null);
    try {
      final record = await _repo.performCheck(
        checkType: checkType,
        faceImageBytes: faceImageBytes,
        locationLat: locationLat,
        locationLng: locationLng,
      );
      await fetchToday();
      return record;
    } catch (e) {
      String errorMsg = '打卡失败，请重试';
      if (e is DioException && e.response?.data != null) {
        final detail = e.response?.data['detail'];
        if (detail != null) errorMsg = detail.toString();
      }
      state = state.copyWith(status: CheckStatus.idle, error: errorMsg);
      return null;
    }
  }
}

final checkProvider = StateNotifierProvider<CheckNotifier, CheckState>((ref) {
  return CheckNotifier();
});
