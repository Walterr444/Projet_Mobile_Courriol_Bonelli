import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rappels_app/models/product.dart';

/// Service pour récupérer les informations d'un produit
/// depuis l'API Open Food Facts via son code-barres (GTIN).
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();
  static ProductService get instance => _instance;

  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v3/product';

  /// Récupère un produit par son GTIN (code-barres EAN).
  /// Retourne null si le produit est introuvable ou si l'API échoue.
  Future<Product?> fetchProduct(String gtin) async {
    try {
      final uri = Uri.parse('$_baseUrl/$gtin.json?fields='
          'product_name,brands,nutriscore_grade,nova_group,'
          'image_url,ingredients_text,allergens_tags,additives_tags,'
          'nutriments,ecoscore_grade,quantity,countries,ingredients_analysis_tags');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'success') return null;

      final p = data['product'] as Map<String, dynamic>? ?? {};
      return Product.fromJson(gtin, p);
    } catch (e) {
      debugPrint('ProductService.fetchProduct error: $e');
      return null;
    }
  }
}
