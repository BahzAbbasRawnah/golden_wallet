import 'package:golden_wallet/features/investment/models/investment_plan.dart';

/// Enum representing different investment statuses
enum InvestmentStatus {
  pending,
  active,
  completed,
  cancelled,
}

/// Extension to provide additional functionality to InvestmentStatus enum
extension InvestmentStatusExtension on InvestmentStatus {
  /// Get the translation key for the investment status
  String get translationKey {
    switch (this) {
      case InvestmentStatus.pending:
        return 'investmentStatusPending';
      case InvestmentStatus.active:
        return 'investmentStatusActive';
      case InvestmentStatus.completed:
        return 'investmentStatusCompleted';
      case InvestmentStatus.cancelled:
        return 'investmentStatusCancelled';
    }
  }
  
  /// Get the investment status from a string value
  static InvestmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return InvestmentStatus.pending;
      case 'active':
        return InvestmentStatus.active;
      case 'completed':
        return InvestmentStatus.completed;
      case 'cancelled':
        return InvestmentStatus.cancelled;
      default:
        return InvestmentStatus.pending;
    }
  }
}

/// Model representing an investment transaction
class InvestmentTransaction {
  final String id;
  final DateTime date;
  final String type;
  final double amount;
  final String description;
  
  const InvestmentTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
  });
  
  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      amount: json['amount'].toDouble(),
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'description': description,
    };
  }
}

/// Model representing a user's investment
class Investment {
  final String id;
  final String planId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double initialInvestment;
  final double currentValue;
  final String currency;
  final InvestmentStatus status;
  final double returnRate;
  final PaymentFrequency paymentFrequency;
  final DateTime nextPaymentDate;
  final List<InvestmentTransaction> transactions;
  final Map<String, double> goldAllocation;
  final String? notes;
  
  const Investment({
    required this.id,
    required this.planId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.initialInvestment,
    required this.currentValue,
    required this.currency,
    required this.status,
    required this.returnRate,
    required this.paymentFrequency,
    required this.nextPaymentDate,
    required this.transactions,
    required this.goldAllocation,
    this.notes,
  });
  
  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      planId: json['planId'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      initialInvestment: json['initialInvestment'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      currency: json['currency'],
      status: InvestmentStatusExtension.fromString(json['status']),
      returnRate: json['returnRate'].toDouble(),
      paymentFrequency: PaymentFrequencyExtension.fromString(json['paymentFrequency']),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
      transactions: (json['transactions'] as List)
          .map((item) => InvestmentTransaction.fromJson(item))
          .toList(),
      goldAllocation: Map<String, double>.from(json['goldAllocation']),
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'initialInvestment': initialInvestment,
      'currentValue': currentValue,
      'currency': currency,
      'status': status.name,
      'returnRate': returnRate,
      'paymentFrequency': paymentFrequency.name,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'goldAllocation': goldAllocation,
      'notes': notes,
    };
  }
}

/// Model representing an investment summary
class InvestmentSummary {
  final double totalInvested;
  final double currentValue;
  final double totalReturns;
  final double returnRate;
  final Map<String, double> totalGoldWeight;
  final int activePlans;
  final int pendingPlans;
  final int completedPlans;
  
  const InvestmentSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalReturns,
    required this.returnRate,
    required this.totalGoldWeight,
    required this.activePlans,
    required this.pendingPlans,
    required this.completedPlans,
  });
  
  factory InvestmentSummary.fromJson(Map<String, dynamic> json) {
    return InvestmentSummary(
      totalInvested: json['totalInvested'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      totalReturns: json['totalReturns'].toDouble(),
      returnRate: json['returnRate'].toDouble(),
      totalGoldWeight: Map<String, double>.from(json['totalGoldWeight']),
      activePlans: json['activePlans'],
      pendingPlans: json['pendingPlans'],
      completedPlans: json['completedPlans'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'totalReturns': totalReturns,
      'returnRate': returnRate,
      'totalGoldWeight': totalGoldWeight,
      'activePlans': activePlans,
      'pendingPlans': pendingPlans,
      'completedPlans': completedPlans,
    };
  }
}
