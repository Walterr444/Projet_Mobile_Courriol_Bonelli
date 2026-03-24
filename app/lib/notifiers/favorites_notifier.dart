import 'package:flutter/foundation.dart';
import 'package:rappels_app/models/product.dart';
import 'package:rappels_app/services/favorites_service.dart';

/// Gère les favoris de l'utilisateur.
class FavoritesNotifier extends ChangeNotifier {
  List<Map<String, String>> _items = [];
  bool _isLoading = false;
  String? _error;

  // Cache local des GTIN en favoris pour un toggle rapide
  final Set<String> _favoriteGtins = {};

  List<Map<String, String>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vérifie si un GTIN est en favori (cache local).
  bool isFavorite(String gtin) => _favoriteGtins.contains(gtin);

  /// Charge les favoris depuis PocketBase et met à jour le cache.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await FavoritesService.instance.getFavorites();
      _favoriteGtins
        ..clear()
        ..addAll(_items.map((e) => e['gtin'] ?? ''));
    } catch (e) {
      _error = 'Impossible de charger les favoris';
      debugPrint('FavoritesNotifier.load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute ou retire un produit des favoris.
  Future<void> toggle(Product product) async {
    final gtin = product.gtin;
    try {
      if (_favoriteGtins.contains(gtin)) {
        await FavoritesService.instance.removeFavorite(gtin);
        _favoriteGtins.remove(gtin);
        _items.removeWhere((e) => e['gtin'] == gtin);
      } else {
        await FavoritesService.instance.addFavorite(product);
        _favoriteGtins.add(gtin);
        _items.insert(0, {
          'gtin':         product.gtin,
          'product_name': product.name,
          'brand':        product.brand,
          'nutriscore':   product.nutriscoreGrade,
          'image_url':    product.imageUrl,
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('FavoritesNotifier.toggle error: $e');
    }
  }
}
