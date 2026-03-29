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
