// lib/config/app_router.dart
import 'package:flutter/material.dart';
import '../features/auth/pages/login_page.dart';
import '../features/user/pages/user_home_page.dart';
import '../features/receiver/pages/receiver_home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/user':
        return MaterialPageRoute(builder: (_) => const UserHomePage());
      case '/receiver':
        return MaterialPageRoute(builder: (_) => const ReceiverHomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404'))),
        );
    }
  }
}
