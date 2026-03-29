import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/employee_me.dart';
import '../../../shared/models/login_response.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  Future<LoginResponse> login(String username, String password) async {
    final response = await _client.dio.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
    final loginResp = LoginResponse.fromJson(response.data);
    await _client.saveToken(loginResp.accessToken);
    return loginResp;
  }

  Future<void> register({
    required String name,
    required String username,
    required String password,
    required List<int> faceImageBytes,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'username': username,
      'password': password,
      'face_image': MultipartFile.fromBytes(
        faceImageBytes,
        filename: 'face.jpg',
      ),
    });
    await _client.dio.post('/api/auth/register', data: formData);
  }

  Future<EmployeeMe> getMe() async {
    final response = await _client.dio.get('/api/me');
    return EmployeeMe.fromJson(response.data);
  }

  Future<EmployeeMe> updateMeName(String name) async {
    final response = await _client.dio.put('/api/me', data: {'name': name});
    return EmployeeMe.fromJson(response.data);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _client.dio.post(
      '/api/auth/change-password',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<void> registerFace(List<int> imageBytes) async {
    final formData = FormData.fromMap({
      'face_image': MultipartFile.fromBytes(imageBytes, filename: 'face.jpg'),
    });
    await _client.dio.post('/api/auth/register-face', data: formData);
  }

  Future<void> logout() async {
    await _client.clearToken();
  }

  Future<bool> hasToken() => _client.hasToken();
}
