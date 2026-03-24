import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

/// Service d'authentification via PocketBase.
/// Gère la connexion, l'inscription et la déconnexion.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  static AuthService get instance => _instance;

  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8090';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8090'
        : 'http://127.0.0.1:8090';
  }

  final PocketBase pb = PocketBase(_baseUrl);

  /// Retourne true si l'utilisateur est actuellement connecté.
  bool get isLoggedIn => pb.authStore.isValid;

  /// Retourne le modèle de l'utilisateur connecté.
  RecordModel? get currentUser =>
      pb.authStore.record;

  /// Connexion avec email et mot de passe.
  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  /// Inscription d'un nouvel utilisateur.
  Future<void> register(String email, String password) async {
    await pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
    });
    // Connexion automatique après inscription
    await login(email, password);
  }

  /// Déconnexion.
  void logout() {
    pb.authStore.clear();
  }
}
