import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('en_US', null);
  FlutterNativeSplash.remove();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'ORDO',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const MainScreen(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: isDark ? Colors.white : Colors.black,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: isDark ? Colors.white : Colors.black,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: isDark ? const Color(0xFF1C1C1C) : Colors.white,
      onSurface: isDark ? Colors.white : Colors.black,
      surfaceContainerHighest: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
      outline: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ),
  );
}
