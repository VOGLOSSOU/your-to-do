[🇬🇧 Read in English](README.md)

# ORDO — Suivi de tâches quotidiennes

Une app Flutter propre et minimaliste conçue pour les entrepreneurs qui veulent une version digitale de leur carnet quotidien. Écris tes tâches, suis ta progression, reste consistant.

## Fonctionnalités

### Essentiel
- **Ajouter des tâches** — titre + description (tous les deux obligatoires), pour aujourd'hui ou demain
- **Cocher les tâches** — tape le cercle pour marquer comme fait, la tâche descend automatiquement en bas
- **Flag urgent** — tape l'icône drapeau pour passer une tâche en urgent (point rouge, remontée en haut automatiquement)
- **Swipe pour supprimer** — glisse vers la gauche sur une tâche pour la supprimer
- **Détail d'une tâche** — tape le titre pour ouvrir une fiche complète (titre, description, statut, badge urgent)
- **Jours passés en lecture seule** — les jours passés sont consultables mais pas modifiables

### Navigation
- **Strip 7 jours** — navigue entre les 5 derniers jours, aujourd'hui et demain
- **Points de jours actifs** — petit point sous les jours qui ont des tâches
- **En-tête de progression** — date + "X / Y tâches complétées" + barre de progression

### Fin de journée
- **Récapitulatif** — tape l'icône graphique (visible quand aujourd'hui a des tâches) pour voir le bilan : faites, restantes
- **Carry over** — reporte toutes les tâches non finies au lendemain en un tap

### Tâches récurrentes
- **Gestionnaire de récurrentes** — tape l'icône repeat pour créer des tâches qui apparaissent automatiquement chaque jour (idéal pour les routines)
- Les nouvelles tâches récurrentes s'insèrent automatiquement dans aujourd'hui et les jours suivants

### Vue semaine
- **Onglet Semaine** — voir les 7 jours avec les stats faites/total par jour
- **Score de consistance** — "X / Y jours actifs entièrement complétés" pour mesurer ta discipline sur la semaine
- **Cartes de jour** — bordure verte quand tout est fait, tape un jour pour y naviguer dans l'onglet Tâches

### Notifications
- **Rappel quotidien** — tape l'icône cloche pour définir une notification quotidienne à l'heure de ton choix
- Activer/désactiver, changer l'heure via un time picker
- Persiste après redémarrage de l'app et du téléphone

### Interface
- **Mode sombre** — thème noir complet, toggle depuis n'importe quel écran, préférence sauvegardée
- **Pas d'écran de verrouillage** — s'ouvre directement sur tes tâches
- **Nom de l'app** — ORDO, avec icône personnalisée et splash screen au lancement

## Comment ça marche

Tu ouvres ORDO → tu écris tes tâches du jour → tu les coches au fur et à mesure. Marque les urgentes pour les garder en haut. En fin de journée, ouvre le récapitulatif et reporte le reste au lendemain. Consulte l'onglet Semaine pour voir ta consistance sur les 7 derniers jours.

## Stack technique

- Flutter (Dart)
- `shared_preferences` — stockage JSON local, aucun serveur nécessaire
- `provider` — gestion d'état
- `google_fonts` — police Inter
- `flutter_local_notifications` + `timezone` — rappels quotidiens planifiés
- `flutter_native_splash` — splash screen brandé au lancement
- `intl` — formatage des dates

## Structure du projet

```
lib/
├── main.dart
├── models/
│   ├── task.dart
│   └── recurring_task.dart
├── db/
│   └── database_helper.dart
├── providers/
│   ├── task_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── main_screen.dart
│   ├── home_screen.dart
│   └── week_screen.dart
├── services/
│   └── notification_service.dart
└── widgets/
    ├── week_strip.dart
    ├── progress_header.dart
    ├── task_tile.dart
    ├── task_detail_sheet.dart
    ├── add_task_sheet.dart
    ├── summary_sheet.dart
    ├── recurring_tasks_sheet.dart
    └── notification_sheet.dart
```

## Démarrage

```bash
flutter pub get

# Lancer sur Android
flutter run -d android

# Build APK release
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
