// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/network/api_client.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/requests/provider/request_provider.dart';
import 'config/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env from project root
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file doesn't exist, use defaults
    print('Warning: .env file not found, using default configuration');
  }

  // Default to Android emulator host if not provided
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  final wsUrl = dotenv.env['WS_URL'] ?? 'ws://10.0.2.2:3000';

  final apiClient = ApiClient(baseUrl: baseUrl);

  runApp(RequestHandlingApp(apiClient: apiClient, wsUrl: wsUrl));
}

class RequestHandlingApp extends StatelessWidget {
  final ApiClient apiClient;
  final String wsUrl;
  const RequestHandlingApp({
    super.key,
    required this.apiClient,
    required this.wsUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(apiClient: apiClient, wsUrl: wsUrl),
        ),
      ],
      child: MaterialApp(
        title: 'Request Handling App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
