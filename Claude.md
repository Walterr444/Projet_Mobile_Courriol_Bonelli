# Mémoire du Projet : Application Yuka-like (Rappels Produits)

Ce document centralise toutes les informations sur l'application mobile de scan de produits alimentaires et de vérification des rappels, développée dans le cadre d'un projet académique (Flutter + PocketBase). Il a pour objectif de permettre à une IA ou un développeur de comprendre immédiatement l'architecture et l'état actuel du code.

---

## 1. Le contexte du projet
Le projet consiste à créer un clone simplifié de l'application **Yuka**. 
L'application permet à l'utilisateur de :
- Scanner le code-barres (GTIN) d'un produit alimentaire.
- Récupérer et afficher les informations nutritionnelles via l'API publique d'**Open Food Facts**.
- Vérifier si ce produit fait l'objet d'un rappel officiel en France (via l'API data.gouv des rappels, synchronisée localement).
- Conserver un historique de ses scans et gérer une liste de favoris personnelle.

## 2. Les technologies utilisées
- **Frontend** : Flutter (`3.10.x+`) / Dart.
- **Backend & Base de données** : PocketBase (`0.21.x+`) – un BaaS open-source incluant auth, base SQLite et administration.
- **Dépendances principales Flutter** :
  - `provider` (gestion d'état via ChangeNotifier).
  - `pocketbase` (SDK Dart officiel pour interagir avec le backend).
  - `mobile_scanner` (outil de lecture de code-barres multiplateforme Android/iOS).
  - `http` (requêtes HTTP vers l'API externe d'Open Food Facts).
  - `share_plus` (fonction de partage natif des fiches de rappels).
  - `cached_network_image` (mise en cache des images des produits).

## 3. L'architecture choisie
L'application Flutter suit une architecture simple et robuste orientée Modèle-Vue-Contrôleur (via `Provider`) avec une séparation stricte des responsabilités :
- **Models (`lib/models/`)** : Définition des structures de données (e.g., `product.dart`, `rappel.dart`).
- **Services (`lib/services/`)** : Singletons gérant l'accès aux données externes (PocketBase, HTTP, APIs).
  - `auth_service.dart`, `product_service.dart`, `favorites_service.dart`, `history_service.dart`.
- **Notifiers (`lib/notifiers/`)** : Classes `ChangeNotifier` qui maintiennent l'état métier de l'application (UI-independent) et orchestrent les services.
- **Pages (`lib/pages/`)** : Vues de l'application structurées autour d'un `Scaffold`.
- **Widgets (`lib/widgets/`)** : Composants réutilisables d'UI pure (`nutriscore_badge.dart`, `product_list_tile.dart`, `rappel_banner.dart`).

Côté Backend (PocketBase) :
L'architecture tire parti des **pb_hooks** (via JavaScript Engine) de PocketBase (`server/pb_hooks/main.pb.js`) permettant de surcharger le comportement du serveur et d'éviter les configurations manuelles. Tout le backend (collections, cron) est automatisé par le code.

## 4. Les décisions techniques prises
- **State Management** : Utilisation de `Provider` et `ChangeNotifier` pour leur simplicité et leur adéquation avec les exigences académiques, offrant une séparation nette entre l'état local (UI) et l'état global.
- **Création des collections DB en pb_hooks** : Pour s'assurer que n'importe quel développeur clonant le projet ait immédiatement un backend fonctionnel sans avoir à importer un fichier JSON, toutes les collections (`rappels`, `history`, `favorites`) sont configurées automatiquement via l'événement `onBootstrap` dans le fichier JavaScript `main.pb.js`.
- **Détection dynamique de l'host Backend** : `AuthService` détermine dynamiquement si l'app tourne sur Web/Desktop (`127.0.0.1`) ou sur un émulateur Android (`10.0.2.2`). *Note : Pour un device physique, l'attribut doit être modifiée avec l'IP de la machine locale.*
- **Unicité des favoris** : `FavoritesService` garantit qu'il n'y a pas de doublons en interrogeant la collection par `(user = userId && gtin = gtin)` avant chaque insertion.

## 5. Les collections PocketBase
1.  **`users`** : Collection par défaut de PocketBase gérant l'authentification (`email`, `password`).
2.  **`rappels`** : Contient tous les rappels produits (GTIN, libellé, motif, risques...). Alimentée via la tâche Cron.
3.  **`history`** : Historique des scans.
    - Champs : `user` (relation vers users, mandatory), `gtin`, `product_name`, `brand`, `nutriscore`, `image_url`.
    - Règles : Insert/View/Delete autorisés uniquement pour `@request.auth.id != '' && user = @request.auth.id`.
4.  **`favorites`** : Mêmes champs et mêmes règles que `history`.

## 6. Les endpoints utilisés
- API PocketBase (REST locale gérée par le SDK Dart).
- **API Open Food Facts (v3)** :
  - `GET https://world.openfoodfacts.org/api/v3/product/{gtin}.json`
  - Les champs filtrés via `?fields=` : product_name, brands, nutriscore_grade, nova_group, image_url, ingredients_text, allergens_tags, additives_tags, nutriments.
- API Gouvernementale des Rappels Produits :
  - `GET https://codelabs.formation-flutter.fr/assets/rappels.json` (téléchargée à chaque exécution du cron).

## 7. Les fonctionnalités implémentées
✅ **Authentification** : Inscription, connexion, déconnexion (sauvegarde auto de session via le authStore de PocketBase).
✅ **Scan de code-barres** : Intégré grâce au package `mobile_scanner`.
✅ **Fiche produit multiniveau** : Implémentée avec un `BottomNavigationBar` regroupant :
  - Fiche : Vue d'ensemble avec badges visuels pour Nutri-Score (ABCDE complet) et NOVA, EcoScore (icône feuille colorée), Quantité, Pays de vente, pills Végétalien/Végétarien.
  - Caractéristiques : Ingrédients en 2 colonnes (label | détail %), Substances allergènes, Additifs.
  - Nutrition : Liste par nutriment avec valeur colorée (vert/orange/rouge) + sous-label "Faible/Modérée/Élevée quantité".
  - Tableau : Listing complet de toutes les valeurs nutritionnelles normalisées pour 100g vs par part.
✅ **Synchronisation et affichage des rappels** : Le hook PocketBase télécharge les rappels ; Flutter l'indique dynamiquement sur le bandeau et une page dédiée affiche les détails complexes.
✅ **Historique et Favoris** : Sauvegarde en temps réel, aucune redondance dans les listes de favoris, les interfaces vides sont gérées visuellement.
✅ **Refonte UI complète** (commit "front app mobile") :
  - `home_page.dart` : Illustration panier dans l'état vide, icône barcode conditionnelle dans l'AppBar, fond gris lavande.
  - `favorites_page.dart` : AppBar bleu-violet foncé (`#2D3091`) avec titre et flèche retour en blanc.
  - `product_list_tile.dart` : Carte Row propre (image carrée 90×90 + texte), suppression du Stack avec image flottante.
  - `product_page.dart` : Design cohérent sur les 4 onglets, boutons AppBar en cercles semi-transparents.

## 8. Le plan du projet 
Toutes les phases définies par les consignes initiales ont été effectuées.
Le plan consistait à diviser la structure : (1) Configuration Backend PB_hooks -> (2) Mise à jour Pubspec -> (3) Services (Auth, OFF, PB) -> (4) Notifiers d'états (Models) -> (5) Composants visuels et Navigation -> (6) Refonte UI front-end.

## 9. Les améliorations possibles
- **Mode hors-ligne** : Utiliser un cache local (ex: Hive, SQLite) pour accéder à l'historique et aux favoris dans des zones sans connectivité.
- **Traduction** : Ajout d'une gestion multilingue, notamment parce que certains additifs OFF reviennent avec un composant `en:` qui est simplement supprimé pour le moment (ex: `en:E471`).
- **Paging et Scroll d'historiques infinis** : La méthode actuelle retourne une limite de N éléments (`perPage: 100`) par souci de simplicité. Il faudrait implémenter un scroll `fetchMore`.
- **Page Scan dédiée** : La page caméra est fonctionnelle mais sans design particulier — à retravailler selon maquette.

## 10. L'état actuel du projet
Le projet est **fonctionnel et terminé** selon les spécifications + refonte UI réalisée.
Toutes les fonctionnalités requises (Scan, OFF, Rappels Codelabs, Auth, Favoris/Historiques) sont compilables et ne génèrent pas d'erreurs d'analyse Dart majeures.

---

## 11. Commandes pratiques

### Lancer le projet
```bash
# 1. Démarrer PocketBase (terminal 1)
cd server
./pocketbase.exe serve     # Windows
# ./pocketbase serve       # macOS/Linux

# 2. Lancer Flutter (terminal 2)
cd app
flutter run                # émulateur par défaut
flutter run -d chrome      # version web
```

### Git
```bash
git add app/lib/ app/pubspec.yaml app/pubspec.lock
git commit -m "votre message"
git push origin main
```

### Device physique
Modifier l'IP dans `lib/services/auth_service.dart` :
```dart
// Remplacer 10.0.2.2 (émulateur) par l'IP locale de votre machine
static const String _host = '192.168.x.x:8090';
```

### Palette de couleurs UI
| Rôle | Valeur |
|---|---|
| Couleur principale (bleu foncé) | `#2D3091` |
| Fond pages list | `#F5F5FA` |
| Fond favoris | `#F0F0F8` |
| Bouton action (jaune) | `#FEB400` |
| Nutriscore A | `#038141` |
| Nutriscore B | `#85BB2F` |
| Nutriscore C | `#FECB02` |
| Nutriscore D | `#EE8100` |
| Nutriscore E | `#E63E11` |

---
*Dernière mise à jour : Mars 2026 — après refonte UI front-end complète.*
