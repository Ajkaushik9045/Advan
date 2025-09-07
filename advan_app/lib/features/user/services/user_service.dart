// lib/features/user/services/user_service.dart
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient apiClient;

  UserService({required this.apiClient});

  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }

  Future<User> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final payload = {'email': email, 'password': password, 'role': role.name};

      final response = await apiClient.post('/auth/login', data: payload);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
