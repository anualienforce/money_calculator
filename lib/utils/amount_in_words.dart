// lib/utils/amount_in_words.dart
class AmountInWords {
  static String convert(double amount, {String currencyName = 'Rupees'}) {
    if (amount == 0) {
      return 'Zero $currencyName Only';
    }

    // Split into whole and decimal parts
    int wholePart = amount.floor();
    int decimalPart = ((amount - wholePart) * 100).round();

    String result = _convertWholeNumber(wholePart);

    if (result.isEmpty) {
      return 'Zero $currencyName Only';
    }

    result += ' $currencyName';

    if (decimalPart > 0) {
      String decimalWords = _convertWholeNumber(decimalPart);
      String fractionalUnit = _getFractionalUnit(currencyName);
      result += ' and $decimalWords $fractionalUnit';
    }

    return '$result Only';
  }

  static String _getFractionalUnit(String currencyName) {
    switch (currencyName.toLowerCase()) {
      case 'us dollar':
      case 'dollar':
        return 'Cents';
      case 'euro':
        return 'Cents';
      case 'british pound':
      case 'pound':
        return 'Pence';
      case 'indian rupee':
      case 'rupee':
      case 'rupees':
        return 'Paise';
      case 'japanese yen':
      case 'yen':
        return 'Sen';
      case 'russian ruble':
      case 'ruble':
        return 'Kopeks';
      default:
        return 'Cents';
    }
  }

  static String _convertWholeNumber(int number) {
    if (number == 0) return '';

    String result = '';

    // Handle billions
    if (number >= 1000000000) {
      result += _convertHundreds(number ~/ 1000000000) + ' Billion ';
      number %= 1000000000;
    }

    // Handle millions
    if (number >= 1000000) {
      result += _convertHundreds(number ~/ 1000000) + ' Million ';
      number %= 1000000;
    }

    // Handle thousands
    if (number >= 1000) {
      result += _convertHundreds(number ~/ 1000) + ' Thousand ';
      number %= 1000;
    }

    // Handle hundreds
    if (number > 0) {
      result += _convertHundreds(number);
    }

    return result.trim();
  }

  static String _convertHundreds(int number) {
    if (number == 0) return '';

    String result = '';

    if (number >= 100) {
      result += _ones[number ~/ 100] + ' Hundred ';
      number %= 100;
    }

    if (number >= 20) {
      result += _tens[number ~/ 10] + ' ';
      number %= 10;
    }

    if (number >= 10) {
      result += _teens[number - 10] + ' ';
      return result.trim();
    }

    if (number > 0) {
      result += _ones[number] + ' ';
    }

    return result.trim();
  }

  static const List<String> _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
  ];

  static const List<String> _teens = [
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];
}