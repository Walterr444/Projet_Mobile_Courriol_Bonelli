import 'package:flutter/foundation.dart';
import 'package:rappels_app/services/history_service.dart';

/// Gère l'historique de scans de l'utilisateur.
class HistoryNotifier extends ChangeNotifier {
  List<Map<String, String>> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge l'historique depuis PocketBase.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await HistoryService.instance.getHistory();
    } catch (e) {
      _error = 'Impossible de charger l\'historique';
      debugPrint('HistoryNotifier.load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
