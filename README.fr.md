[🇬🇧 Read in English](README.md)

# My Tasks — Suivi de tâches quotidiennes

Une app Flutter pour les entrepreneurs qui veulent écrire leurs tâches du jour et suivre leur avancement en temps réel.

## Ce que ça fait

- **Écrire des tâches** — ajoute rapidement des tâches pour n'importe quel jour
- **Cocher les tâches** — tape sur une tâche pour la marquer comme faite au fil de ta journée
- **Suivre la progression** — vois d'un coup d'œil combien de tâches sont faites vs restantes avec une barre de progression
- **Naviguer sur 7 jours** — scroll sur les 7 derniers jours pour revoir les jours passés ou consulter aujourd'hui
- **Supprimer des tâches** — supprime n'importe quelle tâche via l'icône poubelle à droite
- **Stockage local** — toutes les tâches sont sauvegardées localement, rien n'est perdu à la fermeture de l'app

## Comment ça marche

Tu ouvres l'app, tu écris tes tâches du jour (pas d'horaire — juste le nom de la tâche), et tu les coches au fur et à mesure. À n'importe quel moment tu peux voir où tu en es. Tu peux aussi taper sur l'un des 7 derniers jours pour revoir ce que tu as fait.

## Stack technique

- Flutter (Dart)
- `shared_preferences` — stockage local, fonctionne sur web et mobile
- `provider` — gestion d'état
- `google_fonts` — police Inter pour un look minimaliste

## Structure du projet

```
lib/
├── main.dart
├── models/
│   └── task.dart
├── db/
│   └── database_helper.dart
├── providers/
│   └── task_provider.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    ├── week_strip.dart
    ├── progress_header.dart
    ├── task_tile.dart
    └── add_task_sheet.dart
```

## Démarrage

```bash
flutter pub get

# Tester dans le navigateur
flutter run -d chrome

# Lancer sur Android
flutter run -d android
```
