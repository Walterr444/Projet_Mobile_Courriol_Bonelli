import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/models/product.dart';
import 'package:rappels_app/notifiers/favorites_notifier.dart';
import 'package:rappels_app/services/history_service.dart';
import 'package:rappels_app/services/product_service.dart';

const Color _kPrimary = Color(0xFF2D3091);

/// Fiche produit complète avec 4 onglets selon la maquette.
class ProductPage extends StatefulWidget {
  final String gtin;
  const ProductPage({super.key, required this.gtin});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentTab = 0;
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ProductService.instance.fetchProduct(widget.gtin);
      if (!mounted) return;

      setState(() {
        _product = product;
        _isLoading = false;
        _error =
            product == null ? 'Produit introuvable sur Open Food Facts' : null;
      });

      if (product != null) {
        try {
          await HistoryService.instance.addToHistory(product);
        } catch (e) {
          debugPrint('History save error: $e');
        }
        if (mounted) {
          await context.read<FavoritesNotifier>().load();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger le produit';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: _ErrorBody(
            error: _error ?? 'Erreur inconnue', onRetry: _loadProduct),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── AppBar avec image en parallax ─────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Consumer<FavoritesNotifier>(
                  builder: (context, favs, _) {
                    final isFav = favs.isFavorite(widget.gtin);
                    return _CircleIconButton(
                      icon: isFav ? Icons.star : Icons.star_border,
                      onPressed: () => favs.toggle(_product!),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image plein format
                  CachedNetworkImage(
                    imageUrl: _product!.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey[200]),
                  ),
                  // Gradient en haut pour les icônes
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bordure blanche arrondie qui chevauche l'image
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Container(
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
          ),

          // ── Contenu scrollable ────────────────────────
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    260 -
                    kBottomNavigationBarHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête permanent : titre + marque
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product!.name.isNotEmpty
                              ? _product!.name
                              : 'Nom inconnu',
                          style: const TextStyle(
                            color: _kPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _product!.brand.isNotEmpty
                              ? _product!.brand
                              : 'Marque inconnue',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Contenu de l'onglet actif
                  _buildTabContent(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Navigation Bar ─────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        selectedItemColor: _kPrimary,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (i) => setState(() => _currentTab = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Fiche'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Caractéristiques'),
          BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined), label: 'Nutrition'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_on_outlined), label: 'Tableau'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _FicheTab(product: _product!);
      case 1:
        return _CaracteristiquesTab(product: _product!);
      case 2:
        return _NutritionTab(product: _product!);
      case 3:
        return _TableauTab(product: _product!);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Bouton rond transparent (AppBar) ─────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ── ONGLET 1 : FICHE ─────────────────────────────────────
// ════════════════════════════════════════════════════════════
class _FicheTab extends StatelessWidget {
  final Product product;
  const _FicheTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description générique du produit (si présente)
        if (product.name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              product.name,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),

        // ── Bloc Nutri-Score + NOVA ──────────────────────
        _GreySection(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nutri-Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nutri-Score',
                      style: TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FullNutriscoreBadge(grade: product.nutriscoreGrade),
                  ],
                ),
              ),
              Container(
                  width: 1, height: 70, color: const Color(0xFFE0E0E0)),
              const SizedBox(width: 20),
              // NOVA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Groupe NOVA',
                      style: TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _novaText(product.novaGroup),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Bloc EcoScore ────────────────────────────────
        _GreySection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EcoScore',
                style: TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _EcoScoreLeaf(grade: product.ecoscoreGrade),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _ecoscoreText(product.ecoscoreGrade),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Quantité + Vendu ─────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _DetailRow(
                label: 'Quantité',
                value: product.quantity.isNotEmpty
                    ? product.quantity
                    : 'Non spécifié',
              ),
              const _Divider(),
              _DetailRow(
                label: 'Vendu',
                value: product.countries.isNotEmpty
                    ? product.countries
                    : 'France',
              ),
              const SizedBox(height: 24),
              // ── Pills Végétalien / Végétarien ─────────
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                        label: 'Végétalien', isTrue: _isVegan(product)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _PillButton(
                        label: 'Végétarien',
                        isTrue: _isVegetarian(product)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _novaText(int g) {
    switch (g) {
      case 1:
        return 'Aliments peu ou pas transformés';
      case 2:
        return 'Ingrédients culinaires transformés';
      case 3:
        return 'Aliments transformés';
      case 4:
        return 'Produits alimentaires et\nboissons ultra-transformés';
      default:
        return 'Inconnu';
    }
  }

  String _ecoscoreText(String g) {
    switch (g) {
      case 'a':
        return 'Très faible impact environnemental';
      case 'b':
        return 'Faible impact environnemental';
      case 'c':
        return 'Impact environnemental modéré';
      case 'd':
        return 'Impact environnemental élevé';
      case 'e':
        return 'Très fort impact environnemental';
      default:
        return 'Impact inconnu';
    }
  }

  bool _isVegan(Product p) =>
      p.ingredientsAnalysisTags.contains('en:vegan');
  bool _isVegetarian(Product p) =>
      p.ingredientsAnalysisTags.contains('en:vegetarian') || _isVegan(p);
}

// ════════════════════════════════════════════════════════════
// ── ONGLET 2 : CARACTÉRISTIQUES ──────────────────────────
// ════════════════════════════════════════════════════════════
class _CaracteristiquesTab extends StatelessWidget {
  final Product product;
  const _CaracteristiquesTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Ingrédients'),
        _buildIngredients(product.ingredientsText),
        _SectionHeader('Substances allergènes'),
        _buildTagList(product.allergens),
        _SectionHeader('Additifs'),
        _buildTagList(product.additives),
      ],
    );
  }

  /// Affiche les ingrédients en deux colonnes si on peut les parser (ex: "Eau, Sucre 10%")
  Widget _buildIngredients(String text) {
    if (text.isEmpty) {
      return _emptyText('Aucune information disponible.');
    }

    // On sépare par virgule et on tente de détecter un ":" ou "%" pour faire 2 colonnes
    final parts = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      children: [
        for (int i = 0; i < parts.length; i++) ...[
          _buildIngredientRow(parts[i], i),
          if (i < parts.length - 1) const _Divider(),
        ],
      ],
    );
  }

  Widget _buildIngredientRow(String part, int index) {
    // Tenter de séparer ingrédient et détail (ex: "Légumes : petits pois 41%")
    String label = part;
    String detail = '';

    final colonIdx = part.indexOf(':');
    if (colonIdx > 0 && colonIdx < part.length - 1) {
      label = part.substring(0, colonIdx).trim();
      detail = part.substring(colonIdx + 1).trim();
    }

    final isLabelBold = detail.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: _kPrimary,
                fontWeight:
                    isLabelBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (detail.isNotEmpty)
            Expanded(
              flex: 2,
              child: Text(
                detail,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagList(List<String> items) {
    if (items.isEmpty) {
      return _emptyText('Aucune');
    }
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _clean(items[i]),
                style: const TextStyle(
                  color: _kPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (i < items.length - 1) const _Divider(),
        ],
      ],
    );
  }

  Widget _emptyText(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(msg, style: const TextStyle(color: Colors.grey)),
      );

  String _clean(String tag) =>
      tag.replaceFirst(RegExp(r'^[a-z]{2}:'), '').replaceAll('-', ' ');
}

// ════════════════════════════════════════════════════════════
// ── ONGLET 3 : NUTRITION ─────────────────────────────────
// ════════════════════════════════════════════════════════════
class _NutritionTab extends StatelessWidget {
  final Product product;
  const _NutritionTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sous-titre centré gris italique
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                'Repères nutritionnels pour 100g',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // Lignes nutritionnelles avec séparateurs
          _NutritionRow(
            label: 'Matières grasses / lipides',
            value: '${product.fat100g.toStringAsFixed(1)}g',
            level: _fatLevel(product.fat100g),
          ),
          const _NutrDivider(),
          _NutritionRow(
            label: 'Acides gras saturés',
            value: '${product.saturatedFat100g.toStringAsFixed(1)}g',
            level: _satFatLevel(product.saturatedFat100g),
          ),
          const _NutrDivider(),
          _NutritionRow(
            label: 'Sucres',
            value: '${product.sugars100g.toStringAsFixed(1)}g',
            level: _sugarLevel(product.sugars100g),
          ),
          const _NutrDivider(),
          _NutritionRow(
            label: 'Sel',
            value: '${product.salt100g.toStringAsFixed(2)}g',
            level: _saltLevel(product.salt100g),
          ),
        ],
      ),
    );
  }

  _NutrLevel _fatLevel(double v) {
    if (v < 3) return _NutrLevel.low;
    if (v < 20) return _NutrLevel.medium;
    return _NutrLevel.high;
  }

  _NutrLevel _satFatLevel(double v) {
    if (v < 1.5) return _NutrLevel.low;
    if (v < 5) return _NutrLevel.medium;
    return _NutrLevel.high;
  }

  _NutrLevel _sugarLevel(double v) {
    if (v < 5) return _NutrLevel.low;
    if (v < 12.5) return _NutrLevel.medium;
    return _NutrLevel.high;
  }

  _NutrLevel _saltLevel(double v) {
    if (v < 0.3) return _NutrLevel.low;
    if (v < 1.5) return _NutrLevel.medium;
    return _NutrLevel.high;
  }
}

enum _NutrLevel { low, medium, high }

/// Séparateur spécifique à l'onglet Nutrition (avec marge horizontale)
class _NutrDivider extends StatelessWidget {
  const _NutrDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final _NutrLevel level;
  const _NutritionRow(
      {required this.label, required this.value, required this.level});

  Color get _color {
    switch (level) {
      case _NutrLevel.low:
        return const Color(0xFF038141); // vert
      case _NutrLevel.medium:
        return const Color(0xFFF5A623); // orange
      case _NutrLevel.high:
        return const Color(0xFFE63E11); // rouge
    }
  }

  String get _levelLabel {
    switch (level) {
      case _NutrLevel.low:
        return 'Faible quantité';
      case _NutrLevel.medium:
        return 'Quantité modérée';
      case _NutrLevel.high:
        return 'Quantité élevée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Généreux padding vertical pour aérer comme sur la maquette
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label : noir bold, grande taille
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A1A2E), // quasi noir
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Valeur + sous-label empilés à droite
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _levelLabel,
                style: TextStyle(
                  color: _color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ── ONGLET 4 : TABLEAU ───────────────────────────────────
// ════════════════════════════════════════════════════════════
class _TableauTab extends StatelessWidget {
  final Product product;
  const _TableauTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête colonnes
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: const [
              Expanded(child: SizedBox()),
              SizedBox(
                width: 90,
                child: Text(
                  'Pour 100g',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  'Par part',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const _Divider(),

        _TableRow(0, 'Énergie',
            '${product.energy100g.toStringAsFixed(0)} kj', '?',
            bold: true),
        _TableRow(1, 'Matières grasses',
            '${product.fat100g.toStringAsFixed(1)} g', '?',
            bold: true),
        _TableRow(2, 'dont Acides gras saturés',
            '${product.saturatedFat100g.toStringAsFixed(1)} g', '?'),
        _TableRow(3, 'Glucides',
            '${product.carbohydrates100g.toStringAsFixed(1)} g', '?',
            bold: true),
        _TableRow(4, 'dont Sucres',
            '${product.sugars100g.toStringAsFixed(1)} g', '?'),
        _TableRow(5, 'Fibres alimentaires',
            '${product.fiber100g.toStringAsFixed(1)} g', '?',
            bold: true),
        _TableRow(6, 'Protéines',
            '${product.proteins100g.toStringAsFixed(1)} g', '?',
            bold: true),
        _TableRow(
            7, 'Sel', '${product.salt100g.toStringAsFixed(2)}g', '?',
            bold: true),
        _TableRow(8, 'Sodium',
            '${product.sodium100g.toStringAsFixed(3)} g', '?',
            bold: true),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final int index;
  final String label;
  final String val100g;
  final String valPart;
  final bool bold;

  const _TableRow(this.index, this.label, this.val100g, this.valPart,
      {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final bg = index % 2 == 1 ? const Color(0xFFF8F8FC) : Colors.white;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _kPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              val100g,
              style: const TextStyle(color: _kPrimary, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              valPart,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ── COMPOSANTS PARTAGÉS ──────────────────────────────────
// ════════════════════════════════════════════════════════════

/// Section gris clair pour les infos de la fiche
class _GreySection extends StatelessWidget {
  final Widget child;
  const _GreySection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5FA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}

/// En-tête de section centré sur fond gris
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5FA),
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: _kPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Ligne séparateur léger
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
  }
}

/// Ligne détail : label (gauche bleu) | valeur (droite gris)
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge ABCDE du Nutri-Score
class _FullNutriscoreBadge extends StatelessWidget {
  final String grade;
  const _FullNutriscoreBadge({required this.grade});

  @override
  Widget build(BuildContext context) {
    const letters = ['A', 'B', 'C', 'D', 'E'];
    const colors = [
      Color(0xFF038141),
      Color(0xFF85BB2F),
      Color(0xFFFECB02),
      Color(0xFFEE8100),
      Color(0xFFE63E11),
    ];

    if (grade.isEmpty || grade == 'unknown') {
      return const Text('Inconnu',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final letter = letters[i];
        final isSelected = grade.toUpperCase() == letter;
        return Container(
          width: isSelected ? 30 : 22,
          height: isSelected ? 42 : 30,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: colors[i],
            borderRadius: BorderRadius.only(
              topLeft: i == 0 ? const Radius.circular(6) : Radius.zero,
              bottomLeft: i == 0 ? const Radius.circular(6) : Radius.zero,
              topRight: i == 4 ? const Radius.circular(6) : Radius.zero,
              bottomRight: i == 4 ? const Radius.circular(6) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSelected ? 20 : 13,
            ),
          ),
        );
      }),
    );
  }
}

/// Icône feuille EcoScore avec lettre et couleur
class _EcoScoreLeaf extends StatelessWidget {
  final String grade;
  const _EcoScoreLeaf({required this.grade});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (grade) {
      case 'a':
        c = const Color(0xFF1E8F4E);
        break;
      case 'b':
        c = const Color(0xFF2ECC71);
        break;
      case 'c':
        c = const Color(0xFFFFC107);
        break;
      case 'd':
        c = const Color(0xFFF39C12);
        break;
      case 'e':
        c = const Color(0xFFE74C3C);
        break;
      default:
        c = Colors.grey;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(17),
          topRight: Radius.circular(17),
          bottomRight: Radius.circular(17),
          bottomLeft: Radius.circular(4),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        grade.isEmpty || grade == 'unknown' ? '?' : grade.toUpperCase(),
        style:
            TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

/// Pill button Végétalien / Végétarien
class _PillButton extends StatelessWidget {
  final String label;
  final bool isTrue;
  const _PillButton({required this.label, required this.isTrue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isTrue ? const Color(0xFF4CAF93) : Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTrue ? Icons.check : Icons.close,
            color: isTrue ? Colors.white : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: isTrue ? Colors.white : Colors.grey[500],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Corps d'erreur
class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(error, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
}
