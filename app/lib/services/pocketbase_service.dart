import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

/// Service singleton pour accéder à PocketBase.
class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  static PocketBaseService get instance => _instance;

  // Détection dynamique de l'URL :
  // - Web ou Desktop : localhost (127.0.0.1)
  // - Émulateur Android : 10.0.2.2
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8090';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8090'
        : 'http://127.0.0.1:8090';
  }

  final PocketBase pb = PocketBase(_baseUrl);
}
