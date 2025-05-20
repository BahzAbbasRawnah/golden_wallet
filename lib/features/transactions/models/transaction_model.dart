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
  final double price;
  final double fee;
  final double total;
  final DateTime date;
  final String? paymentMethod;
  final String? reference;
  final String? notes;

  const Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.goldWeight,
    this.goldType,
    required this.price,
    required this.fee,
    required this.total,
    required this.date,
    this.paymentMethod,
    this.reference,
    this.notes,
  });

  /// Create a copy of this transaction with the given fields replaced with the new values
  Transaction copyWith({
    String? id,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    String? currency,
    double? goldWeight,
    String? goldType,
    double? price,
    double? fee,
    double? total,
    DateTime? date,
    String? paymentMethod,
    String? reference,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      goldWeight: goldWeight ?? this.goldWeight,
      goldType: goldType ?? this.goldType,
      price: price ?? this.price,
      fee: fee ?? this.fee,
      total: total ?? this.total,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }
}
