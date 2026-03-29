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
