import 'package:flutter/material.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';
import 'package:golden_wallet/features/catalog/models/filter_model.dart';
import 'package:golden_wallet/features/catalog/models/product_model.dart';
import 'package:golden_wallet/features/catalog/services/catalog_service.dart';

/// Provider to manage catalog data and state
class CatalogProvider extends ChangeNotifier {
  // Dependencies
  final CatalogService _catalogService = CatalogService();
  
  // State variables
  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  Set<String> _favoriteProductIds = {};
  CatalogFilter _filter = const CatalogFilter();
  ViewType _viewType = ViewType.grid;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = true;
  
  // Search
  String _searchQuery = '';
  bool _isSearching = false;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  Set<String> get favoriteProductIds => _favoriteProductIds;
  CatalogFilter get filter => _filter;
  ViewType get viewType => _viewType;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _hasMorePages;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  
  /// Initialize the provider
  Future<void> initialize() async {
    await fetchCategories();
    await fetchProducts();
  }
  
  /// Fetch product categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(milliseconds: 500));
      _categories = ProductCategories.getAll();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Fetch products with current filter and pagination
  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
    }
    
    if (!_hasMorePages && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, this would be an API call with proper pagination
      final result = await _catalogService.getProducts(
        page: _currentPage,
        filter: _filter,
        searchQuery: _searchQuery,
      );
      
      if (refresh || _currentPage == 1) {
        _products = result.products;
      } else {
        _products = [..._products, ...result.products];
      }
      
      _totalPages = result.totalPages;
      _hasMorePages = _currentPage < _totalPages;
      
      if (_hasMorePages) {
        _currentPage++;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!_hasMorePages || _isLoading) return;
    await fetchProducts();
  }
  
  /// Get a product by ID
  Future<Product?> getProductById(String id) async {
    // First check if the product is already in the list
    final existingProduct = _products.where((p) => p.id == id).firstOrNull;
    if (existingProduct != null) {
      return existingProduct;
    }
    
    // If not, fetch it from the service
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final product = await _catalogService.getProductById(id);
      
      _isLoading = false;
      notifyListeners();
      
      return product;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Get products by category
  Future<void> getProductsByCategory(String categoryId) async {
    // Reset pagination
    _currentPage = 1;
    _hasMorePages = true;
    
    // Update filter
    _filter = _filter.copyWith(
      categories: categoryId == 'all' ? [] : [categoryId],
    );
    
    await fetchProducts(refresh: true);
  }
  
  /// Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    
    // Reset pagination
    _currentPage = 1;
    _hasMorePages = true;
    
    await fetchProducts(refresh: true);
  }
  
  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    fetchProducts(refresh: true);
  }
  
  /// Update filter
  Future<void> updateFilter(CatalogFilter newFilter) async {
    _filter = newFilter;
    
    // Reset pagination
    _currentPage = 1;
    _hasMorePages = true;
    
    await fetchProducts(refresh: true);
  }
  
  /// Reset filter
  Future<void> resetFilter() async {
    _filter = _filter.reset();
    
    // Reset pagination
    _currentPage = 1;
    _hasMorePages = true;
    
    await fetchProducts(refresh: true);
  }
  
  /// Toggle view type (grid/list)
  void toggleViewType() {
    _viewType = _viewType == ViewType.grid ? ViewType.list : ViewType.grid;
    notifyListeners();
  }
  
  /// Toggle favorite status for a product
  void toggleFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
  }
  
  /// Check if a product is favorite
  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }
  
  /// Get featured products
  List<Product> getFeaturedProducts() {
    return _products.where((p) => p.isFeatured).toList();
  }
  
  /// Get similar products to a given product
  List<Product> getSimilarProducts(Product product) {
    return _products
        .where((p) => 
            p.id != product.id && 
            p.category.id == product.category.id)
        .take(4)
        .toList();
  }
}

/// Enum representing view types for the catalog
enum ViewType {
  grid,
  list,
}
