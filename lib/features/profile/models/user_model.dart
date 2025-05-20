import 'package:flutter/material.dart';

/// User model representing a user in the application
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final String role;
  final UserStatus status;
  final UserPreferences preferences;
  final UserAddress? address;
  final UserKYC? kyc;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.preferences,
    this.address,
    this.kyc,
    required this.createdAt,
    this.lastLoginAt,
  });
  
  /// Create a copy of this user with the given fields replaced with the new values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? role,
    UserStatus? status,
    UserPreferences? preferences,
    UserAddress? address,
    UserKYC? kyc,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      address: address ?? this.address,
      kyc: kyc ?? this.kyc,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  /// Create a user from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      address: json['address'] != null
          ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      kyc: json['kyc'] != null
          ? UserKYC.fromJson(json['kyc'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }
  
  /// Convert this user to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'role': role,
      'status': status.toString().split('.').last,
      'preferences': preferences.toJson(),
      'address': address?.toJson(),
      'kyc': kyc?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

/// Enum representing different user statuses
enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
}

/// Extension to provide additional functionality to UserStatus enum
extension UserStatusExtension on UserStatus {
  String get translationKey {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.pending:
        return 'pending';
    }
  }
  
  Color get color {
    switch (this) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.grey;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.pending:
        return Colors.orange;
    }
  }
}

/// User preferences model
class UserPreferences {
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool biometricAuthEnabled;
  
  const UserPreferences({
    required this.notificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.biometricAuthEnabled,
  });
  
  /// Create a copy of this preferences with the given fields replaced with the new values
  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? biometricAuthEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
    );
  }
  
  /// Create preferences from a JSON object
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] as bool,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool,
      smsNotificationsEnabled: json['sms_notifications_enabled'] as bool,
      biometricAuthEnabled: json['biometric_auth_enabled'] as bool,
    );
  }
  
  /// Convert these preferences to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'push_notifications_enabled': pushNotificationsEnabled,
      'sms_notifications_enabled': smsNotificationsEnabled,
      'biometric_auth_enabled': biometricAuthEnabled,
    };
  }
}

/// User address model
class UserAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  
  const UserAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });
  
  /// Create a copy of this address with the given fields replaced with the new values
  UserAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    return UserAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }
  
  /// Create an address from a JSON object
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String,
    );
  }
  
  /// Convert this address to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
    };
  }
}

/// User KYC (Know Your Customer) model
class UserKYC {
  final String idType;
  final String idNumber;
  final String idFrontImageUrl;
  final String idBackImageUrl;
  final bool isVerified;
  final DateTime? verifiedAt;
  
  const UserKYC({
    required this.idType,
    required this.idNumber,
    required this.idFrontImageUrl,
    required this.idBackImageUrl,
    required this.isVerified,
    this.verifiedAt,
  });
  
  /// Create a copy of this KYC with the given fields replaced with the new values
  UserKYC copyWith({
    String? idType,
    String? idNumber,
    String? idFrontImageUrl,
    String? idBackImageUrl,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return UserKYC(
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      idFrontImageUrl: idFrontImageUrl ?? this.idFrontImageUrl,
      idBackImageUrl: idBackImageUrl ?? this.idBackImageUrl,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
  
  /// Create a KYC from a JSON object
  factory UserKYC.fromJson(Map<String, dynamic> json) {
    return UserKYC(
      idType: json['id_type'] as String,
      idNumber: json['id_number'] as String,
      idFrontImageUrl: json['id_front_image_url'] as String,
      idBackImageUrl: json['id_back_image_url'] as String,
      isVerified: json['is_verified'] as bool,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }
  
  /// Convert this KYC to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id_type': idType,
      'id_number': idNumber,
      'id_front_image_url': idFrontImageUrl,
      'id_back_image_url': idBackImageUrl,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}
