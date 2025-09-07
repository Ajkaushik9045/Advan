// lib/features/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../../../core/network/api_client.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final api = Provider.of<ApiClient>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final res = await api.post(
                    '/api/auth/login',
                    data: {
                      'email': 'enduser@example.com',
                      'password': 'password123',
                    },
                  );
                  final token = res.data['token'] as String?;
                  await auth.loginAs(UserRole.endUser, token: token);
                  Navigator.pushReplacementNamed(context, '/user');
                } catch (_) {
                  await auth.loginAs(UserRole.endUser); // fallback dummy
                  Navigator.pushReplacementNamed(context, '/user');
                }
              },
              child: const Text('Login as End User'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  final res = await api.post(
                    '/api/auth/login',
                    data: {
                      'email': 'receiver@example.com',
                      'password': 'password123',
                    },
                  );
                  final token = res.data['token'] as String?;
                  await auth.loginAs(UserRole.receiver, token: token);
                  Navigator.pushReplacementNamed(context, '/receiver');
                } catch (_) {
                  await auth.loginAs(UserRole.receiver); // fallback dummy
                  Navigator.pushReplacementNamed(context, '/receiver');
                }
              },
              child: const Text('Login as Receiver'),
            ),
          ],
        ),
      ),
    );
  }
}
