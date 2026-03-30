[🇬🇧 Read in English](README.md)

# My Tasks — Suivi de tâches quotidiennes

Une app Flutter pour les entrepreneurs qui veulent écrire leurs tâches du jour et suivre leur avancement en temps réel.

## Accès

L'app est protégée par un code d'accès. Entre le code suivant au démarrage :

```
N@than16
```

## Fonctionnalités

- **Écrire des tâches** — ajoute rapidement des tâches pour aujourd'hui ou planifie celles de demain
- **Cocher les tâches** — tape sur une tâche pour la marquer comme faite au fil de ta journée
- **Suivre la progression** — vois d'un coup d'œil combien de tâches sont faites vs restantes avec une barre de progression
- **Tâches urgentes** — marque une tâche avec 🚩 pour la passer en urgent (point rouge, remontée en haut de liste)
- **Filtrer les tâches** — bascule entre les vues Toutes / Urgentes / Normales
- **Strip 7 jours** — navigue entre les 5 derniers jours, aujourd'hui et demain
- **Points de jours actifs** — petit point sous les jours qui ont des tâches
- **Récapitulatif de fin de journée** — bilan des tâches faites/restantes avec option de reporter les non faites au lendemain
- **Recherche** — retrouve n'importe quelle tâche par mot-clé sur les 7 jours (avec surbrillance)
- **Supprimer des tâches** — icône poubelle sur chaque tâche, ou swipe vers la gauche
- **Mode sombre** — bascule entre thème blanc et noir, le choix est sauvegardé
- **Jours passés en lecture seule** — les jours passés sont consultables uniquement, pas modifiables

## Comment ça marche

Tu ouvres l'app → tu entres ton code → tu écris tes tâches du jour → tu les coches au fur et à mesure. À n'importe quel moment tu peux voir où tu en es. En fin de journée, le bouton **Summary** te donne un bilan et te permet de reporter les tâches non faites au lendemain.

## Stack technique

- Flutter (Dart)
- `shared_preferences` — stockage local, fonctionne sur web et mobile
- `provider` — gestion d'état
- `google_fonts` — police Inter

## Structure du projet

```
lib/
├── main.dart
├── models/
│   └── task.dart
├── db/
│   └── database_helper.dart
├── providers/
│   ├── task_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── lock_screen.dart
│   └── home_screen.dart
└── widgets/
    ├── week_strip.dart
    ├── progress_header.dart
    ├── task_tile.dart
    ├── add_task_sheet.dart
    ├── summary_sheet.dart
    └── search_results.dart
```

## Démarrage

```bash
flutter pub get

# Tester dans le navigateur
flutter run -d chrome

# Lancer sur Android
flutter run -d android
```
