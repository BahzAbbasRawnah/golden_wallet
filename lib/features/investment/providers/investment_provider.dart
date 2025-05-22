import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golden_wallet/features/investment/models/investment_model.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';
import 'package:golden_wallet/features/investment/services/investment_data_service.dart';

/// Provider to manage investment data
class InvestmentProvider extends ChangeNotifier {
  List<InvestmentPlan> _investmentPlans = [];
  List<Investment> _userInvestments = [];
  InvestmentSummary? _investmentSummary;
  bool _isLoading = false;
  String? _error;
  bool _hasSeenOnboarding = false;
  bool _isFirstTimeInvestmentVisit = false;

  /// Get all investment plans
  List<InvestmentPlan> get investmentPlans => _investmentPlans;

  /// Get active investment plans
  List<InvestmentPlan> get activeInvestmentPlans =>
      _investmentPlans.where((plan) => plan.isActive).toList();

  /// Get all user investments
  List<Investment> get userInvestments => _userInvestments;

  /// Get active user investments
  List<Investment> get activeUserInvestments => _userInvestments
      .where((investment) =>
          investment.status == InvestmentStatus.active ||
          investment.status == InvestmentStatus.pending)
      .toList();

  /// Get investment summary
  InvestmentSummary? get investmentSummary => _investmentSummary;

  /// Check if investments are loading
  bool get isLoading => _isLoading;

  /// Get the error message
  String? get error => _error;

  /// Check if the user has seen the investment onboarding
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  /// Check if this is the first time the user is visiting the investment tab
  bool get isFirstTimeInvestmentVisit => _isFirstTimeInvestmentVisit;

  /// Initialize the investment provider
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding =
        prefs.getBool('has_seen_investment_onboarding') ?? false;
    _isFirstTimeInvestmentVisit =
        prefs.getBool('first_time_investment_visit') ?? true;
    notifyListeners();

    // Load data
    await fetchInvestmentPlans();
    await fetchUserInvestments();
  }

  /// Set the flag indicating this is the first time the user is visiting the investment tab
  Future<void> setFirstTimeInvestmentVisit() async {
    _isFirstTimeInvestmentVisit = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time_investment_visit', true);
    notifyListeners();
  }

  /// Set the user has seen the investment onboarding
  Future<void> setHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_investment_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  /// Fetch investment plans
  Future<void> fetchInvestmentPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load investment plans from JSON data
      _investmentPlans = await InvestmentDataService.loadInvestmentPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Fetch user investments
  Future<void> fetchUserInvestments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load user investments from JSON data
      final investmentData = await InvestmentDataService.loadUserInvestments();
      _userInvestments = investmentData.investments;
      _investmentSummary = investmentData.summary;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get investment plan by ID
  Future<InvestmentPlan?> getInvestmentPlanById(String planId) async {
    return await InvestmentDataService.getInvestmentPlanById(planId);
  }

  /// Get user investment by ID
  Future<Investment?> getUserInvestmentById(String investmentId) async {
    return await InvestmentDataService.getUserInvestmentById(investmentId);
  }

  /// Calculate potential returns for an investment plan
  Future<PotentialReturns> calculatePotentialReturns({
    required String planId,
    required double amount,
    required int durationMonths,
  }) async {
    return await InvestmentDataService.calculatePotentialReturns(
      planId: planId,
      amount: amount,
      durationMonths: durationMonths,
    );
  }

  /// Create a new investment
  Future<bool> createInvestment({
    required String planId,
    required double amount,
    required int durationMonths,
    required bool isRecurring,
    dynamic recurringDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would make an API call to create the investment
      // For now, we'll simulate a successful creation
      await Future.delayed(const Duration(seconds: 2));

      // Refresh user investments to include the new one
      await fetchUserInvestments();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Add funds to an investment
  Future<bool> addFunds({
    required String investmentId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would make an API call to add funds
      // For now, we'll simulate a successful operation
      await Future.delayed(const Duration(seconds: 2));

      // Refresh user investments to reflect the changes
      await fetchUserInvestments();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Withdraw funds from an investment
  Future<bool> withdrawFunds({
    required String investmentId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would make an API call to withdraw funds
      // For now, we'll simulate a successful operation
      await Future.delayed(const Duration(seconds: 2));

      // Refresh user investments to reflect the changes
      await fetchUserInvestments();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel an investment
  Future<bool> cancelInvestment(String investmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would make an API call to cancel the investment
      // For now, we'll simulate a successful operation
      await Future.delayed(const Duration(seconds: 2));

      // Refresh user investments to reflect the changes
      await fetchUserInvestments();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
