import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/candlestick_model.dart';

class CryptoChart extends StatefulWidget {
  final List<CandlestickModel> candlesticks;
  final bool isLineOnly;
  final String selectedTimeframe;
  final Function(String)? onTimeframeChanged;

  const CryptoChart({
    super.key,
    required this.candlesticks,
    this.isLineOnly = false,
    this.selectedTimeframe = '1H',
    this.onTimeframeChanged,
  });

  @override
  State<CryptoChart> createState() => _CryptoChartState();
}

class _CryptoChartState extends State<CryptoChart> {
  final List<String> timeframes = ['1m', '5m', '15m', '1H', '4H', '1D', '1W'];

  @override
  Widget build(BuildContext context) {
    if (widget.candlesticks.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isBullish = widget.candlesticks.last.close >= widget.candlesticks.first.open;
    final chartColor = isBullish ? AppColors.profitGreen : AppColors.lossRed;

    return Column(
      children: [
        if (widget.onTimeframeChanged != null)
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: timeframes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tf = timeframes[index];
                final isSelected = tf == widget.selectedTimeframe;
                return ChoiceChip(
                  label: Text(tf),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && widget.onTimeframeChanged != null) {
                      widget.onTimeframeChanged!(tf);
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
        SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 12, bottom: 8),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value >= 1000 ? '\$${(value / 1000).toStringAsFixed(1)}k' : '\$${value.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.candlesticks.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.close);
                    }).toList(),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withAlpha(25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
