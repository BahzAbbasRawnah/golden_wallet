import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';
import 'package:golden_wallet/features/catalog/models/product_model.dart';

/// Enum representing sort options for the catalog data service
enum SortBy {
  newest,
  priceAsc,
  priceDesc,
  popularity,
}

/// Model for catalog filter used by the data service
class CatalogFilter {
  final List<String> categories;
  final double? minPrice;
  final double? maxPrice;
  final List<String> purity;
  final SortBy sortBy;

  const CatalogFilter({
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.purity = const [],
    this.sortBy = SortBy.newest,
  });
}

/// Response model for products
class ProductsResponse {
  final List<Product> products;
  final int totalProducts;
  final int totalPages;

  const ProductsResponse({
    required this.products,
    required this.totalProducts,
    required this.totalPages,
  });
}

/// Service for loading catalog data from JSON files
class CatalogDataService {
  /// Load categories from JSON file
  static Future<List<ProductCategory>> loadCategories() async {
    try {
      final String categoriesJson = await rootBundle
          .loadString('lib/features/catalog/data/categories.json');
      final categoriesData = json.decode(categoriesJson);

      final List<ProductCategory> categories =
          (categoriesData['categories'] as List)
              .map((item) => ProductCategory.fromJson(item))
              .toList();

      return categories;
    } catch (e) {
      // Fallback to hardcoded categories if JSON file is not available
      return ProductCategories.getAll();
    }
  }

  /// Load products from JSON file
  static Future<List<Product>> loadProducts() async {
    try {
      final String productsJson = await rootBundle
          .loadString('lib/features/catalog/data/products.json');
      final productsData = json.decode(productsJson);

      final List<Product> products = (productsData['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList();

      return products;
    } catch (e) {
      // Return empty list if JSON file is not available
      return [];
    }
  }

  /// Get products with pagination and filtering
  static Future<ProductsResponse> getProducts({
    required int page,
    required CatalogFilter filter,
    String? searchQuery,
  }) async {
    // Load all products
    final allProducts = await loadProducts();

    // Apply filters
    var filteredProducts = allProducts;

    // Apply category filter
    if (filter.categories.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.categories.contains(p.category.id))
          .toList();
    }

    // Apply price range filter
    if (filter.minPrice != null) {
      filteredProducts =
          filteredProducts.where((p) => p.price >= filter.minPrice!).toList();
    }

    if (filter.maxPrice != null) {
      filteredProducts =
          filteredProducts.where((p) => p.price <= filter.maxPrice!).toList();
    }

    // Apply purity filter
    if (filter.purity.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.purity.contains(p.purity))
          .toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredProducts = filteredProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              p.category.name.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    switch (filter.sortBy) {
      case SortBy.priceAsc:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceDesc:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortBy.newest:
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.popularity:
        // In a real app, this would sort by popularity metrics
        // For now, we'll use featured status as a proxy for popularity
        filteredProducts.sort((a, b) => b.isFeatured ? 1 : -1);
        break;
    }

    // Calculate pagination
    final totalProducts = filteredProducts.length;
    final productsPerPage = 10;
    final totalPages = (totalProducts / productsPerPage).ceil();

    // Get products for the current page
    final startIndex = (page - 1) * productsPerPage;
    final endIndex = startIndex + productsPerPage > totalProducts
        ? totalProducts
        : startIndex + productsPerPage;

    final paginatedProducts = startIndex < totalProducts
        ? filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];

    return ProductsResponse(
      products: paginatedProducts,
      totalProducts: totalProducts,
      totalPages: totalPages,
    );
  }
}
