# My Tasks — Daily Task Tracker

A Flutter app for entrepreneurs to write down daily tasks and track progress throughout the day.

## What it does

- **Write tasks** — quickly add tasks for any given day
- **Check off tasks** — tap a task to mark it as done as you go through your day
- **Track progress** — see at a glance how many tasks are done vs remaining with a progress bar
- **Navigate your week** — scroll through the last 7 days to review past days or check today
- **Delete tasks** — remove any task with the delete icon on the right
- **Persistent storage** — all tasks are saved locally, nothing is lost when you close the app

## How it works

You open the app, write your tasks for the day (no time slots — just the task name), and check them off as you complete them. At any moment you can see where you stand. You can also tap any of the last 7 days to review what you did.

## Tech stack

- Flutter (Dart)
- `shared_preferences` — local storage, works on web and mobile
- `provider` — state management
- `google_fonts` — Inter font for a clean minimal look

## Project structure

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

## Getting started

```bash
flutter pub get

# Test in browser
flutter run -d chrome

# Run on Android
flutter run -d android
```
