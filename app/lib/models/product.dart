/// Modèle de données représentant un produit alimentaire
/// récupéré depuis l'API Open Food Facts.
class Product {
  final String gtin;
  final String name;
  final String brand;
  final String nutriscoreGrade; // 'a', 'b', 'c', 'd', 'e' ou ''
  final int novaGroup;           // 1, 2, 3 ou 4 (0 = inconnu)
  final String ecoscoreGrade;    // 'a', 'b', 'c', 'd', 'e' ou ''
  final String imageUrl;
  final String ingredientsText;
  final List<String> allergens;  // ex: ['en:milk', 'en:gluten']
  final List<String> additives;  // ex: ['en:e471']
  final List<String> ingredientsAnalysisTags; // ex: ['en:vegan', 'en:non-vegetarian']
  final String quantity;
  final String countries;
  final Map<String, dynamic> nutriments;

  const Product({
    required this.gtin,
    required this.name,
    required this.brand,
    required this.nutriscoreGrade,
    required this.novaGroup,
    required this.ecoscoreGrade,
    required this.imageUrl,
    required this.ingredientsText,
    required this.allergens,
    required this.additives,
    required this.ingredientsAnalysisTags,
    required this.quantity,
    required this.countries,
    required this.nutriments,
  });

  /// Crée un Product depuis le JSON d'Open Food Facts.
  factory Product.fromJson(String gtin, Map<String, dynamic> json) {
    return Product(
      gtin: gtin,
      name: json['product_name'] as String? ?? '',
      brand: json['brands'] as String? ?? '',
      nutriscoreGrade: (json['nutriscore_grade'] as String? ?? '').toLowerCase(),
      novaGroup: (json['nova_group'] as num?)?.toInt() ?? 0,
      ecoscoreGrade: (json['ecoscore_grade'] as String? ?? '').toLowerCase(),
      imageUrl: json['image_url'] as String? ?? '',
      ingredientsText: json['ingredients_text'] as String? ?? '',
      allergens: _toStringList(json['allergens_tags']),
      additives: _toStringList(json['additives_tags']),
      ingredientsAnalysisTags: _toStringList(json['ingredients_analysis_tags']),
      quantity: json['quantity'] as String? ?? '',
      countries: json['countries'] as String? ?? '',
      nutriments: json['nutriments'] as Map<String, dynamic>? ?? {},
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  // ── Helpers nutriments ──────────────────────────────────

  double _getNutriment(String key) {
    final v = nutriments['${key}_100g'] ?? nutriments[key];
    if (v is num) return v.toDouble();
    return 0.0;
  }

  double get energy100g        => _getNutriment('energy-kcal');
  double get fat100g           => _getNutriment('fat');
  double get saturatedFat100g  => _getNutriment('saturated-fat');
  double get sugars100g        => _getNutriment('sugars');
  double get salt100g          => _getNutriment('salt');
  double get fiber100g         => _getNutriment('fiber');
  double get proteins100g      => _getNutriment('proteins');
  double get carbohydrates100g => _getNutriment('carbohydrates');
  double get sodium100g        => _getNutriment('sodium');
}
