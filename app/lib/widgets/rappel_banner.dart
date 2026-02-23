import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rappels_app/notifiers/rappel_notifier.dart';
import 'package:rappels_app/pages/rappel_detail_page.dart';

/// Bandeau d'alerte affiché quand un produit a un rappel en cours.
///
/// À placer dans l'arborescence de widgets juste avant les scores
/// (Nutri-Score, NOVA, etc.)
///
/// Le parent doit fournir un RappelNotifier via Provider/ChangeNotifierProvider.
class RappelBanner extends StatelessWidget {
  const RappelBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RappelNotifier>(
      builder: (context, notifier, _) {
        // Si pas de rappel ou en cours de chargement → on n'affiche rien
        if (!notifier.hasRappel || notifier.rappel == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: GestureDetector(
            // Au clic → ouvrir la page de détail du rappel
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RappelDetailPage(rappel: notifier.rappel!),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                // Fond rouge (#FF0000) avec opacité 36%
                color: const Color.fromARGB(92, 255, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ce produit fait l\'objet d\'un rappel produit',
                      style: const TextStyle(
                        // Texte rouge foncé (#A60000)
                        color: Color(0xFFA60000),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Color(0xFFA60000)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
