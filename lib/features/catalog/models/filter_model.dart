import 'package:golden_wallet/shared/utils/translation_keys.dart';

/// Model representing filter options for the catalog
class CatalogFilter {
  final PriceRange priceRange;
  final List<String> categories;
  final List<String> purityOptions;
  final SortOption sortOption;

  const CatalogFilter({
    this.priceRange = const PriceRange(),
    this.categories = const [],
    this.purityOptions = const [],
    this.sortOption = SortOption.newest,
  });

  /// Create a copy of this filter with the given fields replaced with the new values
  CatalogFilter copyWith({
    PriceRange? priceRange,
    List<String>? categories,
    List<String>? purityOptions,
    SortOption? sortOption,
  }) {
    return CatalogFilter(
      priceRange: priceRange ?? this.priceRange,
      categories: categories ?? this.categories,
      purityOptions: purityOptions ?? this.purityOptions,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Check if the filter is empty (no filters applied)
  bool get isEmpty {
    return categories.isEmpty &&
        purityOptions.isEmpty &&
        priceRange.isDefault &&
        sortOption == SortOption.newest;
  }

  /// Reset all filters to default values
  CatalogFilter reset() {
    return const CatalogFilter();
  }

  /// Create a CatalogFilter from JSON
  factory CatalogFilter.fromJson(Map<String, dynamic> json) {
    return CatalogFilter(
      priceRange:
          PriceRange.fromJson(json['priceRange'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      purityOptions: (json['purityOptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sortOption: SortOption.values.firstWhere(
        (e) => e.toString().split('.').last == json['sortOption'],
        orElse: () => SortOption.newest,
      ),
    );
  }

  /// Convert CatalogFilter to JSON
  Map<String, dynamic> toJson() {
    return {
      'priceRange': priceRange.toJson(),
      'categories': categories,
      'purityOptions': purityOptions,
      'sortOption': sortOption.toString().split('.').last,
    };
  }
}

/// Model representing a price range filter
class PriceRange {
  final double min;
  final double max;
  final double? selectedMin;
  final double? selectedMax;

  const PriceRange({
    this.min = 0,
    this.max = 10000,
    this.selectedMin,
    this.selectedMax,
  });

  /// Get the effective minimum value
  double get effectiveMin => selectedMin ?? min;

  /// Get the effective maximum value
  double get effectiveMax => selectedMax ?? max;

  /// Check if the price range is at default values
  bool get isDefault => selectedMin == null && selectedMax == null;

  /// Create a copy of this price range with the given fields replaced with the new values
  PriceRange copyWith({
    double? min,
    double? max,
    double? selectedMin,
    double? selectedMax,
  }) {
    return PriceRange(
      min: min ?? this.min,
      max: max ?? this.max,
      selectedMin: selectedMin,
      selectedMax: selectedMax,
    );
  }

  /// Reset the selected values to null (default)
  PriceRange reset() {
    return PriceRange(
      min: min,
      max: max,
    );
  }

  /// Create a PriceRange from JSON
  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      selectedMin: json['selectedMin'] != null
          ? (json['selectedMin'] as num).toDouble()
          : null,
      selectedMax: json['selectedMax'] != null
          ? (json['selectedMax'] as num).toDouble()
          : null,
    );
  }

  /// Convert PriceRange to JSON
  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'selectedMin': selectedMin,
      'selectedMax': selectedMax,
    };
  }
}

/// Enum representing sort options for the catalog
enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
  popularity,
  discount,
}

/// Extension to provide additional functionality to SortOption enum
extension SortOptionExtension on SortOption {
  /// Get the translation key for the sort option
  String get translationKey {
    switch (this) {
      case SortOption.newest:
        return TranslationKeys.catalogSortNewest;
      case SortOption.priceHighToLow:
        return TranslationKeys.catalogSortPriceHighToLow;
      case SortOption.priceLowToHigh:
        return TranslationKeys.catalogSortPriceLowToHigh;
      case SortOption.popularity:
        return TranslationKeys.catalogSortPopularity;
      case SortOption.discount:
        return TranslationKeys.catalogSortDiscount;
    }
  }
}
