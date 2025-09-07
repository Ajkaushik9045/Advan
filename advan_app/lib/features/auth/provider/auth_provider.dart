// lib/features/auth/provider/auth_provider.dart
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

enum UserRole { endUser, receiver }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  String? _token;
  UserRole? _role;

  AuthProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  String? get token => _token;
  UserRole? get role => _role;
  bool get isLoggedIn => _token != null;

  // In real app replace with API call and persist token via shared_preferences
  Future<void> loginAs(UserRole role, {String? token}) async {
    _role = role;
    _token = token ?? 'dummy-token';
    _apiClient.setAuthToken(_token);
    notifyListeners();
  }

  void logout() {
    _token = null;
    _role = null;
    _apiClient.setAuthToken(null);
    notifyListeners();
  }
}
