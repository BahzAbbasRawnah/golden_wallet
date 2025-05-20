import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';

/// Provider to manage investment data
class InvestmentProvider extends ChangeNotifier {
  List<InvestmentPlanModel> _investmentPlans = [];
  List<UserInvestmentModel> _userInvestments = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSeenOnboarding = false;
  bool _isFirstTimeInvestmentVisit = false;

  /// Get all investment plans
  List<InvestmentPlanModel> get investmentPlans => _investmentPlans;

  /// Get active investment plans
  List<InvestmentPlanModel> get activeInvestmentPlans =>
      _investmentPlans.where((plan) => plan.isActive).toList();

  /// Get all user investments
  List<UserInvestmentModel> get userInvestments => _userInvestments;

  /// Get active user investments
  List<UserInvestmentModel> get activeUserInvestments => _userInvestments
      .where((investment) =>
          investment.status == InvestmentStatus.active ||
          investment.status == InvestmentStatus.pending)
      .toList();

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
        prefs.getBool('first_time_investment_visit') ?? false;
    notifyListeners();
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock investment plans data
      _investmentPlans = _generateMockInvestmentPlans();

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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock user investments data
      _userInvestments = _generateMockUserInvestments();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get investment plan by ID
  InvestmentPlanModel? getInvestmentPlanById(String planId) {
    try {
      return _investmentPlans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  /// Get user investment by ID
  UserInvestmentModel? getUserInvestmentById(String investmentId) {
    try {
      return _userInvestments
          .firstWhere((investment) => investment.id == investmentId);
    } catch (e) {
      return null;
    }
  }

  /// Create a new investment
  Future<bool> createInvestment({
    required String planId,
    required double amount,
    required int durationMonths,
    required bool isRecurring,
    RecurringInvestmentDetails? recurringDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Get the plan
      final plan = getInvestmentPlanById(planId);
      if (plan == null) {
        throw Exception('Investment plan not found');
      }

      // Validate amount
      if (amount < plan.minAmount) {
        throw Exception('Amount is less than the minimum required');
      }
      if (plan.maxAmount != null && amount > plan.maxAmount!) {
        throw Exception('Amount is more than the maximum allowed');
      }

      // Validate duration
      if (durationMonths < plan.minDurationMonths) {
        throw Exception('Duration is less than the minimum required');
      }
      if (plan.maxDurationMonths != null &&
          durationMonths > plan.maxDurationMonths!) {
        throw Exception('Duration is more than the maximum allowed');
      }

      // Create new investment
      final now = DateTime.now();
      final newInvestment = UserInvestmentModel(
        id: 'inv_${now.millisecondsSinceEpoch}',
        userId: 'user123', // Mock user ID
        planId: planId,
        amount: amount,
        durationMonths: durationMonths,
        startDate: now,
        endDate: now.add(Duration(days: durationMonths * 30)),
        status: InvestmentStatus.active,
        currentValue: amount,
        returnPercentage: 0.0,
        isRecurring: isRecurring,
        recurringDetails: recurringDetails,
        transactions: [
          InvestmentTransaction(
            id: 'tr_${now.millisecondsSinceEpoch}',
            investmentId: 'inv_${now.millisecondsSinceEpoch}',
            type: 'deposit',
            amount: amount,
            date: now,
          ),
        ],
      );

      _userInvestments.add(newInvestment);

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

  /// Add funds to an existing investment
  Future<bool> addFunds({
    required String investmentId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Find the investment
      final index = _userInvestments
          .indexWhere((investment) => investment.id == investmentId);
      if (index == -1) {
        throw Exception('Investment not found');
      }

      // Update the investment
      final investment = _userInvestments[index];
      final now = DateTime.now();

      // Create a new transaction
      final newTransaction = InvestmentTransaction(
        id: 'tr_${now.millisecondsSinceEpoch}',
        investmentId: investmentId,
        type: 'deposit',
        amount: amount,
        date: now,
      );

      // Update the investment with the new transaction and amount
      _userInvestments[index] = investment.copyWith(
        amount: investment.amount + amount,
        currentValue: investment.currentValue + amount,
        transactions: [...investment.transactions, newTransaction],
      );

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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Find the investment
      final index = _userInvestments
          .indexWhere((investment) => investment.id == investmentId);
      if (index == -1) {
        throw Exception('Investment not found');
      }

      // Update the investment
      final investment = _userInvestments[index];

      // Validate amount
      if (amount > investment.currentValue) {
        throw Exception('Withdrawal amount exceeds current value');
      }

      final now = DateTime.now();

      // Create a new transaction
      final newTransaction = InvestmentTransaction(
        id: 'tr_${now.millisecondsSinceEpoch}',
        investmentId: investmentId,
        type: 'withdrawal',
        amount: -amount,
        date: now,
      );

      // Update the investment with the new transaction and amount
      _userInvestments[index] = investment.copyWith(
        currentValue: investment.currentValue - amount,
        transactions: [...investment.transactions, newTransaction],
      );

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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Find the investment
      final index = _userInvestments
          .indexWhere((investment) => investment.id == investmentId);
      if (index == -1) {
        throw Exception('Investment not found');
      }

      // Update the investment status
      final investment = _userInvestments[index];
      _userInvestments[index] = investment.copyWith(
        status: InvestmentStatus.cancelled,
        endDate: DateTime.now(),
      );

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

  /// Generate mock investment plans for testing
  List<InvestmentPlanModel> _generateMockInvestmentPlans() {
    return [
      InvestmentPlanModel(
        id: 'plan_1',
        name: 'Gold Secure',
        description:
            'A low-risk investment plan with stable returns. Ideal for conservative investors looking for steady growth.',
        type: InvestmentPlanType.fixed,
        riskLevel: RiskLevel.low,
        minAmount: 500,
        maxAmount: 50000,
        expectedReturnsPercentage: 5.5,
        minDurationMonths: 12,
        maxDurationMonths: 60,
        managementFeePercentage: 0.5,
        historicalPerformance: _generateHistoricalPerformance(5.5, 0.5),
        isActive: true,
      ),
      InvestmentPlanModel(
        id: 'plan_2',
        name: 'Gold Growth',
        description:
            'A balanced investment plan with moderate risk and higher potential returns. Suitable for investors with a medium-term horizon.',
        type: InvestmentPlanType.flexible,
        riskLevel: RiskLevel.medium,
        minAmount: 1000,
        maxAmount: 100000,
        expectedReturnsPercentage: 8.0,
        minDurationMonths: 24,
        maxDurationMonths: 120,
        managementFeePercentage: 0.75,
        historicalPerformance: _generateHistoricalPerformance(8.0, 1.2),
        isActive: true,
      ),
      InvestmentPlanModel(
        id: 'plan_3',
        name: 'Gold Premium',
        description:
            'A high-risk, high-reward investment plan for aggressive investors seeking maximum returns over the long term.',
        type: InvestmentPlanType.fixed,
        riskLevel: RiskLevel.high,
        minAmount: 5000,
        expectedReturnsPercentage: 12.0,
        minDurationMonths: 36,
        managementFeePercentage: 1.0,
        historicalPerformance: _generateHistoricalPerformance(12.0, 2.5),
        isActive: true,
      ),
      InvestmentPlanModel(
        id: 'plan_4',
        name: 'Gold SIP',
        description:
            'A systematic investment plan allowing regular contributions to build wealth over time. Perfect for long-term financial goals.',
        type: InvestmentPlanType.sip,
        riskLevel: RiskLevel.low,
        minAmount: 100,
        maxAmount: 10000,
        expectedReturnsPercentage: 7.0,
        minDurationMonths: 12,
        managementFeePercentage: 0.5,
        historicalPerformance: _generateHistoricalPerformance(7.0, 0.8),
        isActive: true,
      ),
    ];
  }

  /// Generate mock historical performance data
  List<HistoricalPerformance> _generateHistoricalPerformance(
      double baseReturn, double volatility) {
    final now = DateTime.now();
    final result = <HistoricalPerformance>[];

    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final randomFactor =
          (DateTime.now().millisecondsSinceEpoch % 100) / 100 * volatility * 2 -
              volatility;
      final returnPercentage = baseReturn + randomFactor;

      result.add(HistoricalPerformance(
        date: date,
        returnPercentage: double.parse(returnPercentage.toStringAsFixed(2)),
      ));
    }

    return result;
  }

  /// Generate mock user investments for testing
  List<UserInvestmentModel> _generateMockUserInvestments() {
    final now = DateTime.now();

    return [
      UserInvestmentModel(
        id: 'inv_1',
        userId: 'user123',
        planId: 'plan_1',
        amount: 5000,
        durationMonths: 24,
        startDate: now.subtract(const Duration(days: 180)),
        status: InvestmentStatus.active,
        currentValue: 5250,
        returnPercentage: 5.0,
        isRecurring: false,
        transactions: [
          InvestmentTransaction(
            id: 'tr_1',
            investmentId: 'inv_1',
            type: 'deposit',
            amount: 5000,
            date: now.subtract(const Duration(days: 180)),
          ),
          InvestmentTransaction(
            id: 'tr_2',
            investmentId: 'inv_1',
            type: 'interest',
            amount: 250,
            date: now.subtract(const Duration(days: 30)),
          ),
        ],
      ),
      UserInvestmentModel(
        id: 'inv_2',
        userId: 'user123',
        planId: 'plan_2',
        amount: 10000,
        durationMonths: 36,
        startDate: now.subtract(const Duration(days: 90)),
        status: InvestmentStatus.active,
        currentValue: 10200,
        returnPercentage: 2.0,
        isRecurring: true,
        recurringDetails: RecurringInvestmentDetails(
          frequency: 'monthly',
          day: 15,
          amount: 500,
          nextInvestmentDate: DateTime(now.year, now.month + 1, 15),
        ),
        transactions: [
          InvestmentTransaction(
            id: 'tr_3',
            investmentId: 'inv_2',
            type: 'deposit',
            amount: 10000,
            date: now.subtract(const Duration(days: 90)),
          ),
          InvestmentTransaction(
            id: 'tr_4',
            investmentId: 'inv_2',
            type: 'interest',
            amount: 200,
            date: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),
    ];
  }
}
