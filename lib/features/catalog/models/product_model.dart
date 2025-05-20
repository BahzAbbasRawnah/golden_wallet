import 'package:flutter/material.dart';
import 'package:golden_wallet/shared/utils/translation_keys.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';

/// Model representing a product in the catalog
class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final double price;
  final double weight;
  final String purity;
  final List<String> images;
  final Map<String, String> specifications;
  final ProductAvailability availability;
  final DateTime createdAt;
  final bool isFeatured;
  final double? discountPercentage;
  final double? makingCharges;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.weight,
    required this.purity,
    required this.images,
    required this.specifications,
    required this.availability,
    required this.createdAt,
    this.isFeatured = false,
    this.discountPercentage,
    this.makingCharges,
  });

  /// Get the discounted price if available
  double get discountedPrice {
    if (discountPercentage == null || discountPercentage == 0) {
      return price;
    }
    return price - (price * discountPercentage! / 100);
  }

  /// Check if the product has a discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Get the total price including making charges
  double get totalPrice {
    double basePrice = hasDiscount ? discountedPrice : price;
    return basePrice + (makingCharges ?? 0);
  }

  /// Create a copy of this product with the given fields replaced with the new values
  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductCategory? category,
    double? price,
    double? weight,
    String? purity,
    List<String>? images,
    Map<String, String>? specifications,
    ProductAvailability? availability,
    DateTime? createdAt,
    bool? isFeatured,
    double? discountPercentage,
    double? makingCharges,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      purity: purity ?? this.purity,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      isFeatured: isFeatured ?? this.isFeatured,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      makingCharges: makingCharges ?? this.makingCharges,
    );
  }

  /// Create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category:
          ProductCategory.fromJson(json['category'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      purity: json['purity'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: Map<String, String>.from(json['specifications'] as Map),
      availability: ProductAvailability.values.firstWhere(
        (e) => e.toString().split('.').last == json['availability'],
        orElse: () => ProductAvailability.inStock,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFeatured: json['isFeatured'] as bool? ?? false,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] as num).toDouble()
          : null,
      makingCharges: json['makingCharges'] != null
          ? (json['makingCharges'] as num).toDouble()
          : null,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toJson(),
      'price': price,
      'weight': weight,
      'purity': purity,
      'images': images,
      'specifications': specifications,
      'availability': availability.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isFeatured': isFeatured,
      'discountPercentage': discountPercentage,
      'makingCharges': makingCharges,
    };
  }
}

/// Enum representing product availability status
enum ProductAvailability {
  inStock,
  lowStock,
  outOfStock,
  preOrder,
  comingSoon,
}

/// Extension to provide additional functionality to ProductAvailability enum
extension ProductAvailabilityExtension on ProductAvailability {
  /// Get the translation key for the availability status
  String get translationKey {
    switch (this) {
      case ProductAvailability.inStock:
        return TranslationKeys.catalogInStock;
      case ProductAvailability.lowStock:
        return TranslationKeys.catalogLowStock;
      case ProductAvailability.outOfStock:
        return TranslationKeys.catalogOutOfStock;
      case ProductAvailability.preOrder:
        return TranslationKeys.catalogPreOrder;
      case ProductAvailability.comingSoon:
        return TranslationKeys.catalogComingSoonStatus;
    }
  }

  /// Get the color for the availability status
  Color get color {
    switch (this) {
      case ProductAvailability.inStock:
        return Colors.green;
      case ProductAvailability.lowStock:
        return Colors.orange;
      case ProductAvailability.outOfStock:
        return Colors.red;
      case ProductAvailability.preOrder:
        return Colors.blue;
      case ProductAvailability.comingSoon:
        return Colors.purple;
    }
  }

  /// Check if the product can be purchased
  bool get canPurchase {
    return this == ProductAvailability.inStock ||
        this == ProductAvailability.lowStock ||
        this == ProductAvailability.preOrder;
  }
}
