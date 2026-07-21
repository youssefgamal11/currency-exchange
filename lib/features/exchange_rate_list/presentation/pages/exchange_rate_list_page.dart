import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/utils/img_paths.dart';

import '../models/exchange_rate.dart';
import '../widgets/base_currency_selector.dart';
import '../widgets/exchange_rate_header.dart';
import '../widgets/exchange_rate_list_item.dart';
import '../widgets/update_status_row.dart';

class ExchangeRateListPage extends StatelessWidget {
  const ExchangeRateListPage({super.key});

  static const List<ExchangeRate> _rates = [
    ExchangeRate(
      code: 'USD',
      name: 'US Dollar',
      flagAsset: ImgPath.flagUsd,
      rate: '51.09',
      changeLabel: '+0.32 EGP',
      isPositive: true,
      sparklinePoints: [0.82, 0.55, 0.62, 0.3, 0.42, 0.12],
    ),
    ExchangeRate(
      code: 'EUR',
      name: 'Euro',
      flagAsset: ImgPath.flagEur,
      rate: '60.52',
      changeLabel: '-0.22 EGP',
      isPositive: false,
      sparklinePoints: [0.15, 0.4, 0.28, 0.6, 0.5, 0.78],
    ),
    ExchangeRate(
      code: 'GBP',
      name: 'British Pound',
      flagAsset: ImgPath.flagGbp,
      rate: '70.02',
      changeLabel: '-0.05 EGP',
      isPositive: false,
      sparklinePoints: [0.2, 0.42, 0.3, 0.58, 0.48, 0.7],
    ),
    ExchangeRate(
      code: 'SAR',
      name: 'Saudi Riyal',
      flagAsset: ImgPath.flagSar,
      rate: '13.87',
      changeLabel: '+0.02 EGP',
      isPositive: true,
      sparklinePoints: [0.8, 0.5, 0.6, 0.28, 0.38, 0.1],
    ),
    ExchangeRate(
      code: 'JPY',
      name: 'Japanese Yen',
      flagAsset: ImgPath.flagJpy,
      rate: '0.33',
      changeLabel: '+0.0009 EGP',
      isPositive: true,
      sparklinePoints: [0.85, 0.55, 0.65, 0.25, 0.4, 0.05],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExchangeRateHeader(onRefresh: () {}),
              SizedBox(height: 12.h),
              const UpdateStatusRow(updatedAt: '05:27 PM'),
              SizedBox(height: 16.h),
              const BaseCurrencySelector(),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: _rates.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) => ExchangeRateListItem(item: _rates[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
