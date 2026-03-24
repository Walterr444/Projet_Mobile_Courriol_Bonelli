import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/notifiers/favorites_notifier.dart';
import 'package:rappels_app/pages/product_page.dart';
import 'package:rappels_app/widgets/product_list_tile.dart';

/// Page des favoris de l'utilisateur.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F8),
      appBar: AppBar(
        // AppBar bleu-violet foncé comme dans la maquette 3
        backgroundColor: const Color(0xFF2D3091),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mes favoris',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<FavoritesNotifier>(
        builder: (context, favs, _) {
          if (favs.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favs.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(favs.error!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => favs.load(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (favs.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE8E9F3),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 90,
                      color: Color(0xFF2D3091),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Aucun favori pour le moment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3091),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: favs.items.length,
            itemBuilder: (context, i) {
              final item = favs.items[i];
              return ProductListTile(
                item: item,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => ProductPage(gtin: item['gtin'] ?? '')))
                      .then((_) => favs.load());
                },
              );
            },
          );
        },
      ),
    );
  }
}
