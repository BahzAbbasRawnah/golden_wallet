import 'package:flutter/material.dart';

/// Enum representing different gold categories
enum GoldCategory {
  grams,
  pounds,
  bars,
}

/// Extension to provide additional functionality to GoldCategory enum
extension GoldCategoryExtension on GoldCategory {
  /// Get the translation key for the category
  String get translationKey {
    switch (this) {
      case GoldCategory.grams:
        return 'gold_grams';
      case GoldCategory.pounds:
        return 'gold_pounds';
      case GoldCategory.bars:
        return 'gold_bars';
    }
  }
  
  /// Get the icon for the category
  IconData get icon {
    switch (this) {
      case GoldCategory.grams:
        return Icons.scale;
      case GoldCategory.pounds:
        return Icons.monetization_on;
      case GoldCategory.bars:
        return Icons.view_module;
    }
  }
}

/// Model for gold gram types
class GoldGramType {
  final String karat;
  final String translationKey;
  final double purity;
  
  const GoldGramType({
    required this.karat,
    required this.translationKey,
    required this.purity,
  });
  
  /// Get the price multiplier based on purity
  double get priceMultiplier => purity;
}

/// List of available gold gram types
final List<GoldGramType> goldGramTypes = [
  const GoldGramType(
    karat: '18K',
    translationKey: 'gold_18k',
    purity: 0.750,
  ),
  const GoldGramType(
    karat: '20K',
    translationKey: 'gold_20k',
    purity: 0.833,
  ),
  const GoldGramType(
    karat: '21K',
    translationKey: 'gold_21k',
    purity: 0.875,
  ),
  const GoldGramType(
    karat: '24K',
    translationKey: 'gold_24k',
    purity: 0.999,
  ),
];

/// Model for gold pound weights
class GoldPoundWeight {
  final double grams;
  final String translationKey;
  
  const GoldPoundWeight({
    required this.grams,
    required this.translationKey,
  });
}

/// List of available gold pound weights
final List<GoldPoundWeight> goldPoundWeights = [
  const GoldPoundWeight(
    grams: 1.0,
    translationKey: 'pound_1g',
  ),
  const GoldPoundWeight(
    grams: 2.0,
    translationKey: 'pound_2g',
  ),
  const GoldPoundWeight(
    grams: 4.0,
    translationKey: 'pound_4g',
  ),
  const GoldPoundWeight(
    grams: 8.0,
    translationKey: 'pound_8g',
  ),
];

/// Model for payment method
class PaymentMethod {
  final String id;
  final String translationKey;
  final IconData icon;
  
  const PaymentMethod({
    required this.id,
    required this.translationKey,
    required this.icon,
  });
}

/// List of available payment methods
final List<PaymentMethod> paymentMethods = [
  const PaymentMethod(
    id: 'wallet',
    translationKey: 'wallet_payment',
    icon: Icons.account_balance_wallet,
  ),
  const PaymentMethod(
    id: 'cash',
    translationKey: 'cash_transfer',
    icon: Icons.payments,
  ),
];
