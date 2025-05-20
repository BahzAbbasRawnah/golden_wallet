import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/localization.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';

/// Buy/Sell Gold Screen
class BuySellScreen extends StatefulWidget {
  const BuySellScreen({Key? key}) : super(key: key);

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _barsCountController = TextEditingController();

  // Gold category and type selection
  GoldCategory _selectedCategory = GoldCategory.grams;
  String _selectedGoldType = '24K';
  GoldGramType _selectedGramType = goldGramTypes.last; // 24K by default
  GoldPoundWeight _selectedPoundWeight =
      goldPoundWeights.first; // 1g by default
  int _barsCount = 1;

  // Payment methods
  bool _useWalletPayment = false;
  bool _useCashTransfer = false;

  // Transaction values
  double _currentPrice = 2245.67;
  double _amount = 0.0;
  double _total = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _amountController.addListener(_calculateTotal);
    _barsCountController.text = _barsCount.toString();
    _barsCountController.addListener(_updateBarsCount);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _totalController.dispose();
    _barsCountController.dispose();
    super.dispose();
  }

  // Update bars count from text field
  void _updateBarsCount() {
    if (_barsCountController.text.isNotEmpty) {
      try {
        final count = int.parse(_barsCountController.text);
        if (count >= 1 && count <= 20) {
          setState(() {
            _barsCount = count;
            _calculateTotal();
          });
        }
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  // Handle tab change
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _amountController.clear();
        _totalController.clear();
        _amount = 0.0;
        _total = 0.0;
      });
    }
  }

  // Calculate total based on amount and gold category
  void _calculateTotal() {
    setState(() {
      switch (_selectedCategory) {
        case GoldCategory.grams:
          if (_amountController.text.isNotEmpty) {
            try {
              _amount = double.parse(_amountController.text);
              _total = _amount * _getPriceForGoldType(_selectedGramType.karat);
              _totalController.text = _total.toStringAsFixed(2);
            } catch (e) {
              // Handle parsing error
              _amount = 0.0;
              _total = 0.0;
              _totalController.text = '';
            }
          } else {
            _amount = 0.0;
            _total = 0.0;
            _totalController.text = '';
          }
          break;

        case GoldCategory.pounds:
          if (_amountController.text.isNotEmpty) {
            try {
              _amount = double.parse(_amountController.text);
              // Calculate based on pound weight (in grams) and 24K price
              _total = _amount *
                  _selectedPoundWeight.grams *
                  _getPriceForGoldType('24K') /
                  31.1; // Convert from oz to gram
              _totalController.text = _total.toStringAsFixed(2);
            } catch (e) {
              // Handle parsing error
              _amount = 0.0;
              _total = 0.0;
              _totalController.text = '';
            }
          } else {
            _amount = 0.0;
            _total = 0.0;
            _totalController.text = '';
          }
          break;

        case GoldCategory.bars:
          // For bars, we use the bars count instead of amount
          // Each bar is 1 oz of 24K gold
          _amount = _barsCount.toDouble();
          _total = _amount * _getPriceForGoldType('24K');
          _totalController.text = _total.toStringAsFixed(2);
          break;
      }
    });
  }

  // Get price for selected gold type
  double _getPriceForGoldType(String type) {
    switch (type) {
      case '24K':
        return 2245.67;
      case '22K':
        return 2058.30;
      case '21K':
        return 1965.21;
      case '20K':
        return 1871.39;
      case '18K':
        return 1684.25;
      default:
        return 2245.67;
    }
  }

  // Change gold category
  void _changeGoldCategory(GoldCategory category) {
    setState(() {
      _selectedCategory = category;
      // Reset values
      _amountController.text = '';
      _totalController.text = '';
      _amount = 0.0;
      _total = 0.0;

      // Update calculation
      _calculateTotal();
    });
  }

  // Execute transaction
  Future<void> _executeTransaction() async {
    // Validate payment method
    if (!_useWalletPayment && !_useCashTransfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'selectPaymentMethod'.tr(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Validate amount
    if (_amount <= 0 || _total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'invalidAmount'.tr(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate transaction delay
    await Future.delayed(const Duration(seconds: 2));

    // Show success message if still mounted
    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tabController.index == 0
                ? 'buySuccess'.tr()
                : 'sellSuccess'.tr(),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      setState(() {
        _isLoading = false;
        _amountController.clear();
        _totalController.clear();
        _amount = 0.0;
        _total = 0.0;
        _useWalletPayment = false;
        _useCashTransfer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'buySellGold'.tr(),
          style: TextStyle(
            color: AppTheme.goldDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.goldDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF2A2A2A)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: AppTheme.goldGradient,
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey[700],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: 'buy'.tr()),
                  Tab(text: 'sell'.tr()),
                ],
              ),
            ),

            // Current price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'currentPrice'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${_getPriceForGoldType(_selectedGoldType).toStringAsFixed(2)}/oz',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldDark,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+1.2%',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gold category tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'goldType'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCategoryTab(
                        context,
                        GoldCategory.grams,
                        'goldGrams'.tr(),
                      ),
                      const SizedBox(width: 12),
                      _buildCategoryTab(
                        context,
                        GoldCategory.pounds,
                        'goldPounds'.tr(),
                      ),
                      const SizedBox(width: 12),
                      _buildCategoryTab(
                        context,
                        GoldCategory.bars,
                        'goldBars'.tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionForm(context, isBuy: true),
                  _buildTransactionForm(context, isBuy: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build category tab
  Widget _buildCategoryTab(
    BuildContext context,
    GoldCategory category,
    String title,
  ) {
    final isSelected = _selectedCategory == category;

    return Expanded(
      child: InkWell(
        onTap: () => _changeGoldCategory(category),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.goldColor.withOpacity(0.2)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.goldColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                color: isSelected ? AppTheme.goldDark : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppTheme.goldDark : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build transaction form
  Widget _buildTransactionForm(BuildContext context, {required bool isBuy}) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold type selector based on category
          if (_selectedCategory == GoldCategory.grams) ...[
            _buildGoldTypeSelector(context),
            const SizedBox(height: 16),
          ] else if (_selectedCategory == GoldCategory.pounds) ...[
            _buildPoundWeightSelector(context),
            const SizedBox(height: 16),
          ] else if (_selectedCategory == GoldCategory.bars) ...[
            _buildBarsCountSelector(context),
            const SizedBox(height: 16),
          ],

          // Amount field (not shown for bars)
          if (_selectedCategory != GoldCategory.bars) ...[
            CustomTextField(
              controller: _amountController,
              label: 'amountOz'.tr(),
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.scale,
            ),
            const SizedBox(height: 16),
          ],

          // Total field
          CustomTextField(
            controller: _totalController,
            label: 'totalAmount'.tr(),
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money,
            readOnly: true,
          ),
          const SizedBox(height: 24),

          // Payment method
          Text(
            'paymentMethod'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Payment method checkboxes
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodCheckbox(
                  context,
                  title: 'walletPayment'.tr(),
                  icon: Icons.account_balance_wallet,
                  isSelected: _useWalletPayment,
                  onChanged: (value) {
                    setState(() {
                      _useWalletPayment = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentMethodCheckbox(
                  context,
                  title: 'cashTransfer'.tr(),
                  icon: Icons.payments,
                  isSelected: _useCashTransfer,
                  onChanged: (value) {
                    setState(() {
                      _useCashTransfer = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Transaction button
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(70),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomButton(
              text: isBuy
                  ? 'buyNow'.tr()
                  : 'sellNow'.tr(),
              onPressed: _executeTransaction,
              isLoading: _isLoading,
              type: ButtonType.primary,
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Transaction details
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'transactionDetails'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'pricePerOz'.tr(),
                  '\$${_getPriceForGoldType(_selectedCategory == GoldCategory.grams ? _selectedGramType.karat : '24K').toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'amount'.tr(),
                  '${_amount.toStringAsFixed(2)} ${_selectedCategory == GoldCategory.bars ? 'bars_count'.tr().toLowerCase() : 'oz'}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'fee'.tr(),
                  '\$${(_total * 0.01).toStringAsFixed(2)}',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  context,
                  'total'.tr(),
                  '\$${(_total + (_total * 0.01)).toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build gold type selector for grams
  Widget _buildGoldTypeSelector(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'goldType'.tr(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.goldColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GoldGramType>(
              value: _selectedGramType,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.goldDark,
              ),
              items: goldGramTypes.map((GoldGramType type) {
                return DropdownMenuItem<GoldGramType>(
                  value: type,
                  child: Text(type.translationKey.tr()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGramType = newValue;
                    _selectedGoldType = newValue.karat;
                    _calculateTotal();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build pound weight selector
  Widget _buildPoundWeightSelector(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'weight'.tr(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.goldColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GoldPoundWeight>(
              value: _selectedPoundWeight,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.goldDark,
              ),
              items: goldPoundWeights.map((GoldPoundWeight weight) {
                return DropdownMenuItem<GoldPoundWeight>(
                    value: weight,
                    child: Text(weight.translationKey.tr()));
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPoundWeight = newValue;
                    _calculateTotal();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build bars count selector
  Widget _buildBarsCountSelector(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'barsCount'.tr(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _barsCountController,
          hint: '1-20',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.view_module,
        ),
      ],
    );
  }

  // Build payment method checkbox
  Widget _buildPaymentMethodCheckbox(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.goldColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
            Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: AppTheme.goldDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
         
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppTheme.goldDark : null,
              ),
            ),
          ),
         Icon(
            icon,
            color: isSelected ? AppTheme.goldDark : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Build detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppTheme.goldDark : null,
              ),
        ),
      ],
    );
  }
}
