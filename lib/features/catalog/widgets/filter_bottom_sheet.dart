import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/shared/utils/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';

import 'package:golden_wallet/features/catalog/models/filter_model.dart';
import 'package:golden_wallet/features/catalog/providers/catalog_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';

/// Bottom sheet for filtering products
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late CatalogFilter _filter;
  late RangeValues _priceRangeValues;

  @override
  void initState() {
    super.initState();
    final catalogProvider =
        Provider.of<CatalogProvider>(context, listen: false);
    _filter = catalogProvider.filter;

    // Initialize price range values
    _priceRangeValues = RangeValues(
      _filter.priceRange.effectiveMin,
      _filter.priceRange.effectiveMax,
    );
  }

  /// Apply filters and close the bottom sheet
  void _applyFilters() {
    final catalogProvider =
        Provider.of<CatalogProvider>(context, listen: false);

    // Update price range
    final updatedPriceRange = _filter.priceRange.copyWith(
      selectedMin: _priceRangeValues.start,
      selectedMax: _priceRangeValues.end,
    );

    // Update filter
    final updatedFilter = _filter.copyWith(
      priceRange: updatedPriceRange,
    );

    // Apply filter
    catalogProvider.updateFilter(updatedFilter);

    // Close bottom sheet
    Navigator.pop(context);
  }

  /// Reset filters
  void _resetFilters() {
    setState(() {
      _filter = _filter.reset();
      _priceRangeValues = RangeValues(
        _filter.priceRange.min,
        _filter.priceRange.max,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.catalogFiltersTitle.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  TranslationKeys.catalogClearAllFilters.tr(),
                  style: TextStyle(
                    color: AppTheme.goldDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Price range
          Text(
            TranslationKeys.catalogPriceRange.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRangeValues.start.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '\$${_priceRangeValues.end.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          RangeSlider(
            values: _priceRangeValues,
            min: _filter.priceRange.min,
            max: _filter.priceRange.max,
            divisions: 100,
            activeColor: AppTheme.goldDark,
            inactiveColor: Colors.grey[300],
            labels: RangeLabels(
              '\$${_priceRangeValues.start.toStringAsFixed(0)}',
              '\$${_priceRangeValues.end.toStringAsFixed(0)}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRangeValues = values;
              });
            },
          ),

          const SizedBox(height: 24),

          // Categories
          Text(
            TranslationKeys.catalogCategories.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Consumer<CatalogProvider>(
            builder: (context, provider, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categories.map((category) {
                  final isSelected = _filter.categories.contains(category.id);

                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _filter = _filter.copyWith(
                            categories: [..._filter.categories, category.id],
                          );
                        } else {
                          _filter = _filter.copyWith(
                            categories: _filter.categories
                                .where((id) => id != category.id)
                                .toList(),
                          );
                        }
                      });
                    },
                    selectedColor: AppTheme.goldColor.withAlpha(51),
                    checkmarkColor: AppTheme.goldDark,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.goldDark : Colors.black,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Gold purity
          Text(
            TranslationKeys.catalogPurity.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['24K', '22K', '18K', '14K'].map((purity) {
              final isSelected = _filter.purityOptions.contains(purity);

              return FilterChip(
                label: Text(purity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter = _filter.copyWith(
                        purityOptions: [..._filter.purityOptions, purity],
                      );
                    } else {
                      _filter = _filter.copyWith(
                        purityOptions: _filter.purityOptions
                            .where((p) => p != purity)
                            .toList(),
                      );
                    }
                  });
                },
                selectedColor: AppTheme.goldColor.withAlpha(51),
                checkmarkColor: AppTheme.goldDark,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.goldDark : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Sort by
          Text(
            TranslationKeys.catalogSortByLabel.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SortOption>(
            value: _filter.sortOption,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: SortOption.values.map((option) {
              return DropdownMenuItem<SortOption>(
                value: option,
                child: Text(option.translationKey.tr()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _filter = _filter.copyWith(sortOption: value);
                });
              }
            },
          ),

          const SizedBox(height: 32),

          // Apply button
          CustomButton(
            text: TranslationKeys.catalogApplyFilters.tr(),
            onPressed: _applyFilters,
            type: ButtonType.primary,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
