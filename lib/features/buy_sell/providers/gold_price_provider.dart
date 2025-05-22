import 'package:flutter/material.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';

/// Provider for managing gold price data
class GoldPriceProvider extends ChangeNotifier {
  GoldPriceData? _priceData;
  Map<String, dynamic>? _goldData;
  bool _isLoading = true;
  String _error = '';

  // Selected values
  GoldCategory _selectedCategory = GoldCategory.grams;
  GoldKarat? _selectedGoldType;
  GoldBar? _selectedBar;
  int _barsCount = 1;
  double _amount = 0.0;
  double _total = 0.0;
  bool _isBuying = true;

  // Getters
  GoldPriceData? get priceData => _priceData;
  Map<String, dynamic>? get goldData => _goldData;
  bool get isLoading => _isLoading;
  String get error => _error;

  GoldCategory get selectedCategory => _selectedCategory;
  GoldKarat? get selectedGoldType => _selectedGoldType;
  GoldBar? get selectedBar => _selectedBar;
  int get barsCount => _barsCount;
  double get amount => _amount;
  double get total => _total;
  bool get isBuying => _isBuying;

  // Lists from gold data
  List<GoldCategoryData> get categories =>
      _goldData != null ? _goldData!['categories'] : [];

  List<GoldKarat> get goldKarats =>
      _goldData != null ? _goldData!['goldKarats'] : [];

  List<GoldBar> get goldBars => _goldData != null ? _goldData!['goldBars'] : [];

  List<PaymentMethod> get paymentMethods =>
      _goldData != null ? _goldData!['paymentMethods'] : [];

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Load gold data
      _goldData = await GoldDataService.loadGoldData();

      // Load price data
      _priceData = await GoldDataService.loadGoldPrices();

      // Set default selections
      if (goldKarats.isNotEmpty) {
        _selectedGoldType =
            goldKarats.firstWhere((type) => type.karat == '24K');
      }

      if (goldBars.isNotEmpty) {
        _selectedBar = goldBars.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set the selected category
  void setCategory(GoldCategory category) {
    _selectedCategory = category;
    calculateTotal();
    notifyListeners();
  }

  // Set the selected gold type
  void setGoldType(GoldKarat type) {
    _selectedGoldType = type;
    calculateTotal();
    notifyListeners();
  }

  // Set the bars count
  void setBarsCount(int count) {
    if (count >= 1 && count <= 20) {
      _barsCount = count;
      calculateTotal();
      notifyListeners();
    }
  }

  // Increment bars count
  void incrementBarsCount() {
    if (_barsCount < 20) {
      _barsCount++;
      calculateTotal();
      notifyListeners();
    }
  }

  // Decrement bars count
  void decrementBarsCount() {
    if (_barsCount > 1) {
      _barsCount--;
      calculateTotal();
      notifyListeners();
    }
  }

  // Set the amount
  void setAmount(double amount) {
    _amount = amount;
    calculateTotal();
    notifyListeners();
  }

  // Set buying or selling
  void setIsBuying(bool isBuying) {
    _isBuying = isBuying;
    calculateTotal();
    notifyListeners();
  }

  // Calculate the total based on the current selections
  void calculateTotal() {
    if (_priceData == null || _selectedGoldType == null) {
      _total = 0.0;
      return;
    }

    final pricePerGram = _isBuying
        ? _priceData!.basePricePerGram[_selectedGoldType!.karat]!.buy
        : _priceData!.basePricePerGram[_selectedGoldType!.karat]!.sell;

    switch (_selectedCategory) {
      case GoldCategory.grams:
        _total = _amount * pricePerGram;
        break;
      case GoldCategory.pounds:
        _total = _amount * pricePerGram;

        break;
      case GoldCategory.bars:
        if (_selectedBar != null) {
          _total = _barsCount * _selectedBar!.grams * pricePerGram;
        }
        break;
    }
  }

  // Get the current price for the selected gold type
  double getCurrentPrice() {
    if (_priceData == null || _selectedGoldType == null) {
      return 0.0;
    }

    return _isBuying
        ? _priceData!.basePricePerGram[_selectedGoldType!.karat]!.buy
        : _priceData!.basePricePerGram[_selectedGoldType!.karat]!.sell;
  }

  // Get the currency
  String getCurrency() {
    if (_priceData == null) {
      return 'AED';
    }

    return _priceData!.currency;
  }

  // Get the price trend (up or down) compared to yesterday
  bool isPriceUp() {
    if (_priceData == null ||
        _selectedGoldType == null ||
        _priceData!.priceHistory.length < 2) {
      return true;
    }

    final todayPrice = _isBuying
        ? _priceData!.priceHistory[0].prices[_selectedGoldType!.karat]!.buy
        : _priceData!.priceHistory[0].prices[_selectedGoldType!.karat]!.sell;

    final yesterdayPrice = _isBuying
        ? _priceData!.priceHistory[1].prices[_selectedGoldType!.karat]!.buy
        : _priceData!.priceHistory[1].prices[_selectedGoldType!.karat]!.sell;

    return todayPrice > yesterdayPrice;
  }

  // Get the price change percentage compared to yesterday
  String getPriceChangePercentage() {
    if (_priceData == null ||
        _selectedGoldType == null ||
        _priceData!.priceHistory.length < 2) {
      return '+0.0%';
    }

    final todayPrice = _isBuying
        ? _priceData!.priceHistory[0].prices[_selectedGoldType!.karat]!.buy
        : _priceData!.priceHistory[0].prices[_selectedGoldType!.karat]!.sell;

    final yesterdayPrice = _isBuying
        ? _priceData!.priceHistory[1].prices[_selectedGoldType!.karat]!.buy
        : _priceData!.priceHistory[1].prices[_selectedGoldType!.karat]!.sell;

    final change = ((todayPrice - yesterdayPrice) / yesterdayPrice) * 100;
    final sign = change >= 0 ? '+' : '';

    return '$sign${change.toStringAsFixed(1)}%';
  }
}
