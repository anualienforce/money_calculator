// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'services/admob_service.dart';
import 'services/data_service.dart';
import 'models/app_settings.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdMobService.initialize();
  runApp(const MoneyCalculatorApp());
}

class MoneyCalculatorApp extends StatefulWidget {
  const MoneyCalculatorApp({super.key});

  @override
  State<MoneyCalculatorApp> createState() => _MoneyCalculatorAppState();
}

class _MoneyCalculatorAppState extends State<MoneyCalculatorApp> {
  AppSettings? settings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await DataService.getSettings();
      setState(() {
        settings = loadedSettings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        settings = AppSettings();
        isLoading = false;
      });
    }
  }

  void updateTheme(bool isDarkMode) {
    setState(() {
      settings = settings?.copyWith(isDarkMode: isDarkMode) ?? AppSettings(isDarkMode: isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Cash Calculator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings?.isDarkMode == true ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(onThemeChanged: updateTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}