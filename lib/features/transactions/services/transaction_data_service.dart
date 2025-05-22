import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';

/// Service for loading transaction data from JSON files
class TransactionDataService {
  /// Load all transactions from JSON files
  static Future<List<Transaction>> loadTransactions() async {
    final List<Transaction> allTransactions = [];

    try {
      // Load buy/sell transactions
      final buySellTransactions = await _loadBuySellTransactions();
      allTransactions.addAll(buySellTransactions);

      // Load deposit/withdraw transactions
      final depositWithdrawTransactions =
          await _loadDepositWithdrawTransactions();
      allTransactions.addAll(depositWithdrawTransactions);

      // Sort by date (newest first)
      allTransactions.sort((a, b) => b.date.compareTo(a.date));

      return allTransactions;
    } catch (e) {
      // Return empty list if JSON files are not available
      return [];
    }
  }

  /// Load buy/sell transactions from JSON file
  static Future<List<Transaction>> _loadBuySellTransactions() async {
    try {
      final String jsonData = await rootBundle
          .loadString('lib/features/buy_sell/data/transactions.json');
      final data = json.decode(jsonData);

      final List<Transaction> transactions = (data['transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();

      return transactions;
    } catch (e) {
      // Return empty list if JSON file is not available
      return [];
    }
  }

  /// Load deposit/withdraw transactions from JSON file
  static Future<List<Transaction>> _loadDepositWithdrawTransactions() async {
    try {
      final String jsonData = await rootBundle
          .loadString('lib/features/deposit_withdraw/data/transactions.json');
      final data = json.decode(jsonData);

      final List<Transaction> transactions = (data['transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();

      return transactions;
    } catch (e) {
      // Return empty list if JSON file is not available
      return [];
    }
  }

  /// Get transactions with filtering and sorting
  static Future<List<Transaction>> getTransactions({
    TransactionType? type,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    TransactionSortOption sortOption = TransactionSortOption.dateDesc,
  }) async {
    // Load all transactions
    final allTransactions = await loadTransactions();

    // Apply filters
    var filteredTransactions = allTransactions;

    // Filter by type
    if (type != null) {
      filteredTransactions =
          filteredTransactions.where((t) => t.type == type).toList();
    }

    // Filter by date range
    if (startDate != null) {
      filteredTransactions = filteredTransactions
          .where((t) =>
              t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      // Add one day to include the end date fully
      final adjustedEndDate = endDate.add(const Duration(days: 1));
      filteredTransactions = filteredTransactions
          .where((t) => t.date.isBefore(adjustedEndDate))
          .toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredTransactions = filteredTransactions
          .where((t) =>
              (t.description?.toLowerCase().contains(query) ?? false) ||
              (t.reference?.toLowerCase().contains(query) ?? false) ||
              (t.goldType?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply sorting
    switch (sortOption) {
      case TransactionSortOption.dateAsc:
        filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSortOption.dateDesc:
        filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSortOption.amountAsc:
        filteredTransactions
            .sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case TransactionSortOption.amountDesc:
        filteredTransactions
            .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
    }

    return filteredTransactions;
  }

  /// Get transaction by ID
  static Future<Transaction?> getTransactionById(String id) async {
    final allTransactions = await loadTransactions();
    return allTransactions.where((t) => t.id == id).firstOrNull;
  }

  /// Get transaction statistics
  static Future<TransactionStats> getTransactionStats() async {
    final allTransactions = await loadTransactions();

    // Calculate total buy amount
    final buyTransactions = allTransactions
        .where((t) =>
            t.type == TransactionType.buy &&
            t.status == TransactionStatus.completed)
        .toList();
    final totalBuyAmount = buyTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);

    // Calculate total sell amount
    final sellTransactions = allTransactions
        .where((t) =>
            t.type == TransactionType.sell &&
            t.status == TransactionStatus.completed)
        .toList();
    final totalSellAmount = sellTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);

    // Calculate total deposit amount
    final depositTransactions = allTransactions
        .where((t) =>
            t.type == TransactionType.deposit &&
            t.status == TransactionStatus.completed)
        .toList();
    final totalDepositAmount = depositTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);

    // Calculate total withdraw amount
    final withdrawTransactions = allTransactions
        .where((t) =>
            t.type == TransactionType.withdraw &&
            t.status == TransactionStatus.completed)
        .toList();
    final totalWithdrawAmount = withdrawTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);

    // Get recent transactions (last 5)
    final recentTransactions = allTransactions
        .where((t) => t.status == TransactionStatus.completed)
        .take(5)
        .toList();

    return TransactionStats(
      totalBuyAmount: totalBuyAmount,
      totalSellAmount: totalSellAmount,
      totalDepositAmount: totalDepositAmount,
      totalWithdrawAmount: totalWithdrawAmount,
      buyCount: buyTransactions.length,
      sellCount: sellTransactions.length,
      depositCount: depositTransactions.length,
      withdrawCount: withdrawTransactions.length,
      recentTransactions: recentTransactions,
    );
  }
}

/// Transaction statistics model
class TransactionStats {
  final double totalBuyAmount;
  final double totalSellAmount;
  final double totalDepositAmount;
  final double totalWithdrawAmount;
  final int buyCount;
  final int sellCount;
  final int depositCount;
  final int withdrawCount;
  final List<Transaction> recentTransactions;

  const TransactionStats({
    required this.totalBuyAmount,
    required this.totalSellAmount,
    required this.totalDepositAmount,
    required this.totalWithdrawAmount,
    required this.buyCount,
    required this.sellCount,
    required this.depositCount,
    required this.withdrawCount,
    this.recentTransactions = const [],
  });

  /// Get total transaction count
  int get totalCount => buyCount + sellCount + depositCount + withdrawCount;

  /// Get net balance (deposits + sells - withdraws - buys)
  double get netBalance =>
      totalDepositAmount +
      totalSellAmount -
      totalWithdrawAmount -
      totalBuyAmount;
}

/// Transaction sort options
enum TransactionSortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}
