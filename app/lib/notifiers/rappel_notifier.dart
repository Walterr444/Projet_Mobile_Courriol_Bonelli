import 'package:flutter/foundation.dart';
import 'package:rappels_app/models/rappel.dart';
import 'package:rappels_app/services/auth_service.dart';

/// ChangeNotifier qui vérifie si un produit (via son GTIN/code-barres)
/// a un rappel en cours dans PocketBase.
///
/// Utilisation : injecter ce notifier et appeler checkRappel(gtin)
/// L'UI se met à jour automatiquement lorsque hasRappel change.
class RappelNotifier extends ChangeNotifier {
  final _pb = AuthService.instance.pb;

  bool _isLoading = false;
  bool _hasRappel = false;
  Rappel? _rappel;
  String? _error;

  // Getters exposés à l'UI
  bool get isLoading => _isLoading;
  bool get hasRappel => _hasRappel;
  Rappel? get rappel => _rappel;
  String? get error => _error;

  /// Vérifie si le GTIN donné correspond à un rappel dans PocketBase
  Future<void> checkRappel(String gtin) async {
    _isLoading = true;
    _hasRappel = false;
    _rappel = null;
    _error = null;
    notifyListeners();

    try {
      final result = await _pb
          .collection('rappels')
          .getList(filter: 'gtin = "$gtin"', perPage: 1);

      if (result.items.isNotEmpty) {
        _hasRappel = true;
        _rappel = Rappel.fromRecord(result.items.first);
      } else {
        _hasRappel = false;
      }
    } catch (e) {
      _error = e.toString();
      _hasRappel = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remet à zéro l'état (quand on change de produit)
  void reset() {
    _isLoading = false;
    _hasRappel = false;
    _rappel = null;
    _error = null;
    notifyListeners();
  }
}
