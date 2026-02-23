import 'package:flutter/material.dart';
import 'package:rappels_app/models/rappel.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran de détail d'un rappel produit.
/// Reproduit les informations d'une fiche officielle RappelConso.
class RappelDetailPage extends StatelessWidget {
  final Rappel rappel;

  const RappelDetailPage({super.key, required this.rappel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappel produit'),
        backgroundColor: const Color(0xFFA60000),
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour ouvrir la fiche PDF officielle
          if (rappel.lienVersAffichettePdf.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Voir la fiche PDF',
              onPressed: () async {
                final uri = Uri.parse(rappel.lienVersAffichettePdf);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo du produit
            if (rappel.liensVersLesImages.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.network(
                  rappel.liensVersLesImages,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit
                  Text(
                    rappel.libelle.isNotEmpty
                        ? rappel.libelle
                        : rappel.modeleOuReference,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rappel.marqueProduit,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 20),

                  // Bandeau motif du rappel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(26, 255, 0, 0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA60000)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Motif du rappel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA60000),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(rappel.motifRappel),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section dates
                  SectionTitle('Dates de commercialisation'),
                  InfoRow('Début', rappel.dateDebutCommercialisation),
                  InfoRow('Fin', rappel.dateFinCommercialisation),
                  InfoRow('Fin de procédure', rappel.dateFinProcedure),

                  const SizedBox(height: 16),

                  // Section distribution
                  SectionTitle('Distribution'),
                  InfoRow('Distributeurs', rappel.distributeurs),
                  InfoRow('Zone géographique', rappel.zoneGeographiqueDeVente),

                  const SizedBox(height: 16),

                  // Section risques
                  SectionTitle('Risques encourus'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(rappel.risquesEncourus),
                  ),
                  if (rappel.descriptionComplementaireRisque.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        rappel.descriptionComplementaireRisque,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Section conduites à tenir
                  SectionTitle('Conduite à tenir'),
                  ...rappel.conduitesATenir
                      .split('|')
                      .where((s) => s.trim().isNotEmpty)
                      .map(
                        (action) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  color: Color(0xFFA60000),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text(action.trim())),
                            ],
                          ),
                        ),
                      ),

                  const SizedBox(height: 16),

                  // Préconisations sanitaires (si non vide)
                  if (rappel.preconisationsSanitaires.isNotEmpty) ...[
                    SectionTitle('Préconisations sanitaires'),
                    Text(
                      rappel.preconisationsSanitaires,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Informations complémentaires (si non vide)
                  if (rappel.informationsComplementaires.isNotEmpty) ...[
                    SectionTitle('Informations complémentaires'),
                    Text(rappel.informationsComplementaires),
                    const SizedBox(height: 16),
                  ],

                  // Lien vers la fiche en ligne
                  if (rappel.lienVersLaFicheRappel.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(rappel.lienVersLaFicheRappel);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Voir la fiche officielle'),
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
}

/// Widget titre de section
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF333333),
        ),
      ),
    );
  }
}

/// Widget ligne info (label : valeur)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
