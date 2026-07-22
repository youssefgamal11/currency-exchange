import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/utils/common_functions.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';

import '../args/currency_detail_args.dart';
import 'stat_card.dart';

class StatCardGrid extends StatelessWidget {
  const StatCardGrid({super.key, required this.args});

  final CurrencyDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final changeColor = switch (args.trend) {
      RateTrend.strengthening => AppColors.good,
      RateTrend.weakening => AppColors.critical,
      RateTrend.unchanged => AppColors.textTertiary,
    };

    final trendIcon = switch (args.trend) {
      RateTrend.strengthening => Icons.arrow_upward,
      RateTrend.weakening => Icons.arrow_downward,
      RateTrend.unchanged => null,
    };

    final updatedLabel = args.lastUpdated == null
        ? '—'
        : CommonFunctions.formatShortDate(args.lastUpdated!);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 2.4,
      children: [
        StatCard(
          label: 'Daily Change',
          value: args.changeAbsolute.abs().toStringAsFixed(2),
          valueColor: changeColor,
          icon: trendIcon,
        ),
        StatCard(
          label: 'Change %',
          value: '${args.changePercent.abs().toStringAsFixed(2)}%',
          valueColor: changeColor,
          icon: trendIcon,
        ),
        StatCard(label: 'Yesterday', value: args.yesterdayRate.toStringAsFixed(2)),
        StatCard(label: 'Last Update', value: updatedLabel),
      ],
    );
  }
}
