# Your To-Do — Daily Homework Tracker

A Flutter app to write down your daily homework assignments and track your progress throughout the day.

## Features

- **Add tasks** — quickly jot down homework assignments for the day
- **Check off tasks** — mark each task as done as you complete it
- **Progress view** — see at a glance how many tasks are done vs remaining
- **Daily reset** — tasks are scoped to the current day

## Screens

1. **Home screen** — list of today's tasks with a progress bar + add button
2. **Task item** — checkbox, subject label, description, optional due time

## Tech stack

- Flutter (Dart)
- `hive` or `shared_preferences` for local persistence (no backend needed)
- `provider` or `riverpod` for state management

## Project structure

```
lib/
├── main.dart
├── models/
│   └── task.dart
├── providers/
│   └── task_provider.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    ├── task_tile.dart
    ├── add_task_sheet.dart
    └── progress_header.dart
```

## Getting started

```bash
flutter pub get
flutter run
```
