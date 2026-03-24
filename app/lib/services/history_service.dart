import 'package:rappels_app/models/product.dart';
import 'package:rappels_app/services/auth_service.dart';

/// Service pour gérer l'historique de scans de l'utilisateur.
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();
  static HistoryService get instance => _instance;

  final _pb = AuthService.instance.pb;

  /// Ajoute un produit à l'historique.
  /// Chaque scan crée une nouvelle entrée (l'historique peut avoir des doublons).
  Future<void> addToHistory(Product product) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;

    // Remove existing entry if it already exists to avoid duplicates
    // and bump it to the top (since it will be created anew).
    try {
      final existing = await _pb.collection('history').getList(
        filter: 'gtin = "${product.gtin}" && user = "$userId"',
        perPage: 1,
      );
      if (existing.items.isNotEmpty) {
        await _pb.collection('history').delete(existing.items.first.id);
      }
    } catch (_) {
      // Ignore errors related to fetching/deleting existing items
    }

    await _pb.collection('history').create(body: {
      'user': userId,
      'gtin': product.gtin,
      'product_name': product.name,
      'brand': product.brand,
      'nutriscore': product.nutriscoreGrade,
      'image_url': product.imageUrl,
    });
  }

  /// Récupère l'historique de l'utilisateur (ordre décroissant = le plus récent en premier).
  Future<List<Map<String, String>>> getHistory() async {
    final result = await _pb.collection('history').getList(
      perPage: 100,
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
