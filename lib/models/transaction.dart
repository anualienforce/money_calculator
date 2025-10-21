import '../models/denomination.dart';

class Transaction {
  final String id;
  final String title;
  final String notes;
  final List<Denomination> denominations;
  final double onlineAmount;
  final double totalAmount;
  final DateTime timestamp;
  final String? currencySymbol;
  final String? currencyCode;

  Transaction({
    required this.id,
    required this.title,
    required this.notes,
    required this.denominations,
    required this.onlineAmount,
    required this.totalAmount,
    required this.timestamp,
    this.currencySymbol,
    this.currencyCode,
  });

  // Get cash amount (total - online)
  double get cashAmount => totalAmount - onlineAmount;

  // Get total quantity of notes/coins
  int get totalQuantity => denominations.fold(0, (sum, denom) => sum + denom.quantity);

  // Get formatted total amount
  String get formattedTotal {
    final symbol = currencySymbol ?? '₹';
    return '$symbol${totalAmount.toStringAsFixed(totalAmount % 1 == 0 ? 0 : 2)}';
  }

  // Get formatted cash amount
  String get formattedCashAmount {
    final symbol = currencySymbol ?? '₹';
    return '$symbol${cashAmount.toStringAsFixed(cashAmount % 1 == 0 ? 0 : 2)}';
  }

  // Get formatted online amount
  String get formattedOnlineAmount {
    final symbol = currencySymbol ?? '₹';
    return '$symbol${onlineAmount.toStringAsFixed(onlineAmount % 1 == 0 ? 0 : 2)}';
  }

  Transaction copyWith({
    String? id,
    String? title,
    String? notes,
    List<Denomination>? denominations,
    double? onlineAmount,
    double? totalAmount,
    DateTime? timestamp,
    String? currencySymbol,
    String? currencyCode,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      denominations: denominations ?? this.denominations,
      onlineAmount: onlineAmount ?? this.onlineAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      timestamp: timestamp ?? this.timestamp,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'denominations': denominations.map((d) => d.toJson()).toList(),
      'onlineAmount': onlineAmount,
      'totalAmount': totalAmount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      notes: json['notes'] ?? '',
      denominations: (json['denominations'] as List<dynamic>?)
          ?.map((d) => Denomination.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
      onlineAmount: json['onlineAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      currencySymbol: json['currencySymbol'],
      currencyCode: json['currencyCode'],
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, totalAmount: $totalAmount, currency: $currencySymbol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}