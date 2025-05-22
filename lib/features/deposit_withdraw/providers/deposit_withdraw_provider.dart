import 'dart:math';
import 'package:flutter/material.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/features/deposit_withdraw/models/deposit_withdraw_model.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/features/transactions/providers/transaction_provider.dart';

/// Provider for managing deposit and withdraw operations
class DepositWithdrawProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String? _error;
  double _cashBalance = 5240.00; // Mock initial cash balance
  double _goldBalance = 12.45; // Mock initial gold balance in oz

  // Current transaction being processed
  DepositWithdrawTransaction? _currentTransaction;

  // Transaction history
  List<DepositWithdrawTransaction> _transactions = [];

  // Fee percentages
  final double _depositFeePercentage = 0.01; // 1%
  final double _withdrawFeePercentage = 0.02; // 2%

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get cashBalance => _cashBalance;
  double get goldBalance => _goldBalance;
  DepositWithdrawTransaction? get currentTransaction => _currentTransaction;
  List<DepositWithdrawTransaction> get transactions => _transactions;

  // Constructor
  DepositWithdrawProvider() {
    _loadMockTransactions();
  }

  /// Load mock transaction data
  void _loadMockTransactions() {
    final random = Random();
    final now = DateTime.now();

    // Generate 10 random deposit/withdraw transactions for the past 30 days
    _transactions = List.generate(10, (index) {
      final daysAgo = random.nextInt(30);
      final type = random.nextBool()
          ? TransactionType.deposit
          : TransactionType.withdraw;
      final status = TransactionStatus
          .values[random.nextInt(TransactionStatus.values.length)];

      // Generate random amount between 100 and 5000 for cash
      final amount = (random.nextDouble() * 4900 + 100).toDouble();

      // Calculate fee
      final feePercentage = type == TransactionType.deposit
          ? _depositFeePercentage
          : _withdrawFeePercentage;
      final fee = amount * feePercentage;

      // Calculate total
      final total =
          type == TransactionType.deposit ? amount - fee : amount + fee;

      // Generate random method
      final methods = DepositWithdrawMethod.values;
      final method = methods[random.nextInt(methods.length)];

      return DepositWithdrawTransaction(
        id: 'TRX${200000 + index}',
        type: type,
        status: status,
        amount: amount,
        currency: 'USD',
        fee: fee,
        total: total,
        date: now.subtract(Duration(
            days: daysAgo,
            hours: random.nextInt(24),
            minutes: random.nextInt(60))),
        method: method,
        methodId: method.translationKey,
        reference: 'REF${20000 + random.nextInt(90000)}',
        description:
            random.nextBool() ? 'Sample transaction description' : null,
      );
    });

    // Sort transactions by date (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Initialize a new deposit transaction
  void initializeDeposit({
    required double amount,
    required DepositWithdrawMethod method,
    String? description,
  }) {
    final fee = amount * _depositFeePercentage;
    final total = amount - fee;

    _currentTransaction = DepositWithdrawTransaction(
      id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.deposit,
      status: TransactionStatus.pending,
      amount: amount,
      currency: 'USD',
      fee: fee,
      total: total,
      date: DateTime.now(),
      method: method,
      methodId: method.translationKey,
      description: description,
    );

    notifyListeners();
  }

  /// Initialize a new withdraw transaction
  void initializeWithdraw({
    required double amount,
    required DepositWithdrawMethod method,
    String? description,
  }) {
    final fee = amount * _withdrawFeePercentage;
    final total = amount + fee;

    _currentTransaction = DepositWithdrawTransaction(
      id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.withdraw,
      status: TransactionStatus.pending,
      amount: amount,
      currency: 'USD',
      fee: fee,
      total: total,
      date: DateTime.now(),
      method: method,
      methodId: method.translationKey,
      description: description,
    );

    notifyListeners();
  }

  /// Update the current transaction with bank details
  void updateBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    String? swiftCode,
    String? iban,
  }) {
    if (_currentTransaction == null) return;

    final paymentDetails = {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      if (swiftCode != null) 'swiftCode': swiftCode,
      if (iban != null) 'iban': iban,
    };

    _currentTransaction = _currentTransaction!.copyWith(
      paymentDetails: paymentDetails,
    );

    notifyListeners();
  }

  /// Update the current transaction with card details
  void updateCardDetails({
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
  }) {
    if (_currentTransaction == null) return;

    final paymentDetails = {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };

    _currentTransaction = _currentTransaction!.copyWith(
      paymentDetails: paymentDetails,
    );

    notifyListeners();
  }

  /// Update the current transaction with receipt image
  void updateReceiptImage(String receiptImageUrl) {
    if (_currentTransaction == null) return;

    _currentTransaction = _currentTransaction!.copyWith(
      receiptImageUrl: receiptImageUrl,
    );

    notifyListeners();
  }

  /// Update the current transaction with reference number
  void updateReference(String reference) {
    if (_currentTransaction == null) return;

    _currentTransaction = _currentTransaction!.copyWith(
      reference: reference,
    );

    notifyListeners();
  }

  /// Process the current transaction
  Future<bool> processTransaction(
      TransactionProvider transactionProvider) async {
    if (_currentTransaction == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Update transaction status
      _currentTransaction = _currentTransaction!.copyWith(
        status: TransactionStatus.completed,
      );

      // Update balances
      if (_currentTransaction!.type == TransactionType.deposit) {
        _cashBalance += _currentTransaction!.total;
      } else {
        if (_cashBalance < _currentTransaction!.amount) {
          throw Exception('Insufficient balance');
        }
        _cashBalance -= _currentTransaction!.amount;
      }

      // Add to transaction history
      _transactions.insert(0, _currentTransaction!);

      // In a real app, we would call an API to save the transaction
      // and add it to the global transaction history
      // transactionProvider.addTransaction(_currentTransaction!.toTransaction());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();

      // Update transaction status
      _currentTransaction = _currentTransaction!.copyWith(
        status: TransactionStatus.failed,
      );

      notifyListeners();
      return false;
    }
  }

  /// Clear the current transaction
  void clearCurrentTransaction() {
    _currentTransaction = null;
    _error = null;
    notifyListeners();
  }

  /// Validate deposit amount
  bool validateDepositAmount(double amount) {
    return amount >= AppConstants.minTransactionAmount &&
        amount <= AppConstants.maxTransactionAmount;
  }

  /// Validate withdraw amount
  bool validateWithdrawAmount(double amount) {
    return amount >= AppConstants.minTransactionAmount &&
        amount <= AppConstants.maxTransactionAmount &&
        amount <= _cashBalance;
  }

  /// Get transaction by ID
  DepositWithdrawTransaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }
}
