import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/notifiers/rappel_notifier.dart';
import 'package:rappels_app/widgets/rappel_banner.dart';

/// Page de démonstration : simule une fiche produit avec code-barres.
/// Pour tester, entre un GTIN présent dans ta base PocketBase.
class ProductDemoPage extends StatefulWidget {
  const ProductDemoPage({super.key});

  @override
  State<ProductDemoPage> createState() => _ProductDemoPageState();
}

class _ProductDemoPageState extends State<ProductDemoPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RappelNotifier(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Fiche Produit')),
        body: Consumer<RappelNotifier>(
          builder: (context, notifier, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ de test : saisir un GTIN manuellement
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Code-barres (GTIN)',
                            hintText: 'Ex: 3383883752028',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            final gtin = _controller.text.trim();
                            if (gtin.isNotEmpty) {
                              context.read<RappelNotifier>().checkRappel(gtin);
                            }
                          },
                          child: const Text('Vérifier le rappel'),
                        ),
                      ],
                    ),
                  ),

                  // Simulation d'un produit (nom, marque, description)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Petits pois et carottes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cassegrain',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Petits pois et carottes à l\'étuvée avec garniture',
                        ),
                      ],
                    ),
                  ),

                  // Indicateur de chargement
                  if (notifier.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ⭐ Le bandeau de rappel — à placer juste avant les scores
                  const RappelBanner(),

                  // Simulation des scores Nutri-Score / NOVA
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ScoreCard(
                          label: 'Nutri-Score',
                          value: 'A',
                          color: Color(0xFF1a7d2c),
                        ),
                        _ScoreCard(
                          label: 'Groupe NOVA',
                          value: '1',
                          color: Color(0xFF33a854),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Widget de score (Nutri-Score / NOVA) — exemple visuel
class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
