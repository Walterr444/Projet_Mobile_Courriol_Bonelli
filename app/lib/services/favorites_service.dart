import 'package:rappels_app/models/product.dart';
import 'package:rappels_app/services/auth_service.dart';

/// Service pour gérer les favoris de l'utilisateur.
/// Garantit l'absence de doublons (un seul favori par GTIN).
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();
  static FavoritesService get instance => _instance;

  final _pb = AuthService.instance.pb;

  /// Vérifie si un produit est déjà en favori.
  Future<bool> isFavorite(String gtin) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return false;

    final result = await _pb.collection('favorites').getList(
      filter: 'gtin = "$gtin" && user = "$userId"',
      perPage: 1,
    );
    return result.items.isNotEmpty;
  }

  /// Ajoute un produit aux favoris (si pas déjà présent).
  Future<void> addFavorite(Product product) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;

    final alreadyFav = await isFavorite(product.gtin);
    if (alreadyFav) return;

    await _pb.collection('favorites').create(body: {
      'user':         userId,
      'gtin':         product.gtin,
      'product_name': product.name,
      'brand':        product.brand,
      'nutriscore':   product.nutriscoreGrade,
      'image_url':    product.imageUrl,
    });
  }

  /// Retire un produit des favoris.
  Future<void> removeFavorite(String gtin) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;

    final result = await _pb.collection('favorites').getList(
      filter: 'gtin = "$gtin" && user = "$userId"',
      perPage: 1,
    );
    if (result.items.isEmpty) return;

    await _pb.collection('favorites').delete(result.items.first.id);
  }

  /// Récupère tous les favoris de l'utilisateur.
  Future<List<Map<String, String>>> getFavorites() async {
    final result = await _pb.collection('favorites').getList(
      perPage: 200,
    );

    return result.items.map((r) => {
      'id':           r.id,
      'gtin':         r.getStringValue('gtin'),
      'product_name': r.getStringValue('product_name'),
      'brand':        r.getStringValue('brand'),
      'nutriscore':   r.getStringValue('nutriscore'),
      'image_url':    r.getStringValue('image_url'),
    }).toList();
  }
}
