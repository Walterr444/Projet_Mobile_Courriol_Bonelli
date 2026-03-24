import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/notifiers/auth_notifier.dart';
import 'package:rappels_app/notifiers/favorites_notifier.dart';
import 'package:rappels_app/notifiers/history_notifier.dart';
import 'package:rappels_app/pages/home_page.dart';
import 'package:rappels_app/pages/login_page.dart';
import 'package:rappels_app/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => HistoryNotifier()),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier()),
      ],
      child: MaterialApp(
        title: 'Mes Scans',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          useMaterial3: true,
        ),
        // Navigation initiale selon l'état de connexion
        home: AuthService.instance.isLoggedIn
            ? const HomePage()
            : const LoginPage(),
      ),
    );
  }
}
