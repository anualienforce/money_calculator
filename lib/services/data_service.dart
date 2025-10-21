import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/app_settings.dart';

class DataService {
  static const String _transactionsKey = 'transactions';
  static const String _settingsKey = 'settings';

  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];
    return transactionsJson
        .map((json) => Transaction.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveTransaction(Transaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    transactions.add(transaction);
    
    final transactionsJson = transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  static Future<void> deleteTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    
    final transactionsJson = transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  // Settings methods
  static Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      return AppSettings.fromJson(jsonDecode(settingsJson));
    }
    
    return AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
