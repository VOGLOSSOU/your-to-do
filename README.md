[🇫🇷 Lire en français](README.fr.md)

# My Tasks — Daily Task Tracker

A Flutter app for entrepreneurs to write down daily tasks and track progress throughout the day.

## Access

The app is protected by an access code. Enter the following code at launch:

```
N@than16
```

## Features

- **Write tasks** — quickly add tasks for today or plan ahead for tomorrow
- **Check off tasks** — tap a task to mark it as done as you go through your day
- **Track progress** — see at a glance how many tasks are done vs remaining with a progress bar
- **Urgent tasks** — flag a task with 🚩 to mark it as urgent (red dot, moved to top of list)
- **Filter tasks** — switch between All / Urgent / Normal views
- **7-day strip** — navigate between the last 5 days, today, and tomorrow
- **Active day dots** — small dot under days that have tasks
- **End-of-day summary** — recap of done/remaining tasks with option to carry unfinished tasks to tomorrow
- **Search** — find any task by keyword across all 7 days (with highlight)
- **Delete tasks** — trash icon on each task, or swipe left
- **Dark mode** — toggle between light and black theme, preference is saved
- **Read-only past days** — past days are for review only, no editing allowed

## How it works

Open the app → enter your code → write your tasks for the day → check them off as you complete them. At any moment you can see where you stand. At the end of the day, use the **Summary** button to review and carry unfinished tasks over to tomorrow.

## Tech stack

- Flutter (Dart)
- `shared_preferences` — local storage, works on web and mobile
- `provider` — state management
- `google_fonts` — Inter font

## Project structure

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

## Getting started

```bash
flutter pub get

# Test in browser
flutter run -d chrome

# Run on Android
flutter run -d android
```
