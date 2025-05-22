import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';
import 'package:golden_wallet/shared/widgets/custom_messages.dart';
import 'package:intl/intl.dart';

/// Screen for displaying gold price history
class GoldPriceHistoryScreen extends StatefulWidget {
  const GoldPriceHistoryScreen({super.key});

  @override
  State<GoldPriceHistoryScreen> createState() => _GoldPriceHistoryScreenState();
}

class _GoldPriceHistoryScreenState extends State<GoldPriceHistoryScreen> {
  late Future<GoldPriceData> _priceDataFuture;
  String _selectedKarat = '24K';
  String _selectedTimeRange = 'week';
  bool _showBuyPrice = true;
  bool _showSellPrice = true;

  @override
  void initState() {
    super.initState();
    _priceDataFuture = GoldDataService.loadGoldPrices();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'goldPriceHistory'.tr(),
        showBackButton: true,
      ),
      body: FutureBuilder<GoldPriceData>(
        future: _priceDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Show error message using CustomSnackBarMessages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.showErrorMessage(
                SnackBarTranslationKeys.dataLoadError.tr(),
                action: CustomSnackBarMessages.createRetryAction(() {
                  setState(() {
                    _priceDataFuture = GoldDataService.loadGoldPrices();
                  });
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
                    SnackBarTranslationKeys.dataLoadError.tr(),
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _priceDataFuture = GoldDataService.loadGoldPrices();
                      });
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

          if (!snapshot.hasData) {
            // Show info message using CustomSnackBarMessages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.showInfoMessage(
                'No price data available',
              );
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text('No price data available'),
                ],
              ),
            );
          }

          final priceData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Last updated info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.goldColor.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.update,
                        color: AppTheme.goldDark,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'lastUpdated'.tr() + priceData.formattedLastUpdated,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Current prices
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'currentPrice'.tr(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'karat'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: AppTheme.successColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'buy'.tr(),
                                  style: TextStyle(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: AppTheme.goldPriceDownColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'sell'.tr(),
                                  style: TextStyle(
                                    color: AppTheme.goldPriceDownColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      ...priceData.basePricePerGram.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: AppTheme.successColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.value.buy.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: AppTheme.successColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: AppTheme.goldPriceDownColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.value.sell.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: AppTheme.goldPriceDownColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Filter options
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'goldKarat'.tr(),
                        _selectedKarat,
                        ['24K', '21K', '20K', '18K'],
                        (value) {
                          setState(() {
                            _selectedKarat = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        'timeRange'.tr(),
                        _selectedTimeRange,
                        ['week', 'month', 'custom'],
                        (value) {
                          setState(() {
                            _selectedTimeRange = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price toggle
                Row(
                  children: [
                    _buildToggleChip(
                      'buyPrice'.tr(),
                      _showBuyPrice,
                      AppTheme.successColor,
                      (value) {
                        setState(() {
                          _showBuyPrice = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildToggleChip(
                      'sellPrice'.tr(),
                      _showSellPrice,
                      AppTheme.goldPriceDownColor,
                      (value) {
                        setState(() {
                          _showSellPrice = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Price chart
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Trend - $_selectedKarat',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildPriceChart(priceData),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price history table
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'priceHistory'.tr()} : $_selectedKarat',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceHistoryTable(priceData),
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

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.goldColor.withAlpha(50),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.goldDark,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    Color color,
    Function(bool?) onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: color.withAlpha(50),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPriceChart(GoldPriceData priceData) {
    final filteredHistory = _getFilteredHistory(priceData);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= filteredHistory.length ||
                    value.toInt() < 0) {
                  return const SizedBox.shrink();
                }

                final date = filteredHistory[value.toInt()].date;
                final dateStr = DateFormat('MM/dd').format(date);

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    '\$${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: filteredHistory.length - 1.0,
        minY: _getMinY(filteredHistory),
        maxY: _getMaxY(filteredHistory),
        lineBarsData: [
          if (_showBuyPrice)
            LineChartBarData(
              spots: _getBuySpots(filteredHistory),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor.withAlpha(128),
                  AppTheme.successColor,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor.withAlpha(77),
                    AppTheme.successColor.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          if (_showSellPrice)
            LineChartBarData(
              spots: _getSellSpots(filteredHistory),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldPriceDownColor.withAlpha(128),
                  AppTheme.goldPriceDownColor,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.goldPriceDownColor.withAlpha(77),
                    AppTheme.goldPriceDownColor.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryTable(GoldPriceData priceData) {
    final filteredHistory = _getFilteredHistory(priceData);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          isDarkMode ? Colors.grey[850] : Colors.grey[200],
        ),
        columns: [
          DataColumn(label: Text('date'.tr())),
          DataColumn(label: Text('buyPrice'.tr())),
          DataColumn(label: Text('sellPrice'.tr())),
          DataColumn(label: Text('spread'.tr())),
        ],
        rows: filteredHistory.map((history) {
          final buyPrice = history.prices[_selectedKarat]!.buy;
          final sellPrice = history.prices[_selectedKarat]!.sell;
          final spread = buyPrice - sellPrice;

          return DataRow(
            cells: [
              DataCell(Text(history.formattedDate)),
              DataCell(
                Text(
                  '\$${buyPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${sellPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.goldPriceDownColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${spread.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<GoldPriceHistory> _getFilteredHistory(GoldPriceData priceData) {
    final history = priceData.priceHistory;

    switch (_selectedTimeRange) {
      case 'week':
        return history.take(7).toList();
      case 'month':
        return history;
      case 'custom':
        // In a real app, you would implement a date range picker here
        return history.take(5).toList();
      default:
        return history;
    }
  }

  List<FlSpot> _getBuySpots(List<GoldPriceHistory> history) {
    return history.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final price = entry.value.prices[_selectedKarat]!.buy;
      return FlSpot(index, price);
    }).toList();
  }

  List<FlSpot> _getSellSpots(List<GoldPriceHistory> history) {
    return history.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final price = entry.value.prices[_selectedKarat]!.sell;
      return FlSpot(index, price);
    }).toList();
  }

  double _getMinY(List<GoldPriceHistory> history) {
    double minBuy = double.infinity;
    double minSell = double.infinity;

    for (final item in history) {
      final prices = item.prices[_selectedKarat]!;
      if (prices.buy < minBuy) minBuy = prices.buy;
      if (prices.sell < minSell) minSell = prices.sell;
    }

    return (min(minBuy, minSell) * 0.98).floorToDouble();
  }

  double _getMaxY(List<GoldPriceHistory> history) {
    double maxBuy = 0;
    double maxSell = 0;

    for (final item in history) {
      final prices = item.prices[_selectedKarat]!;
      if (prices.buy > maxBuy) maxBuy = prices.buy;
      if (prices.sell > maxSell) maxSell = prices.sell;
    }

    return (max(maxBuy, maxSell) * 1.02).ceilToDouble();
  }

  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}
