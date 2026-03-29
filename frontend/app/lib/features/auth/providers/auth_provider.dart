import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/employee_me.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final EmployeeMe? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, EmployeeMe? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();

  AuthNotifier() : super(const AuthState());

  Future<void> init() async {
    final hasToken = await _repo.hasToken();
    if (hasToken) {
      try {
        final user = await _repo.getMe();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        await _repo.logout();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repo.login(username, password);
      final user = await _repo.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _parseError(e),
      );
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String password,
    required List<int> faceImageBytes,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repo.register(
        name: name,
        username: username,
        password: password,
        faceImageBytes: faceImageBytes,
      );
      await _repo.login(username, password);
      final user = await _repo.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _parseError(e),
      );
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _repo.changePassword(oldPassword, newPassword);
      final user = await _repo.getMe();
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }

  Future<bool> registerFace(List<int> imageBytes) async {
    try {
      await _repo.registerFace(imageBytes);
      final user = await _repo.getMe();
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<bool> updateDisplayName(String name) async {
    try {
      final user = await _repo.updateMeName(name);
      state = state.copyWith(user: user, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) return '用户名或密码错误';
      if (e.response?.statusCode == 409) return '用户名已被注册';
      if (e.response?.statusCode == 400) {
        final detail = e.response?.data['detail'];
        if (detail != null) return detail.toString();
      }
      if (e.type == DioExceptionType.connectionError) return '无法连接服务器';
      if (e.type == DioExceptionType.connectionTimeout) return '连接超时';
    }
    return '操作失败，请重试';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
