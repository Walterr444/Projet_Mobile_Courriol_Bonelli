import 'package:flutter/foundation.dart';
import 'package:rappels_app/services/auth_service.dart';

/// Gère l'état d'authentification de l'utilisateur.
class AuthNotifier extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => AuthService.instance.isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Connexion avec email + mot de passe.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.instance.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription puis connexion automatique.
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.instance.register(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion.
  void logout() {
    AuthService.instance.logout();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed to authenticate')) {
      return 'Email ou mot de passe incorrect';
    }
    if (msg.contains('already exists')) {
      return 'Un compte avec cet email existe déjà';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Impossible de contacter le serveur';
    }
    return 'Une erreur est survenue';
  }
}
