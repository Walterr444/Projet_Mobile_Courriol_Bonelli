import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/notifiers/auth_notifier.dart';
import 'package:rappels_app/notifiers/history_notifier.dart';
import 'package:rappels_app/pages/favorites_page.dart';
import 'package:rappels_app/pages/login_page.dart';
import 'package:rappels_app/pages/product_page.dart';
import 'package:rappels_app/widgets/product_list_tile.dart';

/// Page d'accueil : historique de scans de l'utilisateur.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryNotifier>().load();
    });
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );
  }

  void _logout() {
    context.read<AuthNotifier>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _openProduct(String gtin) {
    final historyNotifier = context.read<HistoryNotifier>();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductPage(gtin: gtin)))
        .then((_) => historyNotifier.load());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryNotifier>(
      builder: (context, history, _) {
        final hasHistory =
            history.items.isNotEmpty && !history.isLoading && history.error == null;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
            title: const Text(
              'Mes scans',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A237E),
              ),
            ),
            actions: [
              // Icône barcode uniquement si historique non vide
              if (hasHistory)
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  tooltip: 'Scanner',
                  onPressed: _openScanner,
                ),
              // Étoile → favoris (toujours visible)
              IconButton(
                icon: const Icon(Icons.star),
                tooltip: 'Mes favoris',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                ),
              ),
              // Déconnexion
              IconButton(
                icon: const Icon(Icons.exit_to_app_rounded),
                tooltip: 'Se déconnecter',
                onPressed: _logout,
              ),
            ],
          ),
          body: () {
            if (history.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (history.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(history.error!,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => history.load(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (history.items.isEmpty) {
              return _EmptyState(onScan: _openScanner);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: history.items.length,
              itemBuilder: (context, i) {
                final item = history.items[i];
                return ProductListTile(
                  item: item,
                  onTap: () => _openProduct(item['gtin'] ?? ''),
                );
              },
            );
          }(),
        );
      },
    );
  }
}

// ── Page scanner ──────────────────────────────────────────
class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un produit'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode?.rawValue == null) return;

          _handled = true;
          final gtin = barcode!.rawValue!;
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductPage(gtin: gtin)),
          );
        },
      ),
    );
  }
}

// ── État vide ────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration : cercle lavande + icônes panier et produits
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grand cercle lavande en fond
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8E9F3),
                  ),
                ),
                // Petites formes décoratives
                Positioned(
                  top: 15,
                  right: 30,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D2E8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        size: 16, color: Color(0xFF5C6BC0)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 45,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D2E8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.category_outlined,
                        size: 14, color: Color(0xFF5C6BC0)),
                  ),
                ),
                // Icône panier centrale
                const Icon(
                  Icons.shopping_basket_rounded,
                  size: 110,
                  color: Color(0xFF3D4194),
                ),
                // Petites boites dans le panier (déco)
                Positioned(
                  top: 55,
                  right: 55,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEB400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 40,
                  child: Container(
                    width: 22,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DB6AC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Vous n'avez pas encore\nscanné de produit",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Bouton COMMENCER jaune
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEB400),
              foregroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
              elevation: 0,
            ),
            onPressed: onScan,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'COMMENCER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
