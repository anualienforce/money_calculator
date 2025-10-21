import 'package:intl/intl.dart';
import '../models/denomination.dart';

class CurrencyService {
  // Currency configurations
  static final Map<String, CurrencyConfig> _currencies = {
    'USD': CurrencyConfig(
      symbol: '\$',
      name: 'US Dollar',
      code: 'USD',
      denominations: [100.0, 50.0, 20.0, 10.0, 5.0, 1.0, 0.25, 0.10, 0.05, 0.01],
      labels: ['100', '50', '20', '10', '5', '1', '0.25', '0.10', '0.05', '0.01'],
    ),
    'EUR': CurrencyConfig(
      symbol: '€',
      name: 'Euro',
      code: 'EUR',
      denominations: [500.0, 200.0, 100.0, 50.0, 20.0, 10.0, 5.0, 2.0, 1.0, 0.50, 0.20, 0.10, 0.05, 0.02, 0.01],
      labels: ['500', '200', '100', '50', '20', '10', '5', '2', '1', '0.50', '0.20', '0.10', '0.05', '0.02', '0.01'],
    ),
    'GBP': CurrencyConfig(
      symbol: '£',
      name: 'British Pound',
      code: 'GBP',
      denominations: [50.0, 20.0, 10.0, 5.0, 2.0, 1.0, 0.50, 0.20, 0.10, 0.05, 0.02, 0.01],
      labels: ['50', '20', '10', '5', '2', '1', '0.50', '0.20', '0.10', '0.05', '0.02', '0.01'],
    ),
    'INR': CurrencyConfig(
      symbol: '₹',
      name: 'Indian Rupee',
      code: 'INR',
      denominations: [2000.0, 500.0, 200.0, 100.0, 50.0, 20.0, 10.0, 5.0, 2.0, 1.0],
      labels: ['2000', '500', '200', '100', '50', '20', '10', '5', '2', '1'],
    ),
    'JPY': CurrencyConfig(
      symbol: '¥',
      name: 'Japanese Yen',
      code: 'JPY',
      denominations: [10000.0, 5000.0, 1000.0, 500.0, 100.0, 50.0, 10.0, 5.0, 1.0],
      labels: ['10000', '5000', '1000', '500', '100', '50', '10', '5', '1'],
    ),
    'RUB': CurrencyConfig(
      symbol: '₽',
      name: 'Russian Ruble',
      code: 'RUB',
      denominations: [5000.0, 1000.0, 500.0, 100.0, 50.0, 10.0, 5.0, 1.0],
      labels: ['5000', '1000', '500', '100', '50', '10', '5', '1'],
    ),
  };

  // Get currency configuration
  static CurrencyConfig getCurrency(String currencyCode) {
    return _currencies[currencyCode] ?? _currencies['INR']!;
  }

  // Get all available currencies
  static List<CurrencyConfig> getAllCurrencies() {
    return _currencies.values.toList();
  }

  // Format amount with currency
  static String formatAmount(double amount, String currencyCode, {int? decimalPlaces}) {
    final config = getCurrency(currencyCode);
    final formatter = NumberFormat.currency(
      symbol: config.symbol,
      decimalDigits: decimalPlaces ?? (amount % 1 == 0 ? 0 : 2),
    );
    return formatter.format(amount);
  }

  // Format amount in words with currency
  static String formatAmountInWords(double amount, String currencyCode) {
    final config = getCurrency(currencyCode);
    if (amount == 0) return 'Zero ${config.name}';

    final amountInWords = _convertAmountToWords(amount);
    return '$amountInWords ${config.name}${amount != 1 ? 's' : ''}';
  }

  // Convert amount to words (basic implementation)
  static String _convertAmountToWords(double amount) {
    if (amount == 0) return 'Zero';

    final wholePart = amount.floor();
    final decimalPart = ((amount - wholePart) * 100).round();

    String result = _convertWholeNumberToWords(wholePart);

    if (decimalPart > 0) {
      result += ' and ${_convertWholeNumberToWords(decimalPart)} ${decimalPart == 1 ? 'cent' : 'cents'}';
    }

    return result;
  }

  static String _convertWholeNumberToWords(int number) {
    if (number == 0) return 'Zero';

    final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    final teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    final thousands = ['', 'Thousand', 'Million', 'Billion'];

    String result = '';
    int thousandIndex = 0;

    while (number > 0) {
      int chunk = number % 1000;
      if (chunk != 0) {
        String chunkWords = '';

        // Handle hundreds
        int hundreds = chunk ~/ 100;
        if (hundreds > 0) {
          chunkWords += '${ones[hundreds]} Hundred ';
        }

        // Handle tens and ones
        int remainder = chunk % 100;
        if (remainder >= 20) {
          int tensDigit = remainder ~/ 10;
          int onesDigit = remainder % 10;
          chunkWords += '${tens[tensDigit]}';
          if (onesDigit > 0) {
            chunkWords += ' ${ones[onesDigit]}';
          }
          chunkWords += ' ';
        } else if (remainder >= 10) {
          chunkWords += '${teens[remainder - 10]} ';
        } else if (remainder > 0) {
          chunkWords += '${ones[remainder]} ';
        }

        if (thousandIndex > 0 && thousandIndex < thousands.length) {
          chunkWords += '${thousands[thousandIndex]} ';
        }

        result = chunkWords + result;
      }

      number ~/= 1000;
      thousandIndex++;
    }

    return result.trim();
  }

  // Get denominations for a specific currency
  static List<Denomination> getDenominations(String currencyCode) {
    final config = getCurrency(currencyCode);
    return List.generate(
      config.denominations.length,
          (index) => Denomination(
        value: config.denominations[index],
        label: config.labels[index],
        currencySymbol: config.symbol,
      ),
    );
  }

  // Get currency code from symbol
  static String getCurrencyCodeFromSymbol(String symbol) {
    for (final entry in _currencies.entries) {
      if (entry.value.symbol == symbol) {
        return entry.key;
      }
    }
    return 'INR'; // Default fallback
  }

  // Format large amounts with abbreviations
  static String formatLargeAmount(double amount, String currencySymbol) {
    if (amount >= 10000000) { // 1 Crore
      return '$currencySymbol${(amount / 10000000).toStringAsFixed(amount % 10000000 == 0 ? 0 : 1)}Cr';
    } else if (amount >= 100000) { // 1 Lakh
      return '$currencySymbol${(amount / 100000).toStringAsFixed(amount % 100000 == 0 ? 0 : 1)}L';
    } else if (amount >= 1000) { // 1 Thousand
      return '$currencySymbol${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    } else {
      return '$currencySymbol${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
    }
  }
}

class CurrencyConfig {
  final String symbol;
  final String name;
  final String code;
  final List<double> denominations;
  final List<String> labels;

  CurrencyConfig({
    required this.symbol,
    required this.name,
    required this.code,
    required this.denominations,
    required this.labels,
  });

  @override
  String toString() {
    return 'CurrencyConfig(symbol: $symbol, name: $name, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyConfig &&
        other.symbol == symbol &&
        other.name == name &&
        other.code == code;
  }

  @override
  int get hashCode {
    return symbol.hashCode ^ name.hashCode ^ code.hashCode;
  }
}