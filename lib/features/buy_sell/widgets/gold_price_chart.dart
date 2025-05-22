import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:golden_wallet/config/theme.dart';

/// Widget for displaying gold price chart
class GoldPriceChart extends StatelessWidget {
  final double height;
  final bool isUptrend;
  final bool showDetailTooltip;

  const GoldPriceChart({
    super.key,
    required this.height,
    required this.isUptrend,
    this.showDetailTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isUptrend ? AppTheme.successColor : AppTheme.goldPriceDownColor;

    // Sample data points - in a real app, this would come from the provider
    final spots = _getSampleSpots();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Only show a few labels to avoid crowding
                  if (value % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  
                  // In a real app, these would be actual dates
                  final labels = ['Mon', 'Wed', 'Fri', 'Sun'];
                  final index = value ~/ 2;
                  
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 6,
          minY: 65,
          maxY: 75,
          lineTouchData: LineTouchData(
            enabled: showDetailTooltip,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: isDarkMode ? Colors.grey[800]! : Colors.white,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(128),
                  color,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(77),
                    color.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate sample data points for the chart
  List<FlSpot> _getSampleSpots() {
    if (isUptrend) {
      return [
        const FlSpot(0, 70.2),
        const FlSpot(1, 70.5),
        const FlSpot(2, 71.3),
        const FlSpot(3, 71.0),
        const FlSpot(4, 71.8),
        const FlSpot(5, 72.1),
        const FlSpot(6, 72.5),
      ];
    } else {
      return [
        const FlSpot(0, 72.5),
        const FlSpot(1, 72.1),
        const FlSpot(2, 71.8),
        const FlSpot(3, 71.0),
        const FlSpot(4, 71.3),
        const FlSpot(5, 70.5),
        const FlSpot(6, 70.2),
      ];
    }
  }
}
