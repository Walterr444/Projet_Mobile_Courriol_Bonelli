import 'package:flutter/material.dart';
import 'package:rappels_app/models/rappel.dart';
import 'package:share_plus/share_plus.dart';

/// Écran de détail d'un rappel produit.
/// Design centré selon la maquette (sections titrées en bleu foncé).
/// Bouton partage en haut à droite via share_plus.
class RappelDetailPage extends StatelessWidget {
  final Rappel rappel;
  const RappelDetailPage({super.key, required this.rappel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappel produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Partager',
            onPressed: rappel.lienVersLaFicheRappel.isEmpty
                ? null
                : () => Share.share(rappel.lienVersLaFicheRappel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image du produit
            if (rappel.liensVersLesImages.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  rappel.liensVersLesImages,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),
            // Contenu centré
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _Section(
                    title: 'Dates de commercialisation',
                    content: _datesContent(),
                  ),
                  _Section(
                    title: 'Distributeurs',
                    content: rappel.distributeurs,
                  ),
                  _Section(
                    title: 'Zone géographique',
                    content: rappel.zoneGeographiqueDeVente,
                  ),
                  _Section(
                    title: 'Motif du rappel',
                    content: rappel.motifRappel,
                  ),
                  _Section(
                    title: 'Risques encourus',
                    content: rappel.risquesEncourus,
                  ),
                  if (rappel.conduitesATenir.isNotEmpty)
                    _Section(
                      title: 'Conduites à tenir',
                      content: rappel.conduitesATenir.replaceAll('|', '\n• '),
                    ),
                  if (rappel.preconisationsSanitaires.isNotEmpty)
                    _Section(
                      title: 'Préconisations sanitaires',
                      content: rappel.preconisationsSanitaires,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _datesContent() {
    if (rappel.dateDebutCommercialisation.isEmpty &&
        rappel.dateFinCommercialisation.isEmpty) return '';
    final debut = rappel.dateDebutCommercialisation;
    final fin   = rappel.dateFinCommercialisation;
    if (debut.isNotEmpty && fin.isNotEmpty) return 'Du $debut au $fin';
    if (debut.isNotEmpty) return 'Depuis le $debut';
    return "Jusqu'au $fin";
  }
}

/// Section centrée avec titre en bleu foncé.
class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
