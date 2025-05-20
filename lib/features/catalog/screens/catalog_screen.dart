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
    _initializeData();
    _setupScrollListener();
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
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: catalogProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = catalogProvider.categories[index];
                      final isSelected = catalogProvider.filter.categories
                              .contains(category.id) ||
                          (category.id == 'all' &&
                              catalogProvider.filter.categories.isEmpty);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Filter button
                      OutlinedButton.icon(
                        onPressed: _showFilterBottomSheet,
                        icon: const Icon(Icons.filter_list),
                        label: Text(TranslationKeys.catalogFilterButton.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.goldDark,
                          side: BorderSide(color: AppTheme.goldDark),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),

                      const Spacer(),

                      // View type toggle
                      IconButton(
                        onPressed: catalogProvider.toggleViewType,
                        icon: Icon(
                          catalogProvider.viewType == ViewType.grid
                              ? Icons.view_list
                              : Icons.grid_view,
                          color: AppTheme.goldDark,
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

  /// Build grid view for products
  Widget _buildGridView(CatalogProvider catalogProvider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // Increased from 0.6 to give more height
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: catalogProvider.products.length +
          (catalogProvider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == catalogProvider.products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingIndicator(size: 24),
            ),
          );
        }

        final product = catalogProvider.products[index];
        return ProductCard(
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
        );
      },
    );
  }

  /// Build list view for products
  Widget _buildListView(CatalogProvider catalogProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: catalogProvider.products.length +
          (catalogProvider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == catalogProvider.products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingIndicator(size: 24),
            ),
          );
        }

        final product = catalogProvider.products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProductListItem(
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
}
