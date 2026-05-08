[🇫🇷 Lire en français](README.fr.md)

# ORDO — Daily Task Tracker

A clean, minimal Flutter app built for entrepreneurs who want a digital version of their daily notebook. Write tasks, track progress, stay consistent.

## Features

### Core
- **Add tasks** — title + description (both required), for today or tomorrow
- **Check off tasks** — tap the circle to mark done, task moves to the bottom
- **Urgent flag** — tap the flag icon to mark a task urgent (red dot, sorted to top automatically)
- **Swipe to delete** — swipe left on any task to remove it
- **Task detail** — tap a task title to open a full detail sheet (title, description, status, urgent badge)
- **Read-only past days** — past days are visible for review but not editable

### Navigation
- **7-day strip** — navigate between the last 5 days, today, and tomorrow
- **Active day dots** — small dot under days that have tasks
- **Progress header** — date label + "X / Y tasks completed" + progress bar

### End-of-day
- **Summary sheet** — tap the chart icon (visible when today has tasks) for a recap: done count, remaining list
- **Carry over** — move all unfinished tasks to tomorrow in one tap

### Recurring tasks
- **Recurring task manager** — tap the repeat icon to create tasks that automatically appear every day (great for daily routines)
- New recurring tasks are seeded into today and future days automatically

### Week view
- **Week screen** — bottom nav tab showing all 7 days with done/total stats per day
- **Consistency score** — "X / Y active days fully completed" to track your discipline over the week
- **Day cards** — green border when all done, tap a day to navigate to it in the Tasks tab

### UI
- **Dark mode** — full black theme, toggle from any screen, preference saved
- **No lock screen** — opens directly to your tasks
- **App name** — ORDO, with custom icon and splash screen on launch

## How it works

Open ORDO → write your tasks for the day → check them off as you go. Flag urgent tasks to keep them at the top. At the end of the day, open the summary and carry unfinished work to tomorrow. Check the Week tab to see how consistent you've been.

## Tech stack

- Flutter (Dart)
- `shared_preferences` — local JSON storage, no server needed
- `provider` — state management
- `google_fonts` — Inter font
- `flutter_native_splash` — branded splash screen on launch
- `intl` — date formatting

## Project structure

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

## Getting started

```bash
flutter pub get

# Run on Android
flutter run -d android

# Build release APK
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
