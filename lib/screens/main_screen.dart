import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'week_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    WeekScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        indicatorColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            selectedIcon: Icon(Icons.checklist, color: cs.surface),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_outlined, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            selectedIcon: Icon(Icons.calendar_view_week, color: cs.surface),
            label: 'Week',
          ),
        ],
      ),
    );
  }
}
