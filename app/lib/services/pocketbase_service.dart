import 'package:pocketbase/pocketbase.dart';

/// Service singleton pour accéder à PocketBase.
/// Toute l'app utilise la même instance via PocketBaseService.instance
class PocketBaseService {
  // Singleton : une seule instance dans toute l'app
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  static PocketBaseService get instance => _instance;

  // Adresse de PocketBase (ton serveur local)
  // ⚠️ Sur émulateur Android, utilise 10.0.2.2 à la place de 127.0.0.1
  final PocketBase pb = PocketBase('http://10.0.2.2:8090');
}
