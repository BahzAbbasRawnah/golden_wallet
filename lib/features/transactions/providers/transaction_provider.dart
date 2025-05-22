import 'package:flutter/material.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/features/transactions/services/transaction_data_service.dart';

/// Provider for managing transactions
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;

  // Filters
  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Sorting
  TransactionSortOption _sortOption = TransactionSortOption.dateDesc;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  TransactionType? get selectedType => _selectedType;
  TransactionStatus? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  TransactionSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  /// Initialize the provider with data from JSON
  TransactionProvider() {
    loadTransactions();
  }

  /// Load transactions from JSON data
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await TransactionDataService.loadTransactions();
      _applyFilters();
    } catch (e) {
      // Handle error
      _transactions = [];
      _filteredTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get transaction statistics
  Future<TransactionStats> getTransactionStats() async {
    return await TransactionDataService.getTransactionStats();
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
        final endOfDay = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (transaction.date.isAfter(endOfDay)) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.id.toLowerCase().contains(query) ||
            transaction.reference?.toLowerCase().contains(query) == true ||
            transaction.description?.toLowerCase().contains(query) == true;
      }

      return true;
    }).toList();

    // Sort filtered transactions
    _sortFilteredTransactions();

    notifyListeners();
  }

  /// Sort filtered transactions
  void _sortFilteredTransactions() {
    switch (_sortOption) {
      case TransactionSortOption.dateAsc:
        _filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSortOption.dateDesc:
        _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSortOption.amountAsc:
        _filteredTransactions
            .sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case TransactionSortOption.amountDesc:
        _filteredTransactions
            .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
    }
  }

  /// Get sort ascending status
  bool get sortAscending => _sortOption == TransactionSortOption.dateAsc;

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

  /// Toggle sort order (date)
  void toggleSortOrder() {
    if (_sortOption == TransactionSortOption.dateAsc) {
      _sortOption = TransactionSortOption.dateDesc;
    } else if (_sortOption == TransactionSortOption.dateDesc) {
      _sortOption = TransactionSortOption.dateAsc;
    }
    _sortFilteredTransactions();
    notifyListeners();
  }

  /// Set sort option
  void setSortOption(TransactionSortOption option) {
    _sortOption = option;
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
    _sortOption = TransactionSortOption.dateDesc;
    _applyFilters();
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await TransactionDataService.getTransactionById(id);
    } catch (e) {
      return _transactions
          .where((transaction) => transaction.id == id)
          .firstOrNull;
    }
  }
}
