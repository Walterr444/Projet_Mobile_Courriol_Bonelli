// ============================================================
// ÉTAPE 1 — Création automatique de la collection "rappels"
// Ce hook s'exécute au démarrage de PocketBase.
// Il crée la collection si elle n'existe pas encore.
// ============================================================
onBootstrap((e) => {
    e.next();

    try {
        // Vérifier si la collection existe déjà
        $app.findCollectionByNameOrId("rappels");
        console.log("✅ Collection 'rappels' déjà existante.");
    } catch (err) {
        // La collection n'existe pas → on la crée
        console.log("📦 Création de la collection 'rappels'...");

        const collection = new Collection({
            name: "rappels",
            type: "base",
            fields: [
                { name: "gtin", type: "text" },
                { name: "rappel_id", type: "number" },
                { name: "rappel_guid", type: "text" },
                { name: "numero_fiche", type: "text" },
                { name: "libelle", type: "text" },
                { name: "marque_produit", type: "text" },
                { name: "categorie_produit", type: "text" },
                { name: "sous_categorie_produit", type: "text" },
                { name: "modeles_ou_references", type: "text" },
                { name: "date_debut_commercialisation", type: "text" },
                { name: "date_fin_commercialisation", type: "text" },
                { name: "zone_geographique_de_vente", type: "text" },
                { name: "distributeurs", type: "text" },
                { name: "motif_rappel", type: "text" },
                { name: "risques_encourus", type: "text" },
                { name: "conduites_a_tenir", type: "text" },
                { name: "preconisations_sanitaires", type: "text" },
                { name: "description_complementaire_risque", type: "text" },
                { name: "informations_complementaires", type: "text" },
                { name: "liens_vers_les_images", type: "text" },
                { name: "lien_vers_affichette_pdf", type: "text" },
                { name: "lien_vers_la_fiche_rappel", type: "text" },
                { name: "date_publication", type: "text" },
                { name: "date_fin_procedure", type: "text" },
            ],
        });

        $app.save(collection);
        console.log("✅ Collection 'rappels' créée avec succès !");
    }
});


// ============================================================
// ÉTAPE 2 — Synchronisation des rappels 2x par jour
// Télécharge le JSON et insère / met à jour les données en base.
// Pour tester rapidement : remplacer "0 8,20 * * *"
// par "*/2 * * * *" (toutes les 2 minutes)
// ============================================================
cronAdd("sync_rappels", "*/2 * * * *", () => {
    console.log("🔄 Démarrage de la synchronisation des rappels...");

    try {
        // 1. Télécharger le JSON
        const res = $http.send({
            url: "https://codelabs.formation-flutter.fr/assets/rappels.json",
            method: "GET",
        });

        const rappels = res.json;
        console.log(`📦 ${rappels.length} rappels reçus`);

        // 2. Pour chaque rappel : créer ou mettre à jour
        for (const rappel of rappels) {
            // Chercher si ce rappel existe déjà via rappel_guid
            let existingRecords = [];
            try {
                existingRecords = $app.findRecordsByFilter(
                    "rappels",
                    `rappel_guid = "${rappel.rappel_guid}"`,
                    "", 1, 0
                );
            } catch (e) {
                existingRecords = [];
            }

            const collection = $app.findCollectionByNameOrId("rappels");
            let record;

            if (existingRecords.length > 0) {
                record = existingRecords[0]; // Mise à jour
            } else {
                record = new Record(collection); // Création
            }

            // Remplir les champs
            record.set("gtin", String(rappel.gtin ?? ""));
            record.set("rappel_id", rappel.id ?? 0);
            record.set("rappel_guid", rappel.rappel_guid ?? "");
            record.set("numero_fiche", rappel.numero_fiche ?? "");
            record.set("libelle", rappel.libelle ?? "");
            record.set("marque_produit", rappel.marque_produit ?? "");
            record.set("categorie_produit", rappel.categorie_produit ?? "");
            record.set("sous_categorie_produit", rappel.sous_categorie_produit ?? "");
            record.set("modeles_ou_references", rappel.modeles_ou_references ?? "");
            record.set("date_debut_commercialisation", rappel.date_debut_commercialisation ?? "");
            record.set("date_fin_commercialisation", rappel.date_date_fin_commercialisation ?? "");
            record.set("zone_geographique_de_vente", rappel.zone_geographique_de_vente ?? "");
            record.set("distributeurs", rappel.distributeurs ?? "");
            record.set("motif_rappel", rappel.motif_rappel ?? "");
            record.set("risques_encourus", rappel.risques_encourus ?? "");
            record.set("conduites_a_tenir", rappel.conduites_a_tenir_par_le_consommateur ?? "");
            record.set("preconisations_sanitaires", rappel.preconisations_sanitaires ?? "");
            record.set("description_complementaire_risque", rappel.description_complementaire_risque ?? "");
            record.set("informations_complementaires", rappel.informations_complementaires ?? "");
            record.set("liens_vers_les_images", rappel.liens_vers_les_images ?? "");
            record.set("lien_vers_affichette_pdf", rappel.lien_vers_affichette_pdf ?? "");
            record.set("lien_vers_la_fiche_rappel", rappel.lien_vers_la_fiche_rappel ?? "");
            record.set("date_publication", rappel.date_publication ?? "");
            record.set("date_fin_procedure", rappel.date_de_fin_de_la_procedure_de_rappel ?? "");

            $app.save(record);
        }

        console.log(`✅ Synchronisation terminée : ${rappels.length} rappels traités`);

    } catch (err) {
        console.error("❌ Erreur lors de la synchronisation :", err);
    }
});