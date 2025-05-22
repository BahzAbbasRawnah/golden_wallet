import 'package:flutter/material.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/theme.dart';

/// Enum representing different transaction types
enum TransactionType {
  buy,
  sell,
  deposit,
  withdraw,
  transfer,
  investment,
}

/// Enum representing different transaction statuses
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

/// Extension to provide additional functionality to TransactionType enum
extension TransactionTypeExtension on TransactionType {
  /// Get the translation key for the transaction type
  String get translationKey {
    switch (this) {
      case TransactionType.buy:
        return 'buyGold';
      case TransactionType.sell:
        return 'sellGold';
      case TransactionType.deposit:
        return 'depositCash';
      case TransactionType.withdraw:
        return 'withdrawCash';
      case TransactionType.transfer:
        return 'transfer';
      case TransactionType.investment:
        return 'investment';
    }
  }

  /// Get the icon for the transaction type
  IconData get icon {
    switch (this) {
      case TransactionType.buy:
        return Icons.shopping_cart;
      case TransactionType.sell:
        return Icons.sell;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdraw:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.investment:
        return Icons.trending_up;
    }
  }

  /// Get the color for the transaction type
  Color get color {
    switch (this) {
      case TransactionType.buy:
        return AppTheme.goldColor;
      case TransactionType.sell:
        return AppTheme.goldDark;
      case TransactionType.deposit:
        return AppTheme.successColor;
      case TransactionType.withdraw:
        return AppTheme.warningColor;
      case TransactionType.transfer:
        return AppTheme.infoColor;
      case TransactionType.investment:
        return AppTheme.investmentHighYieldColor;
    }
  }

  /// Check if the transaction type is incoming (adds value to wallet)
  bool get isIncoming {
    return this == TransactionType.buy ||
        this == TransactionType.deposit ||
        this == TransactionType.investment;
  }
}

/// Extension to provide additional functionality to TransactionStatus enum
extension TransactionStatusExtension on TransactionStatus {
  /// Get the translation key for the transaction status
  String get translationKey {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Get the color for the transaction status
  Color get color {
    switch (this) {
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.failed:
        return AppTheme.errorColor;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }
}

/// Model representing a transaction
class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final double? goldWeight;
  final String? goldType;
  final String? goldCategory;
  final double price;
  final double totalAmount;
  final DateTime date;
  final DateTime? completedDate;
  final String? paymentMethod;
  final String? paymentMethodId;
  final String? reference;
  final String? description;
  final String? failureReason;
  final String? cancellationReason;

  const Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.goldWeight,
    this.goldType,
    this.goldCategory,
    required this.price,
    required this.totalAmount,
    required this.date,
    this.completedDate,
    this.paymentMethod,
    this.paymentMethodId,
    this.reference,
    this.description,
    this.failureReason,
    this.cancellationReason,
  });

  /// Create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Parse transaction type
    TransactionType parseType(String typeStr) {
      switch (typeStr.toLowerCase()) {
        case 'buy':
          return TransactionType.buy;
        case 'sell':
          return TransactionType.sell;
        case 'deposit':
          return TransactionType.deposit;
        case 'withdraw':
          return TransactionType.withdraw;
        case 'transfer':
          return TransactionType.transfer;
        case 'investment':
          return TransactionType.investment;
        default:
          return TransactionType.deposit;
      }
    }

    // Parse transaction status
    TransactionStatus parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'pending':
          return TransactionStatus.pending;
        case 'processing':
          return TransactionStatus.pending; // Treat processing as pending
        case 'completed':
          return TransactionStatus.completed;
        case 'failed':
          return TransactionStatus.failed;
        case 'cancelled':
          return TransactionStatus.cancelled;
        default:
          return TransactionStatus.pending;
      }
    }

    return Transaction(
      id: json['id'],
      type: parseType(json['type']),
      status: parseStatus(json['status']),
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'AED',
      goldWeight: json['goldWeight']?.toDouble(),
      goldType: json['goldType'],
      goldCategory: json['goldCategory'],
      price: json['price']?.toDouble() ?? 0.0,
      totalAmount:
          json['totalAmount']?.toDouble() ?? json['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      paymentMethod: json['paymentMethod'],
      paymentMethodId: json['paymentMethodId'],
      reference: json['reference'],
      description: json['description'],
      failureReason: json['failureReason'],
      cancellationReason: json['cancellationReason'],
    );
  }

  /// Create a copy of this transaction with the given fields replaced with the new values
  Transaction copyWith({
    String? id,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    String? currency,
    double? goldWeight,
    String? goldType,
    String? goldCategory,
    double? price,
    double? totalAmount,
    DateTime? date,
    DateTime? completedDate,
    String? paymentMethod,
    String? paymentMethodId,
    String? reference,
    String? description,
    String? failureReason,
    String? cancellationReason,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      goldWeight: goldWeight ?? this.goldWeight,
      goldType: goldType ?? this.goldType,
      goldCategory: goldCategory ?? this.goldCategory,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      completedDate: completedDate ?? this.completedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      failureReason: failureReason ?? this.failureReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
