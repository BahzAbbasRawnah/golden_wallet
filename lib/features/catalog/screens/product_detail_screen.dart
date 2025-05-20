import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/catalog/models/product_model.dart';
import 'package:golden_wallet/features/catalog/providers/catalog_provider.dart';
import 'package:golden_wallet/features/catalog/widgets/image_gallery.dart';
import 'package:golden_wallet/features/catalog/widgets/product_card.dart';
import 'package:golden_wallet/features/catalog/widgets/specification_item.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/loading_indicator.dart';

/// Product detail screen
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }
  
  /// Load product details
  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
      final product = await catalogProvider.getProductById(widget.productId);
      
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'productDetails'.tr(),
        actions: _product != null
            ? [
                Consumer<CatalogProvider>(
                  builder: (context, provider, child) {
                    final isFavorite = provider.isFavorite(_product!.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        provider.toggleFavorite(_product!.id);
                      },
                    );
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'errorLoadingProduct'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'tryAgain'.tr(),
                        onPressed: _loadProduct,
                        type: ButtonType.primary,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                )
              : _product == null
                  ? Center(
                      child: Text('productNotFound'.tr()),
                    )
                  : _buildProductDetail(context, _product!),
      bottomNavigationBar: _product != null
          ? _buildBottomBar(context, _product!)
          : null,
    );
  }
  
  /// Build product detail content
  Widget _buildProductDetail(BuildContext context, Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          ImageGallery(images: product.images),
          
          // Product info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Category
                Text(
                  product.category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Row(
                  children: [
                    if (product.hasDiscount) ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${product.discountedPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.discountPercentage!.toStringAsFixed(0)}% OFF',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (product.makingCharges != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${'makingCharges'.tr()}: \$${product.makingCharges!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Availability
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: product.availability.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.availability.translationKey.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'description'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 24),
                
                // Specifications
                Text(
                  'productSpecifications'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...product.specifications.entries.map((entry) {
                  return SpecificationItem(
                    label: entry.key,
                    value: entry.value,
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Similar products
                _buildSimilarProducts(context, product),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build similar products section
  Widget _buildSimilarProducts(BuildContext context, Product product) {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        final similarProducts = provider.getSimilarProducts(product);
        
        if (similarProducts.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'similarProducts'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarProducts.length,
                itemBuilder: (context, index) {
                  final similarProduct = similarProducts[index];
                  return SizedBox(
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ProductCard(
                        product: similarProduct,
                        isFavorite: provider.isFavorite(similarProduct.id),
                        onFavoriteToggle: () => provider.toggleFavorite(similarProduct.id),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.productDetail,
                            arguments: similarProduct.id,
                          );
                        },
                        showCategory: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Build bottom bar with action buttons
  Widget _buildBottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'addToCart'.tr(),
              onPressed: () {
                // TODO: Implement add to cart functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('addedToCart'.tr()),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              type: ButtonType.secondary,
              icon: Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'buyNow'.tr(),
              onPressed: product.availability.canPurchase
                  ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.buySell,
                        arguments: {'product': product},
                      );
                    }
                  : null,
              type: ButtonType.primary,
              icon: Icons.shopping_bag,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
