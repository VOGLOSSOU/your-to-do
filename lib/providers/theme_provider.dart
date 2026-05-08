import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_override';

  // null = follow system, true = forced dark, false = forced light
  bool? _userOverride;

  ThemeMode get themeMode {
    if (_userOverride == null) return ThemeMode.system;
    return _userOverride! ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      _userOverride = true;
    } else if (stored == 'light') {
      _userOverride = false;
    } else {
      _userOverride = null;
    }
    notifyListeners();
  }

  // currentBrightness = brightness actually displayed right now
  Future<void> toggle(Brightness currentBrightness) async {
    final currentlyDark = currentBrightness == Brightness.dark;
    _userOverride = !currentlyDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _userOverride! ? 'dark' : 'light');
    notifyListeners();
  }
}
