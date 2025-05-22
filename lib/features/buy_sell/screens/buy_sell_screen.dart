import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_wallet/features/buy_sell/widgets/amount_input_field.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';
import 'package:golden_wallet/features/buy_sell/providers/gold_price_provider.dart';
import 'package:golden_wallet/features/buy_sell/widgets/gold_category_tab.dart';
import 'package:golden_wallet/features/buy_sell/widgets/gold_price_chart.dart';
import 'package:golden_wallet/features/buy_sell/widgets/gold_type_selector.dart';
import 'package:golden_wallet/features/buy_sell/widgets/payment_method_card.dart';
import 'package:golden_wallet/features/buy_sell/widgets/transaction_summary_card.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_messages.dart';

///  Buy/Sell Gold Screen
class BuySellScreen extends StatefulWidget {
  const BuySellScreen({super.key});

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _barsCountController = TextEditingController();

  // Payment methods
  String? _selectedPaymentMethodId;
  bool _isLoading = false;
  bool _isPriceChartExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _amountController.addListener(_updateAmount);
    _barsCountController.addListener(_updateBarsCount);

    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GoldPriceProvider>(context, listen: false);
      provider.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _totalController.dispose();
    _barsCountController.dispose();
    super.dispose();
  }

  // Update amount from text field
  void _updateAmount() {
    if (_amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(_amountController.text);
        final provider = Provider.of<GoldPriceProvider>(context, listen: false);
        provider.setAmount(amount);
        _totalController.text = provider.total.toStringAsFixed(2);
      } catch (e) {
        // Invalid input, ignore
      }
    } else {
      final provider = Provider.of<GoldPriceProvider>(context, listen: false);
      provider.setAmount(0.0);
      _totalController.text = '0.00';
    }
  }

  // Update bars count from text field
  void _updateBarsCount() {
    if (_barsCountController.text.isNotEmpty) {
      try {
        final count = int.parse(_barsCountController.text);
        if (count >= 1 && count <= 20) {
          final provider =
              Provider.of<GoldPriceProvider>(context, listen: false);
          provider.setBarsCount(count);
          _totalController.text = provider.total.toStringAsFixed(2);
        }
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  // Handle tab change
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final provider = Provider.of<GoldPriceProvider>(context, listen: false);
      provider.setIsBuying(_tabController.index == 0);
      _amountController.clear();
      _totalController.text = '0.00';
    }
  }

  // Execute transaction
  Future<void> _executeTransaction() async {
    // Validate payment method
    if (_selectedPaymentMethodId == null) {
      context.showErrorMessage(
        'selectPaymentMethod'.tr(),
        action: CustomSnackBarMessages.createDismissAction(() {
          // Dismiss action
        }),
      );
      return;
    }

    // Validate amount
    final provider = Provider.of<GoldPriceProvider>(context, listen: false);
    if (provider.amount <= 0 &&
        provider.selectedCategory != GoldCategory.bars) {
      context.showErrorMessage(
        'invalidAmount'.tr(),
        action: CustomSnackBarMessages.createDismissAction(() {
          // Dismiss action
        }),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show loading message
    context.showLoadingMessage(
      SnackBarTranslationKeys.processingRequest.tr(),
      showProgress: true,
    );

    // Simulate transaction delay
    await Future.delayed(const Duration(seconds: 2));

    // Show success message if still mounted
    if (mounted) {
      // Show success message
      context.showSuccessMessage(
        _tabController.index == 0 ? 'buySuccess'.tr() : 'sellSuccess'.tr(),
        duration: const Duration(seconds: 3),
        action: CustomSnackBarMessages.createAction(
          label: 'viewTransactions'.tr(),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.transactions);
          },
        ),
      );

      setState(() {
        _isLoading = false;
        _amountController.clear();
        _totalController.text = '0.00';
        _selectedPaymentMethodId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'buySellGold'.tr(),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.goldPriceHistory);
            },
            tooltip: 'Price History',
          ),
        ],
      ),
      body: Consumer<GoldPriceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            // Show error message using CustomSnackBarMessages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.showErrorMessage(
                provider.error,
                action: CustomSnackBarMessages.createRetryAction(() {
                  // Refresh data
                  final provider =
                      Provider.of<GoldPriceProvider>(context, listen: false);
                  provider.initialize();
                }),
              );
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error,
                    style: TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final provider = Provider.of<GoldPriceProvider>(context,
                          listen: false);
                      provider.initialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(SnackBarTranslationKeys.retry.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Tab bar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).primaryColor, // اللون النشط
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    unselectedLabelStyle:
                        Theme.of(context).textTheme.bodyMedium,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined),
                            const SizedBox(width: 6),
                            Text('buy'.tr()),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sell_outlined),
                            const SizedBox(width: 6),
                            Text('sell'.tr()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Gold price chart and current price
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              Colors.grey[850]!,
                              Colors.grey[900]!,
                            ]
                          : [
                              Colors.white,
                              Colors.grey[100]!,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.goldColor.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Price header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'currentPrice'.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '\$${provider.getCurrentPrice().toStringAsFixed(2)}/g',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.goldDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: provider.isPriceUp()
                                          ? AppTheme.successColor.withAlpha(25)
                                          : AppTheme.goldPriceDownColor
                                              .withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          provider.isPriceUp()
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: provider.isPriceUp()
                                              ? AppTheme.successColor
                                              : AppTheme.goldPriceDownColor,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          provider.getPriceChangePercentage(),
                                          style: TextStyle(
                                            color: provider.isPriceUp()
                                                ? AppTheme.successColor
                                                : AppTheme.goldPriceDownColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: AppTheme.goldDark,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'livePrice'.tr(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.goldDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Chart toggle button
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isPriceChartExpanded =
                                        !_isPriceChartExpanded;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    _isPriceChartExpanded
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppTheme.goldDark,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Price chart
                      if (_isPriceChartExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isPriceChartExpanded ? 1.0 : 0.0,
                            child: SizedBox(
                              height: 120,
                              child: GoldPriceChart(
                                height: 120,
                                isUptrend: provider.isPriceUp(),
                                showDetailTooltip: true,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Gold category tabs
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'goldCategory'.tr(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GoldCategoryTab(
                            category: GoldCategory.grams,
                            label: 'goldGrams'.tr(),
                            isSelected:
                                provider.selectedCategory == GoldCategory.grams,
                            onTap: () =>
                                provider.setCategory(GoldCategory.grams),
                          ),
                          const SizedBox(width: 12),
                          GoldCategoryTab(
                            category: GoldCategory.pounds,
                            label: 'goldPounds'.tr(),
                            isSelected: provider.selectedCategory ==
                                GoldCategory.pounds,
                            onTap: () =>
                                provider.setCategory(GoldCategory.pounds),
                          ),
                          const SizedBox(width: 12),
                          GoldCategoryTab(
                            category: GoldCategory.bars,
                            label: 'goldBars'.tr(),
                            isSelected:
                                provider.selectedCategory == GoldCategory.bars,
                            onTap: () =>
                                provider.setCategory(GoldCategory.bars),
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
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildTransactionForm(context, provider, isBuy: true),
                      _buildTransactionForm(context, provider, isBuy: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build transaction form
  Widget _buildTransactionForm(
    BuildContext context,
    GoldPriceProvider provider, {
    required bool isBuy,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      children: [
        // Gold type selector based on category
        if (provider.selectedCategory == GoldCategory.grams) ...[
          GoldTypeSelector(
            label: 'goldKarat'.tr(),
            options: provider.goldKarats,
            selectedOption: provider.selectedGoldType!,
            onChanged: (newValue) {
              provider.setGoldType(newValue);
              _totalController.text = provider.total.toStringAsFixed(2);
            },
          ),
          const SizedBox(height: 16),
        ] else if (provider.selectedCategory == GoldCategory.pounds)
          ...[

        ] else if (provider.selectedCategory == GoldCategory.bars) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'barSize'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.goldColor.withAlpha(50),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<GoldBar>(
                    value: provider.selectedBar,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.goldDark,
                    ),
                    items: provider.goldBars.map((GoldBar bar) {
                      return DropdownMenuItem<GoldBar>(
                        value: bar,
                        child: Text(
                          '${bar.name} (${bar.grams}g)',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _totalController.text =
                            provider.total.toStringAsFixed(2);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AmountInputField(
            label: 'barsCount'.tr(),
            hint: '1-20',
            controller: _barsCountController,
            unit: 'bars'.tr(),
            icon: Icons.view_module,
            showIncrement: true,
            onIncrement: provider.incrementBarsCount,
            onDecrement: provider.decrementBarsCount,
            helperText: 'eachBar24k'.tr(),
          ),
          const SizedBox(height: 16),
        ],

        // Amount field (not shown for bars)
        if (provider.selectedCategory != GoldCategory.bars) ...[
          AmountInputField(
            label: 'amount'.tr(),
            hint: '0.00',
            controller: _amountController,
            unit:
                provider.selectedCategory == GoldCategory.grams ? 'g' : 'units',
            icon: Icons.scale,
            onChanged: (value) => _updateAmount(),
          ),
          const SizedBox(height: 16),
        ],

        // Total field
        AmountInputField(
          label: 'totalAmount'.tr(),
          hint: '0.00',
          controller: _totalController,
          unit: '\$',
          icon: Icons.attach_money,
          readOnly: true,
        ),
        const SizedBox(height: 24),

        // Payment method
        Text(
          'paymentMethod'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Payment method cards
        Column(
          children: provider.paymentMethods.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PaymentMethodCard(
                title: method.name,
                icon: method.icon,
                isSelected: _selectedPaymentMethodId == method.id,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethodId = method.id;
                  });
                },
                subtitle: method.id == 'wallet'
                    ? '${'walletBalance'.tr()}: \$5,240.00'
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Transaction button
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(70),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomButton(
            text: isBuy ? 'buyNow'.tr() : 'sellNow'.tr(),
            onPressed: _executeTransaction,
            isLoading: _isLoading,
            type: ButtonType.primary,
            backgroundColor: Colors.transparent,
            textColor: Colors.white,
            height: 56,
            icon: isBuy ? Icons.shopping_cart : Icons.sell,
          ),
        ),
        const SizedBox(height: 24),

        // Transaction details
        TransactionSummaryCard(
          title: 'transactionDetails'.tr(),
          details: [
            TransactionDetail(
              label: 'pricePerGram'.tr(),
              value: '\$${provider.getCurrentPrice().toStringAsFixed(2)}',
            ),
            TransactionDetail(
              label: 'amount'.tr(),
              value: provider.selectedCategory == GoldCategory.bars
                  ? '${provider.barsCount} ${provider.selectedBar?.name ?? ""}'
                  : '${provider.amount.toStringAsFixed(2)} ${provider.selectedCategory == GoldCategory.grams ? "g" : "units"}',
            ),
            TransactionDetail(
              label: 'fee'.tr(),
              value: '\$${(provider.total * 0.01).toStringAsFixed(2)}',
            ),
          ],
          total: TransactionDetail(
            label: 'total'.tr(),
            value:
                '\$${(provider.total + (provider.total * 0.01)).toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }
}
