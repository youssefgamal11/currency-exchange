import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';

import '../args/currency_detail_args.dart';
import '../widgets/currency_detail_header.dart';
import '../widgets/currency_history_chart_card.dart';
import '../widgets/current_rate_card.dart';
import '../widgets/stat_card_grid.dart';

class CurrencyDetailPage extends StatelessWidget {
  const CurrencyDetailPage({super.key, required this.args});

  final CurrencyDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrencyDetailHeader(code: args.code, name: args.name, flagAsset: args.flagAsset),
                SizedBox(height: 20.h),
                CurrentRateCard(code: args.code, rate: args.rate),
                SizedBox(height: 16.h),
                StatCardGrid(args: args),
                SizedBox(height: 16.h),
                CurrencyHistoryChartCard(code: args.code),
                SizedBox(height: 16.h),
                // const InvertedRateInfoBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
