# CheckMan Flutter 员工端 App 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 CheckMan 创建 Flutter 员工端 App，复用 flutter_check 的 Botanical Ledger 设计系统，对接 CheckMan 后端 API。

**Architecture:** Feature-first 目录结构，flutter_riverpod 状态管理，go_router 路由（含状态路由守卫），dio 网络层。UI 组件从 flutter_check 移植，业务逻辑针对 CheckMan API 重写。

**Tech Stack:** Flutter 3.41+, flutter_riverpod, go_router, dio, camera, geolocator, google_fonts, freezed, intl

**参考源码:** `/Users/xbang/code/VScode/flutter_check/flutter_app/lib/`
**设计规范:** `/Users/xbang/code/VScode/CheckMan/design/UI-DESIGN-SPEC.md`
**后端代码:** `/Users/xbang/code/VScode/CheckMan/backend/app/`

---

## Task 1: 创建 Flutter 项目 + 平台配置

**Files:**
- Create: `frontend/app/` (Flutter project)
- Modify: `frontend/app/pubspec.yaml`
- Modify: `frontend/app/ios/Podfile`
- Modify: `frontend/app/ios/Runner/Info.plist`
- Modify: `frontend/app/ios/Runner.xcodeproj/project.pbxproj` (deployment target)
- Modify: `frontend/app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: 创建 Flutter 项目**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend
flutter create --org com.checkman --project-name checkman_app app
```

- [ ] **Step 2: 替换 pubspec.yaml**

替换 `frontend/app/pubspec.yaml` 为：

```yaml
name: checkman_app
description: "CheckMan 员工考勤 App"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.11.3

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.4
  camera: ^0.11.1
  geolocator: ^13.0.2
  google_fonts: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: 配置 iOS**

替换 `frontend/app/ios/Podfile`，取消注释并设置 platform：

```ruby
platform :ios, '16.0'
```

即把第一行 `# platform :ios, ...` 改为 `platform :ios, '16.0'`。

修改 `ios/Runner.xcodeproj/project.pbxproj`：搜索所有 `IPHONEOS_DEPLOYMENT_TARGET`，值改为 `16.0`。

如果有硬编码的 `DEVELOPMENT_TEAM`，删除该行（让 Xcode 自动签名）。

修改 `ios/Runner/Info.plist`，在 `</dict>` 之前添加权限声明：

```xml
<key>NSCameraUsageDescription</key>
<string>打卡时需要使用前置摄像头拍摄人脸照片</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>打卡时需要获取您的位置信息以验证打卡地点</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>打卡时需要获取您的位置信息以验证打卡地点</string>
```

- [ ] **Step 4: 配置 Android 权限**

在 `android/app/src/main/AndroidManifest.xml` 的 `<manifest>` 标签内、`<application>` 标签前添加：

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

- [ ] **Step 5: 安装依赖并验证**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter pub get
flutter analyze
```

Expected: 无 error（可能有默认代码的 warning，忽略即可）

- [ ] **Step 6: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app
git commit -m "feat: scaffold Flutter project with platform config

- iOS deployment target 16.0, camera/location permissions
- Android camera/location permissions
- All dependencies declared in pubspec.yaml"
```

---

## Task 2: 移植设计系统（主题 + 共享组件）

**Files:**
- Create: `frontend/app/lib/core/theme/app_theme.dart`
- Create: `frontend/app/lib/shared/widgets/botanical_card.dart`
- Create: `frontend/app/lib/shared/widgets/botanical_input.dart`
- Create: `frontend/app/lib/shared/widgets/botanical_button.dart`
- Create: `frontend/app/lib/shared/widgets/status_badge.dart`
- Create: `frontend/app/lib/shared/widgets/stat_card.dart`
- Create: `frontend/app/lib/shared/widgets/section_header.dart`
- Create: `frontend/app/lib/shared/widgets/glass_bottom_nav.dart`

**Source:** 从 `/Users/xbang/code/VScode/flutter_check/flutter_app/lib/` 复制以下文件，**仅修改 import 路径**（将 `package:attendance_app/` 改为 `package:checkman_app/`）：

- [ ] **Step 1: 复制主题文件**

复制 `flutter_check/.../core/theme/app_theme.dart` 到 `frontend/app/lib/core/theme/app_theme.dart`。内容不变（已在之前读取过，包含 `BotanicalColors`, `AppShadows`, `AppRadius`, `AppSpacing`, `AppTheme` 等类）。

- [ ] **Step 2: 复制共享组件**

逐个复制以下文件到 `frontend/app/lib/shared/widgets/`，修改 import 路径：

1. `botanical_card.dart` — import 改为 `package:checkman_app/core/theme/app_theme.dart`
2. `botanical_input.dart` — 无需改（不依赖自定义 import）
3. `botanical_button.dart` — import 改为 `package:checkman_app/core/theme/app_theme.dart`
4. `status_badge.dart` — 无需改
5. `stat_card.dart` — import 改为 `package:checkman_app/core/theme/app_theme.dart`
6. `section_header.dart` — 无需改
7. `glass_bottom_nav.dart` — 删除 `isAdminMode`/`showModeSwitcher`/`onModeSwitch` 相关代码和 `_adminItems`、`_ModeSwitchNavItem`，只保留用户模式的 3 个 tab（打卡/历史/个人）

- [ ] **Step 3: 验证编译**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter analyze lib/core/theme/ lib/shared/widgets/
```

Expected: 无 error

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/core/theme frontend/app/lib/shared/widgets
git commit -m "feat: port Botanical Ledger design system from flutter_check

- AppTheme with full color scheme, typography, component themes
- Shared widgets: BotanicalCard, BotanicalInput, BotanicalButton,
  StatusBadge, StatCard, SectionHeader, GlassBottomNav
- GlassBottomNav simplified to employee-only (no admin mode)"
```

---

## Task 3: 核心基础设施（Config + ApiClient）

**Files:**
- Create: `frontend/app/lib/core/config/app_config.dart`
- Create: `frontend/app/lib/core/network/api_client.dart`

- [ ] **Step 1: 创建 AppConfig**

创建 `frontend/app/lib/core/config/app_config.dart`：

```dart
class AppConfig {
  static const String appName = 'CheckMan';
  static const String apiBaseUrl = 'http://localhost:8000';

  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: apiBaseUrl,
      );
}
```

- [ ] **Step 2: 创建 ApiClient**

创建 `frontend/app/lib/core/network/api_client.dart`：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void Function()? onForceLogout;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          onForceLogout?.call();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> saveToken(String accessToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
```

注意和 flutter_check 的区别：没有 refresh token，401 直接触发登出。

- [ ] **Step 3: 验证**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter analyze lib/core/
```

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/core/config frontend/app/lib/core/network
git commit -m "feat: add AppConfig and ApiClient with JWT interceptor

- Single access_token auth (no refresh token)
- 401 triggers force logout callback
- Configurable base URL via env"
```

---

## Task 4: 数据模型

**Files:**
- Create: `frontend/app/lib/shared/models/employee_me.dart`
- Create: `frontend/app/lib/shared/models/login_response.dart`
- Create: `frontend/app/lib/shared/models/check_record.dart`

- [ ] **Step 1: 创建 EmployeeMe 模型**

创建 `frontend/app/lib/shared/models/employee_me.dart`：

```dart
class EmployeeMe {
  final int id;
  final String name;
  final String username;
  final String status;
  final bool faceRegistered;
  final bool mustChangePassword;
  final bool requireFace;
  final bool requireLocation;
  final double? locationLat;
  final double? locationLng;
  final double? locationRadius;

  const EmployeeMe({
    required this.id,
    required this.name,
    required this.username,
    required this.status,
    this.faceRegistered = false,
    this.mustChangePassword = false,
    this.requireFace = false,
    this.requireLocation = false,
    this.locationLat,
    this.locationLng,
    this.locationRadius,
  });

  factory EmployeeMe.fromJson(Map<String, dynamic> json) => EmployeeMe(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        status: json['status'] as String,
        faceRegistered: json['face_registered'] as bool? ?? false,
        mustChangePassword: json['must_change_password'] as bool? ?? false,
        requireFace: json['require_face'] as bool? ?? false,
        requireLocation: json['require_location'] as bool? ?? false,
        locationLat: (json['location_lat'] as num?)?.toDouble(),
        locationLng: (json['location_lng'] as num?)?.toDouble(),
        locationRadius: (json['location_radius'] as num?)?.toDouble(),
      );

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isReady => isActive && !mustChangePassword && faceRegistered;
}
```

- [ ] **Step 2: 创建 LoginResponse 模型**

创建 `frontend/app/lib/shared/models/login_response.dart`：

```dart
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String status;
  final bool mustChangePassword;
  final bool faceRegistered;

  const LoginResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.status,
    required this.mustChangePassword,
    required this.faceRegistered,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
        status: json['status'] as String,
        mustChangePassword: json['must_change_password'] as bool,
        faceRegistered: json['face_registered'] as bool,
      );
}
```

- [ ] **Step 3: 创建 CheckRecord 模型**

创建 `frontend/app/lib/shared/models/check_record.dart`：

```dart
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

  factory CheckRecord.fromJson(Map<String, dynamic> json) => CheckRecord(
        id: json['id'] as int,
        checkTime: DateTime.parse(json['check_time'] as String),
        checkType: json['check_type'] as String,
        facePassed: json['face_passed'] as bool?,
        locationLat: (json['location_lat'] as num?)?.toDouble(),
        locationLng: (json['location_lng'] as num?)?.toDouble(),
        locationPassed: json['location_passed'] as bool?,
      );

  bool get isClockIn => checkType == 'clock_in';
  bool get isClockOut => checkType == 'clock_out';
}
```

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/shared/models
git commit -m "feat: add data models matching CheckMan backend schemas

- EmployeeMe (from /api/me with check requirements)
- LoginResponse (from /api/auth/login)
- CheckRecord (from /api/check/today and /api/check/history)"
```

---

## Task 5: Auth Repository + Provider

**Files:**
- Create: `frontend/app/lib/features/auth/data/auth_repository.dart`
- Create: `frontend/app/lib/features/auth/providers/auth_provider.dart`

- [ ] **Step 1: 创建 AuthRepository**

创建 `frontend/app/lib/features/auth/data/auth_repository.dart`：

```dart
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
      'face_image': MultipartFile.fromBytes(faceImageBytes, filename: 'face.jpg'),
    });
    await _client.dio.post('/api/auth/register', data: formData);
  }

  Future<EmployeeMe> getMe() async {
    final response = await _client.dio.get('/api/me');
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
```

- [ ] **Step 2: 创建 AuthProvider**

创建 `frontend/app/lib/features/auth/providers/auth_provider.dart`：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/employee_me.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final EmployeeMe? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

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
      // 注册后自动登录
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
```

- [ ] **Step 3: 验证**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter analyze lib/features/auth/
```

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/auth
git commit -m "feat: add auth repository and provider

- Login, register (multipart with face), change password, register face
- AuthNotifier with status routing state
- Error parsing for DioException"
```

---

## Task 6: Check Repository + Provider

**Files:**
- Create: `frontend/app/lib/features/check_in/data/check_repository.dart`
- Create: `frontend/app/lib/features/check_in/providers/check_provider.dart`

- [ ] **Step 1: 创建 CheckRepository**

创建 `frontend/app/lib/features/check_in/data/check_repository.dart`：

```dart
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
```

- [ ] **Step 2: 创建 CheckProvider**

创建 `frontend/app/lib/features/check_in/providers/check_provider.dart`：

```dart
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

  CheckRecord? get lastClockIn {
    final clockIns = todayRecords.where((r) => r.isClockIn).toList();
    return clockIns.isNotEmpty ? clockIns.last : null;
  }

  CheckRecord? get lastClockOut {
    final clockOuts = todayRecords.where((r) => r.isClockOut).toList();
    return clockOuts.isNotEmpty ? clockOuts.last : null;
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
      state = state.copyWith(status: CheckStatus.idle, error: '打卡失败，请重试');
      return null;
    }
  }
}

final checkProvider = StateNotifierProvider<CheckNotifier, CheckState>((ref) {
  return CheckNotifier();
});
```

- [ ] **Step 3: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/check_in/data frontend/app/lib/features/check_in/providers
git commit -m "feat: add check repository and provider

- performCheck with multipart face image upload
- getTodayRecords, getHistory with date filters
- CheckState tracks today's clock_in/clock_out status"
```

---

## Task 7: 路由 + AppShell + main.dart

**Files:**
- Create: `frontend/app/lib/core/router/app_router.dart`
- Create: `frontend/app/lib/shared/widgets/app_shell.dart`
- Modify: `frontend/app/lib/main.dart`

- [ ] **Step 1: 创建 AppShell（员工专用，无管理模式）**

创建 `frontend/app/lib/shared/widgets/app_shell.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'glass_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 创建路由配置**

创建 `frontend/app/lib/core/router/app_router.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/check_in/presentation/check_in_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/pending_screen.dart';
import '../../features/onboarding/presentation/rejected_screen.dart';
import '../../features/onboarding/presentation/face_enrollment_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _historyKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

GoRouter createRouter(WidgetRef ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = auth.status == AuthStatus.authenticated;
      final path = state.uri.path;
      final user = auth.user;

      if (!isAuth) {
        return (path == '/login' || path == '/register') ? null : '/login';
      }

      if (path == '/login' || path == '/register') {
        if (user?.mustChangePassword == true) return '/change-password-forced';
        if (user?.isPending == true) return '/pending';
        if (user?.isRejected == true) return '/rejected';
        if (user?.faceRegistered == false) return '/face-enrollment';
        return '/home';
      }

      if (user?.mustChangePassword == true && !path.contains('change-password')) {
        return '/change-password-forced';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/change-password-forced',
        pageBuilder: (_, __) => const NoTransitionPage(
          child: ChangePasswordScreen(isForced: true),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen(isForced: false),
      ),
      GoRoute(
        path: '/pending',
        pageBuilder: (_, __) => const NoTransitionPage(child: PendingScreen()),
      ),
      GoRoute(
        path: '/rejected',
        pageBuilder: (_, __) => const NoTransitionPage(child: RejectedScreen()),
      ),
      GoRoute(
        path: '/face-enrollment',
        pageBuilder: (_, __) => const NoTransitionPage(child: FaceEnrollmentScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, __) => const NoTransitionPage(child: CheckInScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyKey,
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (_, __) => const NoTransitionPage(child: HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 3: 替换 main.dart**

替换 `frontend/app/lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CheckManApp()));
}

class CheckManApp extends ConsumerStatefulWidget {
  const CheckManApp({super.key});

  @override
  ConsumerState<CheckManApp> createState() => _CheckManAppState();
}

class _CheckManAppState extends ConsumerState<CheckManApp> {
  @override
  void initState() {
    super.initState();
    ApiClient().onForceLogout = () => ref.read(authProvider.notifier).logout();
    Future.microtask(() => ref.read(authProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.status == AuthStatus.initial) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = createRouter(ref);

    return MaterialApp.router(
      title: 'CheckMan',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/core/router frontend/app/lib/shared/widgets/app_shell.dart frontend/app/lib/main.dart
git commit -m "feat: add router with status-based redirects and app shell

- GoRouter with auth guard and status routing
- AppShell with 3-tab GlassBottomNav
- main.dart with Riverpod + theme + auth init"
```

---

## Task 8: 认证页面（登录 + 注册 + 改密码）

**Files:**
- Create: `frontend/app/lib/features/auth/presentation/login_screen.dart`
- Create: `frontend/app/lib/features/auth/presentation/register_screen.dart`
- Create: `frontend/app/lib/features/auth/presentation/change_password_screen.dart`

- [ ] **Step 1: 创建登录页**

参照 `flutter_check/.../auth/presentation/login_screen.dart` 的 UI 布局，创建 `frontend/app/lib/features/auth/presentation/login_screen.dart`。

关键改动点：
- 品牌名改为 `CheckMan`（不是 ENDPAGE）
- 按钮文字改为 `登录`（不是"激活账户"）
- 添加底部「没有账号？立即注册」链接，`context.push('/register')`
- `_handleLogin` 调用 `ref.read(authProvider.notifier).login(username, password)`

完整实现参照 flutter_check 的 login_screen.dart，适配上述改动。

- [ ] **Step 2: 创建注册页**

创建 `frontend/app/lib/features/auth/presentation/register_screen.dart`。

布局参照登录页风格（背景光晕 + 白色卡片），表单字段：
- 姓名（BotanicalInput）
- 用户名（BotanicalInput）
- 密码（BotanicalInput，obscureText）
- 人脸拍照按钮（点击打开前置相机，用 `camera` 包，拍照后显示预览）
- 提交按钮：调用 `ref.read(authProvider.notifier).register(...)`

注意：注册接口需要 `face_image` 作为 multipart，所以要用 `camera` 包拍照获取 bytes。

- [ ] **Step 3: 创建改密码页**

从 flutter_check 复制 `change_password_screen.dart`，修改：
- 品牌名改为 `CheckMan`
- import 路径改为 `package:checkman_app/...`

逻辑基本不变：强制模式改密后跳 `/face-enrollment`（如果 face 未注册）或 `/home`。

- [ ] **Step 4: 验证编译**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter analyze lib/features/auth/presentation/
```

- [ ] **Step 5: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/auth/presentation
git commit -m "feat: add login, register, and change password screens

- Login with Botanical Ledger design
- Register with camera face capture (multipart upload)
- Change password (forced + voluntary modes)"
```

---

## Task 9: Onboarding 页面（待审核 + 已拒绝 + 人脸录入）

**Files:**
- Create: `frontend/app/lib/features/onboarding/presentation/pending_screen.dart`
- Create: `frontend/app/lib/features/onboarding/presentation/rejected_screen.dart`
- Create: `frontend/app/lib/features/onboarding/presentation/face_enrollment_screen.dart`

- [ ] **Step 1: 创建待审核页**

创建 `frontend/app/lib/features/onboarding/presentation/pending_screen.dart`：

全屏状态页，黄色氛围光，显示：
- 时钟/等待图标
- "账户审核中" 标题
- "您的注册申请正在等待管理员审核" 副标题
- 退出登录按钮
- 刷新按钮（调用 `ref.read(authProvider.notifier).refreshUser()`，审核通过后自动跳转）

参照 flutter_check 的 onboarding_flow_screen.dart 的背景光晕风格。

- [ ] **Step 2: 创建已拒绝页**

创建 `frontend/app/lib/features/onboarding/presentation/rejected_screen.dart`：

全屏状态页，红色氛围光，显示：
- 错误图标
- "注册被拒绝" 标题
- "重新注册" 按钮：先登出，然后跳转 `/register`
- 退出登录按钮

- [ ] **Step 3: 创建人脸录入页**

参照 flutter_check 的 `face_enrollment_screen.dart`，创建 `frontend/app/lib/features/onboarding/presentation/face_enrollment_screen.dart`。

关键改动：
- **只用前置相机**（不提供相册选择）：使用 `camera` 包直接打开前置相机取景
- 拍照后调用 `ref.read(authProvider.notifier).registerFace(bytes)`
- 成功后用户状态自动刷新，路由守卫跳转到 `/home`
- 人脸图片通过 multipart 上传（不是 base64）

- [ ] **Step 4: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/onboarding
git commit -m "feat: add onboarding screens (pending, rejected, face enrollment)

- Pending screen with refresh to check approval status
- Rejected screen with re-register option
- Face enrollment with front camera only (multipart upload)"
```

---

## Task 10: 打卡主页 + 相机页

**Files:**
- Create: `frontend/app/lib/features/check_in/presentation/check_in_screen.dart`
- Create: `frontend/app/lib/features/check_in/presentation/camera_screen.dart`

- [ ] **Step 1: 创建打卡主页**

参照 flutter_check 的 `check_in_screen.dart` 布局，创建 `frontend/app/lib/features/check_in/presentation/check_in_screen.dart`。

关键改动：
- 品牌名改为 `CheckMan`
- 使用 `ref.watch(checkProvider)` 获取今日打卡状态
- `initState` 中调用 `ref.read(checkProvider.notifier).fetchToday()`
- 点击签到/签退按钮时：
  1. 读取 `ref.read(authProvider).user` 获取 `requireFace` / `requireLocation`
  2. 如果 `requireFace`：`Navigator.push` 到 `CameraScreen`，获取返回的 bytes
  3. 如果 `requireLocation`：同时用 `Geolocator.getCurrentPosition()` 获取 GPS
  4. 调用 `ref.read(checkProvider.notifier).performCheck(...)` 提交
- 打卡结果直接在主页下方显示（复用 flutter_check 的结果卡片 UI）

- [ ] **Step 2: 创建全屏相机页**

创建 `frontend/app/lib/features/check_in/presentation/camera_screen.dart`：

使用 `camera` 包实现全屏前置相机取景界面：
- 初始化 `CameraController`（前置摄像头，`ResolutionPreset.medium`）
- 全屏显示 `CameraPreview`
- 覆盖扫描线动画（sweep 动画，参照 UI-DESIGN-SPEC.md）
- 圆形引导框（人脸放置区域）
- 底部拍照按钮，点击后 `controller.takePicture()`，将 bytes 通过 `Navigator.pop(context, bytes)` 返回
- 左上角返回按钮取消

```dart
// 核心结构
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _controller!.takePicture();
    final bytes = await file.readAsBytes();
    if (mounted) Navigator.pop(context, bytes);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 全屏 CameraPreview + 扫描线动画 + 拍照按钮
    // ...
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/check_in/presentation
git commit -m "feat: add check-in screen and camera screen

- Check-in home with hero clock card, smart check requirements
- Full-screen front camera with scan line animation
- Multipart face image submission"
```

---

## Task 11: 历史记录页

**Files:**
- Create: `frontend/app/lib/features/history/presentation/history_screen.dart`

- [ ] **Step 1: 创建历史记录页**

参照 flutter_check 的 `history_screen.dart` 布局，创建 `frontend/app/lib/features/history/presentation/history_screen.dart`。

关键改动：
- 品牌名改为 `CheckMan`
- 数据源改用 `CheckRepository().getHistory()` 返回 `List<CheckRecord>`
- `CheckRecord` 模型不同：有 `checkType`（clock_in/clock_out）而非 `checkInTime/checkOutTime`
- 按日期分组时，每天可能有多条记录（多次 clock_in/clock_out）
- 记录卡片显示：签到/签退时间分别从对应的 `CheckRecord` 获取
- 统计计算：从 clock_in 到 clock_out 的时间差计算工时

- [ ] **Step 2: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/history
git commit -m "feat: add history screen with date picker and stats

- Weekly stats card with total hours and progress bar
- Horizontal date selector
- Daily record cards with clock_in/clock_out times"
```

---

## Task 12: 个人中心页

**Files:**
- Create: `frontend/app/lib/features/profile/presentation/profile_screen.dart`

- [ ] **Step 1: 创建个人中心页**

参照 flutter_check 的 `profile_screen.dart` 布局，创建 `frontend/app/lib/features/profile/presentation/profile_screen.dart`。

关键改动：
- 品牌名改为 `CheckMan`
- 用户数据从 `ref.watch(authProvider).user`（类型 `EmployeeMe`）获取
- `user.name` 代替 `user.fullName`
- 删除"角色"显示（员工端不需要）
- 系统设置：修改密码 → `context.push('/change-password')`
- 系统设置：人脸重录 → `context.push('/face-enrollment')`
- 退出登录 → `ref.read(authProvider.notifier).logout()`

- [ ] **Step 2: Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app/lib/features/profile
git commit -m "feat: add profile screen with account info and settings

- Avatar, name, stats display
- Change password and re-enroll face options
- Logout with confirmation dialog"
```

---

## Task 13: 集成验证 + 最终检查

**Files:**
- Modify: various (fix any remaining issues)

- [ ] **Step 1: 编译验证**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter analyze
flutter build ios --no-codesign
flutter build apk --debug
```

所有命令应无 error 通过。

- [ ] **Step 2: 确保后端运行**

```bash
cd /Users/xbang/code/VScode/CheckMan/backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- [ ] **Step 3: 模拟器/真机测试**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter run
```

验证以下流程：
1. 启动 → 显示登录页
2. 点击注册 → 填写信息 + 拍照 → 提交 → 跳转待审核页
3. 后端审核通过后，刷新 → 跳转主页
4. 打卡签到 → 相机拍照 → 提交 → 显示结果
5. 切换到历史 tab → 查看记录
6. 切换到个人 tab → 修改密码 / 人脸重录
7. 退出登录 → 回到登录页

- [ ] **Step 4: iOS 真机安装验证**

```bash
cd /Users/xbang/code/VScode/CheckMan/frontend/app
flutter run --release
```

确认能成功安装到 iOS 真机（无 DEVELOPMENT_TEAM 硬编码问题）。

- [ ] **Step 5: 最终 Commit**

```bash
cd /Users/xbang/code/VScode/CheckMan
git add frontend/app
git commit -m "feat: complete CheckMan Flutter employee app

- All screens implemented and tested
- iOS/Android build verified
- Connects to CheckMan backend API"
```
