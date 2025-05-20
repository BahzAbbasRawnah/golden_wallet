import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';
import 'package:golden_wallet/features/catalog/models/filter_model.dart';
import 'package:golden_wallet/features/catalog/models/product_model.dart';

/// Service to handle catalog API calls and data fetching
class CatalogService {
  /// Get products with pagination and filtering
  Future<ProductsResponse> getProducts({
    required int page,
    required CatalogFilter filter,
    String? searchQuery,
  }) async {
    // In a real app, this would be an API call
    // For now, we'll simulate an API response with mock data
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate mock products
    final allProducts = _generateMockProducts();
    
    // Apply filters
    var filteredProducts = allProducts;
    
    // Apply category filter
    if (filter.categories.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.categories.contains(p.category.id))
          .toList();
    }
    
    // Apply price range filter
    if (filter.priceRange.selectedMin != null || filter.priceRange.selectedMax != null) {
      filteredProducts = filteredProducts
          .where((p) => 
              p.price >= filter.priceRange.effectiveMin && 
              p.price <= filter.priceRange.effectiveMax)
          .toList();
    }
    
    // Apply purity filter
    if (filter.purityOptions.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.purityOptions.contains(p.purity))
          .toList();
    }
    
    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredProducts = filteredProducts
          .where((p) => 
              p.name.toLowerCase().contains(query) || 
              p.description.toLowerCase().contains(query))
          .toList();
    }
    
    // Apply sorting
    switch (filter.sortOption) {
      case SortOption.newest:
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceHighToLow:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.priceLowToHigh:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.popularity:
        // In a real app, this would be based on popularity metrics
        // For now, we'll just use a random order
        filteredProducts.shuffle();
        break;
      case SortOption.discount:
        filteredProducts.sort((a, b) => 
            (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
        break;
    }
    
    // Apply pagination
    final pageSize = 10;
    final totalPages = (filteredProducts.length / pageSize).ceil();
    
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize > filteredProducts.length 
        ? filteredProducts.length 
        : startIndex + pageSize;
    
    final paginatedProducts = startIndex < filteredProducts.length
        ? filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];
    
    return ProductsResponse(
      products: paginatedProducts,
      totalPages: totalPages,
      currentPage: page,
    );
  }
  
  /// Get a product by ID
  Future<Product?> getProductById(String id) async {
    // In a real app, this would be an API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allProducts = _generateMockProducts();
    return allProducts.where((p) => p.id == id).firstOrNull;
  }
  
  /// Generate mock products for testing
  List<Product> _generateMockProducts() {
    final categories = ProductCategories.getAll();
    
    return [
      Product(
        id: '1',
        name: '24K Gold Bar - 10g',
        description: 'Pure 24K gold bar, perfect for investment and collection.',
        category: categories.firstWhere((c) => c.id == 'bars'),
        price: 650.0,
        weight: 10.0,
        purity: '24K',
        images: [
          'assets/images/products/gold_bar_1.jpg',
          'assets/images/products/gold_bar_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '99.99%',
          'Weight': '10g',
          'Dimensions': '45mm x 25mm x 1.5mm',
          'Manufacturer': 'Golden Wallet Mint',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'Gold Coin - American Eagle',
        description: 'American Eagle gold coin, a popular choice for collectors.',
        category: categories.firstWhere((c) => c.id == 'coins'),
        price: 1850.0,
        weight: 31.1,
        purity: '22K',
        images: [
          'assets/images/products/gold_coin_1.jpg',
          'assets/images/products/gold_coin_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '91.67%',
          'Weight': '1 oz (31.1g)',
          'Diameter': '32.7mm',
          'Thickness': '2.87mm',
          'Year': '2023',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isFeatured: true,
      ),
      Product(
        id: '3',
        name: 'Gold Necklace with Pendant',
        description: 'Elegant gold necklace with a beautiful pendant design.',
        category: categories.firstWhere((c) => c.id == 'jewelry'),
        price: 1200.0,
        weight: 8.5,
        purity: '18K',
        images: [
          'assets/images/products/gold_necklace_1.jpg',
          'assets/images/products/gold_necklace_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '75%',
          'Weight': '8.5g',
          'Chain Length': '18 inches',
          'Clasp Type': 'Lobster',
          'Style': 'Pendant',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isFeatured: false,
        discountPercentage: 10.0,
        makingCharges: 80.0,
      ),
      Product(
        id: '4',
        name: 'Gold Bracelet - Classic Chain',
        description: 'Classic gold chain bracelet, perfect for everyday wear.',
        category: categories.firstWhere((c) => c.id == 'jewelry'),
        price: 950.0,
        weight: 7.2,
        purity: '22K',
        images: [
          'assets/images/products/gold_bracelet_1.jpg',
          'assets/images/products/gold_bracelet_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '91.67%',
          'Weight': '7.2g',
          'Length': '7.5 inches',
          'Width': '4mm',
          'Clasp Type': 'Box',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isFeatured: false,
        makingCharges: 65.0,
      ),
      Product(
        id: '5',
        name: 'Gold Watch - Luxury Edition',
        description: 'Luxury gold watch with premium craftsmanship.',
        category: categories.firstWhere((c) => c.id == 'watches'),
        price: 5800.0,
        weight: 85.0,
        purity: '18K',
        images: [
          'assets/images/products/gold_watch_1.jpg',
          'assets/images/products/gold_watch_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '75%',
          'Weight': '85g',
          'Case Diameter': '40mm',
          'Band Width': '20mm',
          'Movement': 'Automatic',
          'Water Resistance': '50m',
        },
        availability: ProductAvailability.lowStock,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isFeatured: true,
        discountPercentage: 5.0,
      ),
      // Add more mock products as needed
      Product(
        id: '6',
        name: 'Gold Ring - Diamond Solitaire',
        description: 'Elegant gold ring with a stunning diamond solitaire.',
        category: categories.firstWhere((c) => c.id == 'jewelry'),
        price: 1500.0,
        weight: 4.5,
        purity: '18K',
        images: [
          'assets/images/products/gold_ring_1.jpg',
          'assets/images/products/gold_ring_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '75%',
          'Weight': '4.5g',
          'Diamond': '0.5 carat',
          'Diamond Clarity': 'VS1',
          'Diamond Color': 'F',
          'Ring Size': '7',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        isFeatured: false,
        makingCharges: 120.0,
      ),
      Product(
        id: '7',
        name: 'Gold Bar - 50g',
        description: 'Premium 24K gold bar, ideal for serious investors.',
        category: categories.firstWhere((c) => c.id == 'bars'),
        price: 3250.0,
        weight: 50.0,
        purity: '24K',
        images: [
          'assets/images/products/gold_bar_3.jpg',
          'assets/images/products/gold_bar_4.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '99.99%',
          'Weight': '50g',
          'Dimensions': '70mm x 40mm x 2mm',
          'Manufacturer': 'Golden Wallet Mint',
          'Serial Number': 'Yes',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        isFeatured: true,
      ),
      Product(
        id: '8',
        name: 'Gold Earrings - Classic Hoops',
        description: 'Classic gold hoop earrings, a timeless accessory.',
        category: categories.firstWhere((c) => c.id == 'jewelry'),
        price: 580.0,
        weight: 3.8,
        purity: '22K',
        images: [
          'assets/images/products/gold_earrings_1.jpg',
          'assets/images/products/gold_earrings_2.jpg',
        ],
        specifications: {
          'Material': 'Gold',
          'Purity': '91.67%',
          'Weight': '3.8g',
          'Diameter': '25mm',
          'Closure Type': 'Hinged',
          'Style': 'Hoop',
        },
        availability: ProductAvailability.inStock,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        isFeatured: false,
        makingCharges: 45.0,
      ),
      // Add more products as needed
    ];
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
