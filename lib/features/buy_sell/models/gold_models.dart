import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Enum representing different gold units
enum GoldUnit { gram, pound, bar }

/// Enum representing different gold categories
enum GoldCategory {
  grams,
  pounds,
  bars,
}

/// Model for gold type (karat)
class GoldKarat {
  final String id;
  final String karat;
  final String name;
  final String? description;

  const GoldKarat({
    required this.id,
    required this.karat,
    required this.name,
    this.description,
  });

  factory GoldKarat.fromJson(Map<String, dynamic> json) {
    return GoldKarat(
      id: json['id'],
      karat: json['karat'],
      name: json['name'],
      description: json['description'],
    );
  }
}

/// Model for gold category data
class GoldCategoryData {
  final String id;
  final String name;
  final IconData? icon;
  final String? description;

  const GoldCategoryData({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  factory GoldCategoryData.fromJson(Map<String, dynamic> json) {
    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'scale':
          return Icons.scale;
        case 'monetization_on':
          return Icons.monetization_on;
        case 'view_module':
          return Icons.view_module;
        case 'account_balance_wallet':
          return Icons.account_balance_wallet;
        case 'payments':
          return Icons.payments;
        case 'account_balance':
          return Icons.account_balance;
        case 'credit_card':
          return Icons.credit_card;
        default:
          return Icons.circle;
      }
    }

    return GoldCategoryData(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] != null ? getIconData(json['icon']) : null,
      description: json['description'],
    );
  }
}

/// Model for gold bar
class GoldBar {
  final String id;
  final String name;
  final double grams;
  final String? description;

  const GoldBar({
    required this.id,
    required this.name,
    required this.grams,
    this.description,
  });

  factory GoldBar.fromJson(Map<String, dynamic> json) {
    return GoldBar(
      id: json['id'],
      name: json['name'],
      grams: json['grams'],
      description: json['description'],
    );
  }
}

/// Model for payment method
class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'account_balance_wallet':
          return Icons.account_balance_wallet;
        case 'payments':
          return Icons.payments;
        case 'account_balance':
          return Icons.account_balance;
        case 'credit_card':
          return Icons.credit_card;
        case 'currency_bitcoin':
          return Icons.currency_bitcoin;
        default:
          return Icons.payment;
      }
    }

    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      icon: getIconData(json['icon']),
      description: json['description'],
    );
  }
}

/// Model for gold price
class GoldPrice {
  final double buy;
  final double sell;

  const GoldPrice({
    required this.buy,
    required this.sell,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      buy: json['buy'].toDouble(),
      sell: json['sell'].toDouble(),
    );
  }
}

/// Model for gold price history
class GoldPriceHistory {
  final DateTime date;
  final Map<String, GoldPrice> prices;

  const GoldPriceHistory({
    required this.date,
    required this.prices,
  });

  factory GoldPriceHistory.fromJson(Map<String, dynamic> json) {
    Map<String, GoldPrice> priceMap = {};
    json.forEach((key, value) {
      if (key != 'date') {
        priceMap[key] = GoldPrice.fromJson(value);
      }
    });

    return GoldPriceHistory(
      date: DateTime.parse(json['date']),
      prices: priceMap,
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy', 'en_US').format(date.toLocal());
  }
}

/// Service for loading gold data
class GoldDataService {
  static Future<Map<String, dynamic>> loadGoldData() async {
    final String goldDataJson = await rootBundle
        .loadString('lib/features/buy_sell/data/gold_data.json');
    final goldData = json.decode(goldDataJson);

    final List<GoldCategoryData> categories =
        (goldData['goldCategories'] as List)
            .map((item) => GoldCategoryData.fromJson(item))
            .toList();

    final List<GoldKarat> goldKarats = (goldData['goldKarats'] as List)
        .map((item) => GoldKarat.fromJson(item))
        .toList();

    final List<GoldBar> goldBars = (goldData['goldBars'] as List)
        .map((item) => GoldBar.fromJson(item))
        .toList();

    final List<PaymentMethod> paymentMethods =
        (goldData['paymentMethods'] as List)
            .map((item) => PaymentMethod.fromJson(item))
            .toList();

    return {
      'categories': categories,
      'goldKarats': goldKarats,
      'goldBars': goldBars,
      'paymentMethods': paymentMethods,
    };
  }

  static Future<GoldPriceData> loadGoldPrices() async {
    final String goldPricesJson = await rootBundle
        .loadString('lib/features/buy_sell/data/gold_prices.json');
    final goldPrices = json.decode(goldPricesJson);

    return GoldPriceData.fromJson(goldPrices);
  }
}

/// Model for gold price data
class GoldPriceData {
  final DateTime lastUpdated;
  final String currency;
  final Map<String, GoldPrice> basePricePerGram;
  final List<GoldPriceHistory> priceHistory;

  const GoldPriceData({
    required this.lastUpdated,
    required this.currency,
    required this.basePricePerGram,
    required this.priceHistory,
  });

  factory GoldPriceData.fromJson(Map<String, dynamic> json) {
    Map<String, GoldPrice> prices = {};
    (json['basePricePerGram'] as Map<String, dynamic>).forEach((key, value) {
      prices[key] = GoldPrice.fromJson(value);
    });

    return GoldPriceData(
      lastUpdated: DateTime.parse(json['lastUpdated']),
      currency: json['currency'] ?? 'AED',
      basePricePerGram: prices,
      priceHistory: (json['priceHistory'] as List)
          .map((item) => GoldPriceHistory.fromJson(item))
          .toList(),
    );
  }

  String get formattedLastUpdated {
    return DateFormat('MMM dd, yyyy HH:mm', 'en_US')
        .format(lastUpdated.toLocal());
  }
}
