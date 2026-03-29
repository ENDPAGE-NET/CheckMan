import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/check_record.dart';

class CheckRepository {
  final ApiClient _client = ApiClient();

  Future<CheckRecord> performCheck({
    required String checkType,
    List<int>? faceImageBytes,
    double? locationLat,
    double? locationLng,
  }) async {
    final map = <String, dynamic>{'check_type': checkType};
    if (faceImageBytes != null) {
      map['face_image'] = MultipartFile.fromBytes(faceImageBytes, filename: 'face.jpg');
    }
    if (locationLat != null) map['location_lat'] = locationLat;
    if (locationLng != null) map['location_lng'] = locationLng;

    final formData = FormData.fromMap(map);
    final response = await _client.dio.post('/api/check', data: formData);
    return CheckRecord.fromJson(response.data);
  }

  Future<List<CheckRecord>> getTodayRecords() async {
    final response = await _client.dio.get('/api/check/today');
    final list = response.data as List;
    return list.map((e) => CheckRecord.fromJson(e)).toList();
  }

  Future<List<CheckRecord>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T')[0];

    final response = await _client.dio.get('/api/check/history', queryParameters: params);
    final list = response.data as List;
    return list.map((e) => CheckRecord.fromJson(e)).toList();
  }
}
