import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:golden_wallet/features/investment/models/investment_model.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';

/// Service for loading investment data from JSON files
class InvestmentDataService {
  /// Load investment plans from JSON file
  static Future<List<InvestmentPlan>> loadInvestmentPlans() async {
    try {
      final String plansJson = await rootBundle
          .loadString('lib/features/investment/data/investment_plans.json');
      final plansData = json.decode(plansJson);

      final List<InvestmentPlan> plans = (plansData['investmentPlans'] as List)
          .map((item) => InvestmentPlan.fromJson(item))
          .toList();

      return plans;
    } catch (e) {
      // Return empty list if JSON file is not available
      return [];
    }
  }

  /// Load user investments from JSON file
  static Future<UserInvestmentData> loadUserInvestments() async {
    try {
      final String investmentsJson = await rootBundle
          .loadString('lib/features/investment/data/user_investments.json');
      final investmentsData = json.decode(investmentsJson);

      final List<Investment> investments =
          (investmentsData['userInvestments'] as List)
              .map((item) => Investment.fromJson(item))
              .toList();

      final investmentSummary =
          InvestmentSummary.fromJson(investmentsData['investmentSummary']);

      return UserInvestmentData(
        investments: investments,
        summary: investmentSummary,
      );
    } catch (e) {
      // Return empty data if JSON file is not available
      return UserInvestmentData(
        investments: [],
        summary: InvestmentSummary(
          totalInvested: 0,
          currentValue: 0,
          totalReturns: 0,
          returnRate: 0,
          totalGoldWeight: {},
          activePlans: 0,
          pendingPlans: 0,
          completedPlans: 0,
        ),
      );
    }
  }

  /// Get investment plan by ID
  static Future<InvestmentPlan?> getInvestmentPlanById(String id) async {
    final plans = await loadInvestmentPlans();
    return plans.where((plan) => plan.id == id).firstOrNull;
  }

  /// Get user investment by ID
  static Future<Investment?> getUserInvestmentById(String id) async {
    final investmentData = await loadUserInvestments();
    return investmentData.investments.where((inv) => inv.id == id).firstOrNull;
  }

  /// Get active investment plans
  static Future<List<InvestmentPlan>> getActiveInvestmentPlans() async {
    final plans = await loadInvestmentPlans();
    return plans.where((plan) => plan.isActive).toList();
  }

  /// Get user's active investments
  static Future<List<Investment>> getActiveInvestments() async {
    final investmentData = await loadUserInvestments();
    return investmentData.investments
        .where((inv) => inv.status == InvestmentStatus.active)
        .toList();
  }

  /// Calculate potential returns for an investment plan
  static Future<PotentialReturns> calculatePotentialReturns({
    required String planId,
    required double amount,
    required int durationMonths,
  }) async {
    final plan = await getInvestmentPlanById(planId);

    if (plan == null) {
      throw Exception('Investment plan not found');
    }

    // Calculate potential returns based on plan parameters
    final minReturn =
        amount * (plan.expectedReturns.min / 100) * (durationMonths / 12);
    final maxReturn =
        amount * (plan.expectedReturns.max / 100) * (durationMonths / 12);

    // Calculate gold allocation
    final Map<String, double> goldAllocation = {};
    plan.goldAllocation.forEach((karat, percentage) {
      // Convert percentage to actual gold weight
      // This is a simplified calculation - in a real app, this would be based on current gold prices
      final goldPrice = karat == '24K'
          ? 72.0
          : karat == '22K'
              ? 66.0
              : 54.0; // Example prices per gram
      final goldWeight = (amount * (percentage / 100)) / goldPrice;
      goldAllocation[karat] = goldWeight;
    });

    return PotentialReturns(
      initialInvestment: amount,
      minReturn: minReturn,
      maxReturn: maxReturn,
      minTotalValue: amount + minReturn,
      maxTotalValue: amount + maxReturn,
      durationMonths: durationMonths,
      goldAllocation: goldAllocation,
    );
  }
}

/// Model for user investment data
class UserInvestmentData {
  final List<Investment> investments;
  final InvestmentSummary summary;

  const UserInvestmentData({
    required this.investments,
    required this.summary,
  });
}

/// Model for potential investment returns
class PotentialReturns {
  final double initialInvestment;
  final double minReturn;
  final double maxReturn;
  final double minTotalValue;
  final double maxTotalValue;
  final int durationMonths;
  final Map<String, double> goldAllocation;

  const PotentialReturns({
    required this.initialInvestment,
    required this.minReturn,
    required this.maxReturn,
    required this.minTotalValue,
    required this.maxTotalValue,
    required this.durationMonths,
    required this.goldAllocation,
  });
}
