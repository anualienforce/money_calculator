class Denomination {
  double value;
  String label;
  int quantity;
  String? currencySymbol;

  Denomination({
    required this.value,
    required this.label,
    this.quantity = 0,
    this.currencySymbol,
  });

  double get total => value * quantity;

  String get formattedValue {
    final symbol = currencySymbol ?? '₹';
    return '$symbol${value.toStringAsFixed(value < 1 ? 2 : 0)}';
  }

  String get formattedTotal {
    final symbol = currencySymbol ?? '₹';
    return '$symbol${total.toStringAsFixed(value < 1 ? 2 : 0)}';
  }

  // Add this simple copy method
  Denomination copy() {
    return Denomination(
      value: value,
      label: label,
      quantity: quantity,
      currencySymbol: currencySymbol,
    );
  }

  Denomination copyWith({
    double? value,
    String? label,
    int? quantity,
    String? currencySymbol,
  }) {
    return Denomination(
      value: value ?? this.value,
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Denomination convertToCurrency(String newCurrency, Map<String, double> exchangeRates) {
    if (currencySymbol == newCurrency) return this;

    final currentRate = exchangeRates[currencySymbol] ?? 1.0;
    final newRate = exchangeRates[newCurrency] ?? 1.0;
    final convertedValue = (value / currentRate) * newRate;

    return copyWith(
      value: convertedValue,
      currencySymbol: newCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'quantity': quantity,
      'currencySymbol': currencySymbol,
    };
  }

  factory Denomination.fromJson(Map<String, dynamic> json) {
    return Denomination(
      value: json['value']?.toDouble() ?? 0.0,
      label: json['label'] ?? '',
      quantity: json['quantity'] ?? 0,
      currencySymbol: json['currencySymbol'],
    );
  }
}