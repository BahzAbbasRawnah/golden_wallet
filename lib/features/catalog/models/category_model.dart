import 'package:flutter/material.dart';

/// Model representing a product category in the catalog
class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String? iconName;
  final String? imageUrl;
  final String? parentId;
  final bool isActive;
  
  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconName,
    this.imageUrl,
    this.parentId,
    this.isActive = true,
  });
  
  /// Create a copy of this category with the given fields replaced with the new values
  ProductCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? imageUrl,
    String? parentId,
    bool? isActive,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// Create a ProductCategory from JSON
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  /// Convert ProductCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'isActive': isActive,
    };
  }
  
  /// Get the icon for the category
  IconData getIcon() {
    // Map string icon names to IconData
    switch (iconName) {
      case 'jewelry':
        return Icons.diamond;
      case 'coins':
        return Icons.monetization_on;
      case 'bars':
        return Icons.view_module;
      case 'watches':
        return Icons.watch;
      case 'gifts':
        return Icons.card_giftcard;
      case 'accessories':
        return Icons.accessibility;
      default:
        return Icons.category;
    }
  }
}

/// Predefined product categories
class ProductCategories {
  static const ProductCategory all = ProductCategory(
    id: 'all',
    name: 'All Products',
    description: 'All gold products',
    iconName: 'all',
  );
  
  static const ProductCategory jewelry = ProductCategory(
    id: 'jewelry',
    name: 'Jewelry',
    description: 'Gold jewelry items',
    iconName: 'jewelry',
  );
  
  static const ProductCategory coins = ProductCategory(
    id: 'coins',
    name: 'Coins',
    description: 'Gold coins and collectibles',
    iconName: 'coins',
  );
  
  static const ProductCategory bars = ProductCategory(
    id: 'bars',
    name: 'Gold Bars',
    description: 'Gold bars and bullion',
    iconName: 'bars',
  );
  
  static const ProductCategory watches = ProductCategory(
    id: 'watches',
    name: 'Watches',
    description: 'Luxury gold watches',
    iconName: 'watches',
  );
  
  static const ProductCategory gifts = ProductCategory(
    id: 'gifts',
    name: 'Gift Items',
    description: 'Gold gift items',
    iconName: 'gifts',
  );
  
  static const ProductCategory accessories = ProductCategory(
    id: 'accessories',
    name: 'Accessories',
    description: 'Gold accessories',
    iconName: 'accessories',
  );
  
  /// Get all predefined categories
  static List<ProductCategory> getAll() {
    return [
      all,
      jewelry,
      coins,
      bars,
      watches,
      gifts,
      accessories,
    ];
  }
  
  /// Get a category by ID
  static ProductCategory getById(String id) {
    return getAll().firstWhere(
      (category) => category.id == id,
      orElse: () => all,
    );
  }
}
