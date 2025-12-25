class LoginRecord {
  final String id;
  final String odaId;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final String loginType; // 'biometric', 'sms', 'second_party'
  final String? deviceInfo;
  
  LoginRecord({
    required this.id,
    required this.odaId,
    required this.loginTime,
    this.logoutTime,
    required this.loginType,
    this.deviceInfo,
  });
  
  factory LoginRecord.fromJson(Map<String, dynamic> json) {
    return LoginRecord(
      id: json['id'] ?? '',
      odaId: json['user_id'] ?? '',
      loginTime: DateTime.parse(json['login_time'] ?? DateTime.now().toIso8601String()),
      logoutTime: json['logout_time'] != null ? DateTime.parse(json['logout_time']) : null,
      loginType: json['login_type'] ?? 'biometric',
      deviceInfo: json['device_info'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': odaId,
      'login_time': loginTime.toIso8601String(),
      'logout_time': logoutTime?.toIso8601String(),
      'login_type': loginType,
      'device_info': deviceInfo,
    };
  }
}

class SecondPartyUser {
  final String id;
  final String lawyerId;
  final String fullName;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  
  SecondPartyUser({
    required this.id,
    required this.lawyerId,
    required this.fullName,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
  });
  
  factory SecondPartyUser.fromJson(Map<String, dynamic> json) {
    return SecondPartyUser(
      id: json['id'] ?? '',
      lawyerId: json['lawyer_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lawyer_id': lawyerId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
