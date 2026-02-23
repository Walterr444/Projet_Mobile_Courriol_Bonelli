/// Modèle de données représentant un rappel produit
/// Les champs correspondent exactement à la collection PocketBase "rappels"
class Rappel {
  final String id; // ID PocketBase (généré automatiquement)
  final String gtin; // Code-barres EAN du produit
  final String libelle; // Nom du produit
  final String marqueProduit;
  final String categorieProduit;
  final String modeleOuReference;
  final String dateDebutCommercialisation;
  final String dateFinCommercialisation;
  final String zoneGeographiqueDeVente;
  final String distributeurs;
  final String motifRappel;
  final String risquesEncourus;
  final String conduitesATenir;
  final String preconisationsSanitaires;
  final String descriptionComplementaireRisque;
  final String informationsComplementaires;
  final String liensVersLesImages;
  final String lienVersAffichettePdf;
  final String lienVersLaFicheRappel;
  final String datePublication;
  final String dateFinProcedure;

  const Rappel({
    required this.id,
    required this.gtin,
    required this.libelle,
    required this.marqueProduit,
    required this.categorieProduit,
    required this.modeleOuReference,
    required this.dateDebutCommercialisation,
    required this.dateFinCommercialisation,
    required this.zoneGeographiqueDeVente,
    required this.distributeurs,
    required this.motifRappel,
    required this.risquesEncourus,
    required this.conduitesATenir,
    required this.preconisationsSanitaires,
    required this.descriptionComplementaireRisque,
    required this.informationsComplementaires,
    required this.liensVersLesImages,
    required this.lienVersAffichettePdf,
    required this.lienVersLaFicheRappel,
    required this.datePublication,
    required this.dateFinProcedure,
  });

  /// Crée un Rappel depuis un enregistrement PocketBase (RecordModel)
  factory Rappel.fromRecord(dynamic record) {
    return Rappel(
      id: record.id,
      gtin: record.getStringValue('gtin'),
      libelle: record.getStringValue('libelle'),
      marqueProduit: record.getStringValue('marque_produit'),
      categorieProduit: record.getStringValue('categorie_produit'),
      modeleOuReference: record.getStringValue('modeles_ou_references'),
      dateDebutCommercialisation: record.getStringValue(
        'date_debut_commercialisation',
      ),
      dateFinCommercialisation: record.getStringValue(
        'date_fin_commercialisation',
      ),
      zoneGeographiqueDeVente: record.getStringValue(
        'zone_geographique_de_vente',
      ),
      distributeurs: record.getStringValue('distributeurs'),
      motifRappel: record.getStringValue('motif_rappel'),
      risquesEncourus: record.getStringValue('risques_encourus'),
      conduitesATenir: record.getStringValue('conduites_a_tenir'),
      preconisationsSanitaires: record.getStringValue(
        'preconisations_sanitaires',
      ),
      descriptionComplementaireRisque: record.getStringValue(
        'description_complementaire_risque',
      ),
      informationsComplementaires: record.getStringValue(
        'informations_complementaires',
      ),
      liensVersLesImages: record.getStringValue('liens_vers_les_images'),
      lienVersAffichettePdf: record.getStringValue('lien_vers_affichette_pdf'),
      lienVersLaFicheRappel: record.getStringValue('lien_vers_la_fiche_rappel'),
      datePublication: record.getStringValue('date_publication'),
      dateFinProcedure: record.getStringValue('date_fin_procedure'),
    );
  }
}
