import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';

/// Enum representing different deposit/withdraw methods
enum DepositWithdrawMethod {
  bankTransfer,
  cardPayment,
  cash,
  physicalGold,
}

/// Extension to provide additional functionality to DepositWithdrawMethod enum
extension DepositWithdrawMethodExtension on DepositWithdrawMethod {
  /// Get the translation key for the method
  String get translationKey {
    switch (this) {
      case DepositWithdrawMethod.bankTransfer:
        return 'bank_transfer';
      case DepositWithdrawMethod.cardPayment:
        return 'card_payment';
      case DepositWithdrawMethod.cash:
        return 'cash';
      case DepositWithdrawMethod.physicalGold:
        return 'physical_gold';
    }
  }

  /// Get the icon for the method
  IconData get icon {
    switch (this) {
      case DepositWithdrawMethod.bankTransfer:
        return Icons.account_balance;
      case DepositWithdrawMethod.cardPayment:
        return Icons.credit_card;
      case DepositWithdrawMethod.cash:
        return Icons.payments;
      case DepositWithdrawMethod.physicalGold:
        return Icons.monetization_on;
    }
  }

  /// Get the color for the method
  Color get color {
    switch (this) {
      case DepositWithdrawMethod.bankTransfer:
        return AppTheme.infoColor;
      case DepositWithdrawMethod.cardPayment:
        return AppTheme.accentColor;
      case DepositWithdrawMethod.cash:
        return AppTheme.successColor;
      case DepositWithdrawMethod.physicalGold:
        return AppTheme.goldColor;
    }
  }
}

/// Model representing a deposit/withdraw transaction
class DepositWithdrawTransaction {
  final String id;
  final TransactionType type; // deposit or withdraw
  final TransactionStatus status;
  final double amount;
  final String currency;
  final double? goldWeight;
  final String? goldType;
  final double fee;
  final double total;
  final DateTime date;
  final DepositWithdrawMethod method;
  final String? reference;
  final String? notes;
  final String? receiptImageUrl;
  final BankAccountDetails? bankDetails;
  final CardDetails? cardDetails;

  const DepositWithdrawTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.goldWeight,
    this.goldType,
    required this.fee,
    required this.total,
    required this.date,
    required this.method,
    this.reference,
    this.notes,
    this.receiptImageUrl,
    this.bankDetails,
    this.cardDetails,
  });

  /// Create a copy of this transaction with the given fields replaced with the new values
  DepositWithdrawTransaction copyWith({
    String? id,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    String? currency,
    double? goldWeight,
    String? goldType,
    double? fee,
    double? total,
    DateTime? date,
    DepositWithdrawMethod? method,
    String? reference,
    String? notes,
    String? receiptImageUrl,
    BankAccountDetails? bankDetails,
    CardDetails? cardDetails,
  }) {
    return DepositWithdrawTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      goldWeight: goldWeight ?? this.goldWeight,
      goldType: goldType ?? this.goldType,
      fee: fee ?? this.fee,
      total: total ?? this.total,
      date: date ?? this.date,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      bankDetails: bankDetails ?? this.bankDetails,
      cardDetails: cardDetails ?? this.cardDetails,
    );
  }

  /// Convert to a Transaction object
  Transaction toTransaction() {
    return Transaction(
      id: id,
      type: type,
      status: status,
      amount: amount,
      currency: currency,
      goldWeight: goldWeight,
      goldType: goldType,
      price: 0, // Not applicable for deposit/withdraw
      fee: fee,
      total: total,
      date: date,
      paymentMethod: method.translationKey,
      reference: reference,
      notes: notes,
    );
  }
}

/// Model representing bank account details
class BankAccountDetails {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? swiftCode;
  final String? iban;

  const BankAccountDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.swiftCode,
    this.iban,
  });
}

/// Model representing card details
class CardDetails {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;

  const CardDetails({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
  });
}

/// Extension to provide additional functionality to DepositWithdrawTransaction class
extension DepositWithdrawTransactionExtension on DepositWithdrawTransaction {
  /// Get the icon for the transaction
  IconData get icon => type.icon;

  /// Get the color for the transaction
  Color get color => type.color;
}
