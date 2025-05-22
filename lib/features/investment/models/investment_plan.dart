import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';

/// Enum representing different risk levels
enum RiskLevel {
  very_low,
  low,
  medium,
  high,
  very_high,
}

/// Extension to provide additional functionality to RiskLevel enum
extension RiskLevelExtension on RiskLevel {
  /// Get the translation key for the risk level
  String get translationKey {
    switch (this) {
      case RiskLevel.very_low:
        return 'riskLevelVeryLow';
      case RiskLevel.low:
        return 'riskLevelLow';
      case RiskLevel.medium:
        return 'riskLevelMedium';
      case RiskLevel.high:
        return 'riskLevelHigh';
      case RiskLevel.very_high:
        return 'riskLevelVeryHigh';
    }
  }
  
  /// Get the color for the risk level
  Color get color {
    switch (this) {
      case RiskLevel.very_low:
        return Colors.green.shade300;
      case RiskLevel.low:
        return AppTheme.successColor;
      case RiskLevel.medium:
        return AppTheme.warningColor;
      case RiskLevel.high:
        return AppTheme.errorColor;
      case RiskLevel.very_high:
        return Colors.red.shade900;
    }
  }
  
  /// Get the risk level from a string value
  static RiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'very_low':
        return RiskLevel.very_low;
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      case 'very_high':
        return RiskLevel.very_high;
      default:
        return RiskLevel.medium;
    }
  }
}

/// Enum representing different payment frequencies
enum PaymentFrequency {
  one_time,
  monthly,
  quarterly,
  semi_annually,
  annually,
}

/// Extension to provide additional functionality to PaymentFrequency enum
extension PaymentFrequencyExtension on PaymentFrequency {
  /// Get the translation key for the payment frequency
  String get translationKey {
    switch (this) {
      case PaymentFrequency.one_time:
        return 'paymentFrequencyOneTime';
      case PaymentFrequency.monthly:
        return 'paymentFrequencyMonthly';
      case PaymentFrequency.quarterly:
        return 'paymentFrequencyQuarterly';
      case PaymentFrequency.semi_annually:
        return 'paymentFrequencySemiAnnually';
      case PaymentFrequency.annually:
        return 'paymentFrequencyAnnually';
    }
  }
  
  /// Get the payment frequency from a string value
  static PaymentFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'one_time':
        return PaymentFrequency.one_time;
      case 'monthly':
        return PaymentFrequency.monthly;
      case 'quarterly':
        return PaymentFrequency.quarterly;
      case 'semi_annually':
        return PaymentFrequency.semi_annually;
      case 'annually':
        return PaymentFrequency.annually;
      default:
        return PaymentFrequency.monthly;
    }
  }
}

/// Model representing a duration range
class DurationRange {
  final int min;
  final int max;
  final String unit;
  
  const DurationRange({
    required this.min,
    required this.max,
    required this.unit,
  });
  
  factory DurationRange.fromJson(Map<String, dynamic> json) {
    return DurationRange(
      min: json['min'],
      max: json['max'],
      unit: json['unit'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'unit': unit,
    };
  }
}

/// Model representing an expected returns range
class ReturnsRange {
  final double min;
  final double max;
  final String unit;
  
  const ReturnsRange({
    required this.min,
    required this.max,
    required this.unit,
  });
  
  factory ReturnsRange.fromJson(Map<String, dynamic> json) {
    return ReturnsRange(
      min: json['min'].toDouble(),
      max: json['max'].toDouble(),
      unit: json['unit'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'unit': unit,
    };
  }
}

/// Model representing an investment plan
class InvestmentPlan {
  final String id;
  final String name;
  final String description;
  final double minInvestment;
  final String currency;
  final DurationRange duration;
  final ReturnsRange expectedReturns;
  final RiskLevel riskLevel;
  final List<String> features;
  final Map<String, int> goldAllocation;
  final PaymentFrequency paymentFrequency;
  final bool isActive;
  final DateTime createdAt;
  final List<String> tags;
  
  const InvestmentPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.minInvestment,
    required this.currency,
    required this.duration,
    required this.expectedReturns,
    required this.riskLevel,
    required this.features,
    required this.goldAllocation,
    required this.paymentFrequency,
    required this.isActive,
    required this.createdAt,
    required this.tags,
  });
  
  factory InvestmentPlan.fromJson(Map<String, dynamic> json) {
    return InvestmentPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      minInvestment: json['minInvestment'].toDouble(),
      currency: json['currency'],
      duration: DurationRange.fromJson(json['duration']),
      expectedReturns: ReturnsRange.fromJson(json['expectedReturns']),
      riskLevel: RiskLevelExtension.fromString(json['riskLevel']),
      features: List<String>.from(json['features']),
      goldAllocation: Map<String, int>.from(json['goldAllocation']),
      paymentFrequency: PaymentFrequencyExtension.fromString(json['paymentFrequency']),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'minInvestment': minInvestment,
      'currency': currency,
      'duration': duration.toJson(),
      'expectedReturns': expectedReturns.toJson(),
      'riskLevel': riskLevel.name,
      'features': features,
      'goldAllocation': goldAllocation,
      'paymentFrequency': paymentFrequency.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}
