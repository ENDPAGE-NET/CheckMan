class CheckRecord {
  final int id;
  final DateTime checkTime;
  final String checkType;
  final bool? facePassed;
  final double? locationLat;
  final double? locationLng;
  final bool? locationPassed;

  const CheckRecord({
    required this.id,
    required this.checkTime,
    required this.checkType,
    this.facePassed,
    this.locationLat,
    this.locationLng,
    this.locationPassed,
  });

  factory CheckRecord.fromJson(Map<String, dynamic> json) {
    // 后端返回 UTC 时间，确保正确转换为本地时间
    var timeStr = json['check_time'] as String;
    // 如果没有时区标识，强制当作 UTC
    if (!timeStr.endsWith('Z') && !timeStr.contains('+')) {
      timeStr = '${timeStr}Z';
    }
    return CheckRecord(
      id: json['id'] as int,
      checkTime: DateTime.parse(timeStr).toLocal(),
      checkType: json['check_type'] as String,
      facePassed: json['face_passed'] as bool?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      locationPassed: json['location_passed'] as bool?,
    );
  }

  bool get isClockIn => checkType == 'clock_in';
  bool get isClockOut => checkType == 'clock_out';
}
