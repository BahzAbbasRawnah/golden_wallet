import 'package:flutter/material.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/theme.dart';

/// Enum representing different investment plan types
enum InvestmentPlanType {
  fixed,
  flexible,
  sip,
}

/// Extension to provide additional functionality to InvestmentPlanType enum
extension InvestmentPlanTypeExtension on InvestmentPlanType {
  /// Get the translation key for the investment plan type
  String get translationKey {
    switch (this) {
      case InvestmentPlanType.fixed:
        return 'investmentTypeFixed';
      case InvestmentPlanType.flexible:
        return 'investmentTypeFlexible';
      case InvestmentPlanType.sip:
        return 'investmentTypeSIP';
    }
  }
  
  /// Get the icon for the investment plan type
  IconData get icon {
    switch (this) {
      case InvestmentPlanType.fixed:
        return Icons.lock_outline;
      case InvestmentPlanType.flexible:
        return Icons.autorenew;
      case InvestmentPlanType.sip:
        return Icons.calendar_today;
    }
  }
  
  /// Get the string value of the investment plan type
  String get value {
    switch (this) {
      case InvestmentPlanType.fixed:
        return AppConstants.investmentTypeFixed;
      case InvestmentPlanType.flexible:
        return AppConstants.investmentTypeFlexible;
      case InvestmentPlanType.sip:
        return AppConstants.investmentTypeSIP;
    }
  }
  
  /// Get the investment plan type from a string value
  static InvestmentPlanType fromString(String value) {
    switch (value) {
      case AppConstants.investmentTypeFixed:
        return InvestmentPlanType.fixed;
      case AppConstants.investmentTypeFlexible:
        return InvestmentPlanType.flexible;
      case AppConstants.investmentTypeSIP:
        return InvestmentPlanType.sip;
      default:
        return InvestmentPlanType.fixed;
    }
  }
}

/// Enum representing different risk levels
enum RiskLevel {
  low,
  medium,
  high,
}

/// Extension to provide additional functionality to RiskLevel enum
extension RiskLevelExtension on RiskLevel {
  /// Get the translation key for the risk level
  String get translationKey {
    switch (this) {
      case RiskLevel.low:
        return 'riskLevelLow';
      case RiskLevel.medium:
        return 'riskLevelMedium';
      case RiskLevel.high:
        return 'riskLevelHigh';
    }
  }
  
  /// Get the color for the risk level
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return AppTheme.successColor;
      case RiskLevel.medium:
        return AppTheme.warningColor;
      case RiskLevel.high:
        return AppTheme.errorColor;
    }
  }
  
  /// Get the string value of the risk level
  String get value {
    switch (this) {
      case RiskLevel.low:
        return AppConstants.riskLevelLow;
      case RiskLevel.medium:
        return AppConstants.riskLevelMedium;
      case RiskLevel.high:
        return AppConstants.riskLevelHigh;
    }
  }
  
  /// Get the risk level from a string value
  static RiskLevel fromString(String value) {
    switch (value) {
      case AppConstants.riskLevelLow:
        return RiskLevel.low;
      case AppConstants.riskLevelMedium:
        return RiskLevel.medium;
      case AppConstants.riskLevelHigh:
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }
}

/// Model representing an investment plan
class InvestmentPlanModel {
  final String id;
  final String name;
  final String description;
  final InvestmentPlanType type;
  final RiskLevel riskLevel;
  final double minAmount;
  final double? maxAmount;
  final double expectedReturnsPercentage;
  final int minDurationMonths;
  final int? maxDurationMonths;
  final double managementFeePercentage;
  final List<HistoricalPerformance> historicalPerformance;
  final bool isActive;
  
  const InvestmentPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.riskLevel,
    required this.minAmount,
    this.maxAmount,
    required this.expectedReturnsPercentage,
    required this.minDurationMonths,
    this.maxDurationMonths,
    required this.managementFeePercentage,
    required this.historicalPerformance,
    this.isActive = true,
  });
  
  /// Create a copy of this investment plan with the given fields replaced with the new values
  InvestmentPlanModel copyWith({
    String? id,
    String? name,
    String? description,
    InvestmentPlanType? type,
    RiskLevel? riskLevel,
    double? minAmount,
    double? maxAmount,
    double? expectedReturnsPercentage,
    int? minDurationMonths,
    int? maxDurationMonths,
    double? managementFeePercentage,
    List<HistoricalPerformance>? historicalPerformance,
    bool? isActive,
  }) {
    return InvestmentPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      riskLevel: riskLevel ?? this.riskLevel,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      expectedReturnsPercentage: expectedReturnsPercentage ?? this.expectedReturnsPercentage,
      minDurationMonths: minDurationMonths ?? this.minDurationMonths,
      maxDurationMonths: maxDurationMonths ?? this.maxDurationMonths,
      managementFeePercentage: managementFeePercentage ?? this.managementFeePercentage,
      historicalPerformance: historicalPerformance ?? this.historicalPerformance,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// Create an investment plan from a JSON object
  factory InvestmentPlanModel.fromJson(Map<String, dynamic> json) {
    return InvestmentPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: InvestmentPlanTypeExtension.fromString(json['type'] as String),
      riskLevel: RiskLevelExtension.fromString(json['risk_level'] as String),
      minAmount: json['min_amount'] as double,
      maxAmount: json['max_amount'] as double?,
      expectedReturnsPercentage: json['expected_returns_percentage'] as double,
      minDurationMonths: json['min_duration_months'] as int,
      maxDurationMonths: json['max_duration_months'] as int?,
      managementFeePercentage: json['management_fee_percentage'] as double,
      historicalPerformance: (json['historical_performance'] as List)
          .map((e) => HistoricalPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  
  /// Convert this investment plan to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.value,
      'risk_level': riskLevel.value,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'expected_returns_percentage': expectedReturnsPercentage,
      'min_duration_months': minDurationMonths,
      'max_duration_months': maxDurationMonths,
      'management_fee_percentage': managementFeePercentage,
      'historical_performance': historicalPerformance.map((e) => e.toJson()).toList(),
      'is_active': isActive,
    };
  }
}

/// Model representing historical performance data for an investment plan
class HistoricalPerformance {
  final DateTime date;
  final double returnPercentage;
  
  const HistoricalPerformance({
    required this.date,
    required this.returnPercentage,
  });
  
  /// Create historical performance data from a JSON object
  factory HistoricalPerformance.fromJson(Map<String, dynamic> json) {
    return HistoricalPerformance(
      date: DateTime.parse(json['date'] as String),
      returnPercentage: json['return_percentage'] as double,
    );
  }
  
  /// Convert this historical performance data to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'return_percentage': returnPercentage,
    };
  }
}
