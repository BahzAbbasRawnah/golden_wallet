import 'package:golden_wallet/features/catalog/models/filter_model.dart'
    as app_filter;
import 'package:golden_wallet/features/catalog/models/product_model.dart';
import 'package:golden_wallet/features/catalog/services/catalog_data_service.dart';

/// Service to handle catalog API calls and data fetching
class CatalogService {
  /// Get products with pagination and filtering
  Future<ProductsResponse> getProducts({
    required int page,
    required app_filter.CatalogFilter filter,
    String? searchQuery,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Convert filter model to match the data service
    final dataServiceFilter = CatalogFilter(
      categories: filter.categories,
      minPrice: filter.priceRange.selectedMin,
      maxPrice: filter.priceRange.selectedMax,
      purity: filter.purityOptions,
      sortBy: _convertSortOption(filter.sortOption),
    );

    // Get products from data service
    final result = await CatalogDataService.getProducts(
      page: page,
      filter: dataServiceFilter,
      searchQuery: searchQuery,
    );

    return ProductsResponse(
      products: result.products,
      totalPages: result.totalPages,
      currentPage: page,
    );
  }

  /// Convert SortOption to SortBy
  SortBy _convertSortOption(app_filter.SortOption option) {
    switch (option) {
      case app_filter.SortOption.newest:
        return SortBy.newest;
      case app_filter.SortOption.priceHighToLow:
        return SortBy.priceDesc;
      case app_filter.SortOption.priceLowToHigh:
        return SortBy.priceAsc;
      case app_filter.SortOption.popularity:
        return SortBy.popularity;
      case app_filter.SortOption.discount:
        // No direct equivalent, use popularity as fallback
        return SortBy.popularity;
    }
  }

  /// Get a product by ID
  Future<Product?> getProductById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get all products from data service
    final allProducts = await CatalogDataService.loadProducts();
    return allProducts.where((p) => p.id == id).firstOrNull;
  }
}

/// Response model for products API
class ProductsResponse {
  final List<Product> products;
  final int totalPages;
  final int currentPage;

  const ProductsResponse({
    required this.products,
    required this.totalPages,
    required this.currentPage,
  });
}
