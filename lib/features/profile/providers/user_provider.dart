import 'package:flutter/material.dart';
import 'package:golden_wallet/features/profile/models/user_model.dart';

/// Provider to manage user data
class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  /// Get the current user
  User? get user => _user;
  
  /// Check if the user is loading
  bool get isLoading => _isLoading;
  
  /// Get the error message
  String? get error => _error;
  
  /// Check if the user is logged in
  bool get isLoggedIn => _user != null;
  
  /// Set the current user
  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }
  
  /// Clear the current user
  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }
  
  /// Set the error message
  void setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  /// Clear the error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Fetch the user data
  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      _user = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+971 50 123 4567',
        profileImageUrl: null,
        role: 'customer',
        status: UserStatus.active,
        preferences: const UserPreferences(
          notificationsEnabled: true,
          emailNotificationsEnabled: true,
          pushNotificationsEnabled: true,
          smsNotificationsEnabled: false,
          biometricAuthEnabled: true,
        ),
        address: const UserAddress(
          street: '123 Gold Street',
          city: 'Dubai',
          state: 'Dubai',
          country: 'United Arab Emirates',
          postalCode: '12345',
        ),
        kyc: const UserKYC(
          idType: 'Passport',
          idNumber: 'AB123456',
          idFrontImageUrl: 'https://example.com/id_front.jpg',
          idBackImageUrl: 'https://example.com/id_back.jpg',
          isVerified: true,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Update the user data
  Future<bool> updateUser({
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user data
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Update the user address
  Future<bool> updateAddress({
    required String street,
    required String city,
    required String state,
    required String country,
    required String postalCode,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user address
      final updatedAddress = UserAddress(
        street: street,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
      );
      
      _user = _user!.copyWith(address: updatedAddress);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Update the user preferences
  Future<bool> updatePreferences({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? biometricAuthEnabled,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user preferences
      final updatedPreferences = _user!.preferences.copyWith(
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        pushNotificationsEnabled: pushNotificationsEnabled,
        smsNotificationsEnabled: smsNotificationsEnabled,
        biometricAuthEnabled: biometricAuthEnabled,
      );
      
      _user = _user!.copyWith(preferences: updatedPreferences);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
