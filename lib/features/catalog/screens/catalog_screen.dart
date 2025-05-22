import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/shared/utils/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';
import 'package:golden_wallet/features/catalog/models/filter_model.dart';
import 'package:golden_wallet/features/catalog/models/product_model.dart';
import 'package:golden_wallet/features/catalog/providers/catalog_provider.dart';
import 'package:golden_wallet/features/catalog/widgets/category_chip.dart';
import 'package:golden_wallet/features/catalog/widgets/filter_bottom_sheet.dart';
import 'package:golden_wallet/features/catalog/widgets/product_card.dart';
import 'package:golden_wallet/features/catalog/widgets/product_list_item.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_search_bar.dart';
import 'package:golden_wallet/shared/widgets/empty_state.dart';
import 'package:golden_wallet/shared/widgets/loading_indicator.dart';

/// Main catalog screen
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();

    // Initialize data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize data
  Future<void> _initializeData() async {
    final catalogProvider =
        Provider.of<CatalogProvider>(context, listen: false);
    await catalogProvider.initialize();
  }

  /// Setup scroll listener for pagination
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final catalogProvider =
            Provider.of<CatalogProvider>(context, listen: false);
        catalogProvider.loadMoreProducts();
      }
    });
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  /// Handle search
  void _handleSearch(String query) {
    final catalogProvider =
        Provider.of<CatalogProvider>(context, listen: false);
    catalogProvider.searchProducts(query);
  }

  /// Clear search
  void _clearSearch() {
    _searchController.clear();
    final catalogProvider =
        Provider.of<CatalogProvider>(context, listen: false);
    catalogProvider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'catalog'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
              ),
              onPressed: () {
                // Navigate to cart screen
                Navigator.pushNamed(context, AppRoutes.cart);
              }),
          IconButton(
              icon: const Icon(
                Icons.favorite_outline,
              ),
              onPressed: () {
                // Navigate to favorites screen
                // Navigator.pushNamed(context, Routes.favorites);
              }),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, catalogProvider, child) {
          return RefreshIndicator(
            onRefresh: () => catalogProvider.fetchProducts(refresh: true),
            color: AppTheme.goldDark,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: TranslationKeys.catalogSearchProducts.tr(),
                    onSearch: _handleSearch,
                    onClear: _clearSearch,
                  ),
                ),

                // Categories
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0D000000), // 5% opacity black
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: catalogProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = catalogProvider.categories[index];
                      final isSelected = catalogProvider.filter.categories
                              .contains(category.id) ||
                          (category.id == 'all' &&
                              catalogProvider.filter.categories.isEmpty);

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CategoryChip(
                          category: category,
                          isSelected: isSelected,
                          onTap: () {
                            catalogProvider.getProductsByCategory(category.id);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Filter and view type controls
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.goldColor.withAlpha(50),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: AppTheme.goldDark,
                        ),
                        onPressed: _showFilterBottomSheet,
                      ),

                      // Filter button
                      // ElevatedButton.icon(
                      //   onPressed: _showFilterBottomSheet,
                      //   icon: const Icon(Icons.filter_list, size: 18),
                      //   label: Text(TranslationKeys.catalogFilterButton.tr()),
                      //   style: ElevatedButton.styleFrom(
                      //     foregroundColor: Colors.white,
                      //     backgroundColor: AppTheme.goldColor,
                      //     elevation: 0,
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 12, vertical: 8),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(width: 8),

                      // View type toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: catalogProvider.toggleViewType,
                          icon: Icon(
                            catalogProvider.viewType == ViewType.grid
                                ? Icons.view_list
                                : Icons.grid_view,
                            color: AppTheme.goldDark,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Products list
                Expanded(
                  child: _buildProductsList(catalogProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build products list based on view type
  Widget _buildProductsList(CatalogProvider catalogProvider) {
    if (catalogProvider.isLoading && catalogProvider.products.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    if (catalogProvider.products.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: TranslationKeys.catalogNoProductsFound.tr(),
        message: catalogProvider.isSearching
            ? TranslationKeys.catalogNoProductsFoundForSearch.tr()
            : TranslationKeys.catalogNoProductsFoundWithFilters.tr(),
        actionText:
            catalogProvider.filter.isEmpty && !catalogProvider.isSearching
                ? null
                : TranslationKeys.catalogResetFiltersButton.tr(),
        onAction: catalogProvider.filter.isEmpty && !catalogProvider.isSearching
            ? null
            : () {
                _clearSearch();
                catalogProvider.resetFilter();
              },
      );
    }

    return catalogProvider.viewType == ViewType.grid
        ? _buildGridView(catalogProvider)
        : _buildListView(catalogProvider);
  }

  /// Build grid view for products with gold-themed styling
  Widget _buildGridView(CatalogProvider catalogProvider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5, // Decreased to give more height to each card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: catalogProvider.products.length +
          (catalogProvider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == catalogProvider.products.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoadingIndicator(
                size: 24,
                color: AppTheme.goldColor,
              ),
            ),
          );
        }

        final product = catalogProvider.products[index];

        // Add a subtle animation for the cards
        return AnimatedOpacity(
          duration: Duration(milliseconds: 300 + (index * 50)),
          opacity: 1.0,
          curve: Curves.easeInOut,
          child: ProductCard(
            product: product,
            isFavorite: catalogProvider.isFavorite(product.id),
            onFavoriteToggle: () => catalogProvider.toggleFavorite(product.id),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: product.id,
              );
            },
          ),
        );
      },
    );
  }

  /// Build list view for products with gold-themed styling
  Widget _buildListView(CatalogProvider catalogProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: catalogProvider.products.length +
          (catalogProvider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == catalogProvider.products.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoadingIndicator(
                size: 24,
                color: AppTheme.goldColor,
              ),
            ),
          );
        }

        final product = catalogProvider.products[index];

        // Add a subtle animation for the list items
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 300 + (index * 30)),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProductListItem(
              product: product,
              isFavorite: catalogProvider.isFavorite(product.id),
              onFavoriteToggle: () =>
                  catalogProvider.toggleFavorite(product.id),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetail,
                  arguments: product.id,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
