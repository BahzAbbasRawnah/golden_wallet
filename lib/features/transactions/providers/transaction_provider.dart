import 'dart:math';
import 'package:flutter/material.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';

/// Provider for managing transactions
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  
  // Filters
  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  
  // Sorting
  bool _sortAscending = false;
  
  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  TransactionType? get selectedType => _selectedType;
  TransactionStatus? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  bool get sortAscending => _sortAscending;
  
  /// Initialize the provider with mock data
  TransactionProvider() {
    _loadMockTransactions();
    _applyFilters();
  }
  
  /// Load mock transaction data
  void _loadMockTransactions() {
    final random = Random();
    final now = DateTime.now();
    
    // Generate 20 random transactions for the past 30 days
    _transactions = List.generate(20, (index) {
      final daysAgo = random.nextInt(30);
      final type = TransactionType.values[random.nextInt(TransactionType.values.length)];
      final status = TransactionStatus.values[random.nextInt(TransactionStatus.values.length)];
      
      // Generate random amount between 0.1 and 5 for gold transactions
      final amount = (random.nextDouble() * 4.9 + 0.1).toDouble();
      
      // Generate random price between 1800 and 2300 for gold
      final price = (random.nextDouble() * 500 + 1800).toDouble();
      
      // Calculate fee (0.5% to 2%)
      final feePercentage = (random.nextDouble() * 1.5 + 0.5) / 100;
      final fee = price * amount * feePercentage;
      
      // Calculate total
      final total = type.isIncoming 
          ? price * amount + fee 
          : price * amount - fee;
      
      // Generate random gold type
      final goldTypes = ['24K', '22K', '21K', '18K'];
      final goldType = goldTypes[random.nextInt(goldTypes.length)];
      
      // Generate random payment method
      final paymentMethods = ['wallet', 'bank_transfer', 'card', 'cash'];
      final paymentMethod = paymentMethods[random.nextInt(paymentMethods.length)];
      
      return Transaction(
        id: 'TRX${100000 + index}',
        type: type,
        status: status,
        amount: amount,
        currency: 'USD',
        goldWeight: amount,
        goldType: goldType,
        price: price,
        fee: fee,
        total: total,
        date: now.subtract(Duration(days: daysAgo, hours: random.nextInt(24), minutes: random.nextInt(60))),
        paymentMethod: paymentMethod,
        reference: 'REF${10000 + random.nextInt(90000)}',
        notes: random.nextBool() ? 'Sample transaction note' : null,
      );
    });
    
    // Sort transactions by date (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
  
  /// Apply filters to transactions
  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      // Filter by type
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }
      
      // Filter by status
      if (_selectedStatus != null && transaction.status != _selectedStatus) {
        return false;
      }
      
      // Filter by date range
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null) {
        // Include the entire end date by setting time to end of day
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (transaction.date.isAfter(endOfDay)) {
          return false;
        }
      }
      
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.id.toLowerCase().contains(query) ||
               transaction.reference?.toLowerCase().contains(query) == true ||
               transaction.notes?.toLowerCase().contains(query) == true;
      }
      
      return true;
    }).toList();
    
    // Sort filtered transactions
    _sortFilteredTransactions();
    
    notifyListeners();
  }
  
  /// Sort filtered transactions
  void _sortFilteredTransactions() {
    if (_sortAscending) {
      _filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
    } else {
      _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
    }
  }
  
  /// Set filter by transaction type
  void setTypeFilter(TransactionType? type) {
    _selectedType = type;
    _applyFilters();
  }
  
  /// Set filter by transaction status
  void setStatusFilter(TransactionStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }
  
  /// Set date range filter
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }
  
  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  /// Toggle sort order
  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _sortFilteredTransactions();
    notifyListeners();
  }
  
  /// Reset all filters
  void resetFilters() {
    _selectedType = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _sortAscending = false;
    _applyFilters();
  }
  
  /// Get transaction by ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }
}
