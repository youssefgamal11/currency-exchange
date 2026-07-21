import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:axis/core%20/utils/common_functions.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';

import '../../domain/entity/currency_history_point.dart';

class CurrencyHistoryChart extends StatelessWidget {
  const CurrencyHistoryChart({super.key, required this.history, required this.trend});

  final List<CurrencyHistoryPoint> history;
  final RateTrend trend;

  @override
  Widget build(BuildContext context) {
    final lineColor = switch (trend) {
      RateTrend.strengthening => AppColors.good,
      RateTrend.weakening => AppColors.critical,
      RateTrend.unchanged => AppColors.textTertiary,
    };

    final rates = history.map((p) => p.rate);
    final low = rates.reduce((a, b) => a < b ? a : b);
    final high = rates.reduce((a, b) => a > b ? a : b);
    final padding = (high - low) == 0 ? (high * 0.02).clamp(0.0001, double.infinity) : (high - low) * 0.15;

    return SizedBox(
      height: 180.h,
      child: LineChart(
        LineChartData(
          minY: low - padding,
          maxY: high + padding,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24.h,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= history.length) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      CommonFunctions.formatShortDate(history[index].date),
                      style: AppTextStyle.r11.copyWith(color: AppColors.textTertiary),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceElevated,
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(4),
                  AppTextStyle.b12.copyWith(color: AppColors.textPrimary),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < history.length; i++) FlSpot(i.toDouble(), history[i].rate),
              ],
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
