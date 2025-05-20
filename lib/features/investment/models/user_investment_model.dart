import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';

/// Enum representing different investment statuses
enum InvestmentStatus {
  active,
  completed,
  cancelled,
  pending,
}

/// Extension to provide additional functionality to InvestmentStatus enum
extension InvestmentStatusExtension on InvestmentStatus {
  /// Get the translation key for the investment status
  String get translationKey {
    switch (this) {
      case InvestmentStatus.active:
        return 'investmentStatusActive';
      case InvestmentStatus.completed:
        return 'investmentStatusCompleted';
      case InvestmentStatus.cancelled:
        return 'investmentStatusCancelled';
      case InvestmentStatus.pending:
        return 'investmentStatusPending';
    }
  }
  
  /// Get the string value of the investment status
  String get value {
    switch (this) {
      case InvestmentStatus.active:
        return 'active';
      case InvestmentStatus.completed:
        return 'completed';
      case InvestmentStatus.cancelled:
        return 'cancelled';
      case InvestmentStatus.pending:
        return 'pending';
    }
  }
  
  /// Get the investment status from a string value
  static InvestmentStatus fromString(String value) {
    switch (value) {
      case 'active':
        return InvestmentStatus.active;
      case 'completed':
        return InvestmentStatus.completed;
      case 'cancelled':
        return InvestmentStatus.cancelled;
      case 'pending':
        return InvestmentStatus.pending;
      default:
        return InvestmentStatus.active;
    }
  }
}

/// Model representing a user's investment
class UserInvestmentModel {
  final String id;
  final String userId;
  final String planId;
  final double amount;
  final int durationMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final InvestmentStatus status;
  final double currentValue;
  final double returnPercentage;
  final bool isRecurring;
  final RecurringInvestmentDetails? recurringDetails;
  final List<InvestmentTransaction> transactions;
  
  const UserInvestmentModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.amount,
    required this.durationMonths,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.currentValue,
    required this.returnPercentage,
    this.isRecurring = false,
    this.recurringDetails,
    required this.transactions,
  });
  
  /// Create a copy of this user investment with the given fields replaced with the new values
  UserInvestmentModel copyWith({
    String? id,
    String? userId,
    String? planId,
    double? amount,
    int? durationMonths,
    DateTime? startDate,
    DateTime? endDate,
    InvestmentStatus? status,
    double? currentValue,
    double? returnPercentage,
    bool? isRecurring,
    RecurringInvestmentDetails? recurringDetails,
    List<InvestmentTransaction>? transactions,
  }) {
    return UserInvestmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      amount: amount ?? this.amount,
      durationMonths: durationMonths ?? this.durationMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      currentValue: currentValue ?? this.currentValue,
      returnPercentage: returnPercentage ?? this.returnPercentage,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDetails: recurringDetails ?? this.recurringDetails,
      transactions: transactions ?? this.transactions,
    );
  }
  
  /// Create a user investment from a JSON object
  factory UserInvestmentModel.fromJson(Map<String, dynamic> json) {
    return UserInvestmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      amount: json['amount'] as double,
      durationMonths: json['duration_months'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: InvestmentStatusExtension.fromString(json['status'] as String),
      currentValue: json['current_value'] as double,
      returnPercentage: json['return_percentage'] as double,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringDetails: json['recurring_details'] != null
          ? RecurringInvestmentDetails.fromJson(json['recurring_details'] as Map<String, dynamic>)
          : null,
      transactions: (json['transactions'] as List)
          .map((e) => InvestmentTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  
  /// Convert this user investment to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'amount': amount,
      'duration_months': durationMonths,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.value,
      'current_value': currentValue,
      'return_percentage': returnPercentage,
      'is_recurring': isRecurring,
      'recurring_details': recurringDetails?.toJson(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }
  
  /// Calculate the progress percentage of the investment duration
  double get progressPercentage {
    if (status == InvestmentStatus.completed) return 100.0;
    if (status == InvestmentStatus.cancelled) return 0.0;
    
    final now = DateTime.now();
    final totalDuration = durationMonths * 30 * 24 * 60 * 60 * 1000; // Convert months to milliseconds
    final elapsedDuration = now.difference(startDate).inMilliseconds;
    
    final progress = (elapsedDuration / totalDuration) * 100;
    return progress.clamp(0.0, 100.0);
  }
  
  /// Calculate the remaining days of the investment
  int get remainingDays {
    if (status == InvestmentStatus.completed || status == InvestmentStatus.cancelled) return 0;
    
    final endDateTime = startDate.add(Duration(days: durationMonths * 30));
    final now = DateTime.now();
    
    if (now.isAfter(endDateTime)) return 0;
    
    return endDateTime.difference(now).inDays;
  }
  
  /// Calculate the profit amount
  double get profitAmount {
    return currentValue - amount;
  }
}

/// Model representing recurring investment details
class RecurringInvestmentDetails {
  final String frequency; // monthly, quarterly, yearly
  final int day; // Day of the month for the recurring investment
  final double amount;
  final DateTime nextInvestmentDate;
  
  const RecurringInvestmentDetails({
    required this.frequency,
    required this.day,
    required this.amount,
    required this.nextInvestmentDate,
  });
  
  /// Create recurring investment details from a JSON object
  factory RecurringInvestmentDetails.fromJson(Map<String, dynamic> json) {
    return RecurringInvestmentDetails(
      frequency: json['frequency'] as String,
      day: json['day'] as int,
      amount: json['amount'] as double,
      nextInvestmentDate: DateTime.parse(json['next_investment_date'] as String),
    );
  }
  
  /// Convert these recurring investment details to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'day': day,
      'amount': amount,
      'next_investment_date': nextInvestmentDate.toIso8601String(),
    };
  }
}

/// Model representing an investment transaction
class InvestmentTransaction {
  final String id;
  final String investmentId;
  final String type; // deposit, withdrawal, interest
  final double amount;
  final DateTime date;
  
  const InvestmentTransaction({
    required this.id,
    required this.investmentId,
    required this.type,
    required this.amount,
    required this.date,
  });
  
  /// Create an investment transaction from a JSON object
  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      id: json['id'] as String,
      investmentId: json['investment_id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }
  
  /// Convert this investment transaction to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investment_id': investmentId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
