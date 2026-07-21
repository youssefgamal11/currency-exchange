import 'package:axis/core%20/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/utils/img_paths.dart';

import 'mini_currency_row.dart';

class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          MiniCurrencyRow(
            flagAsset: ImgPath.flagUsd,
            code: 'USD',
            rate: '52.01',
            changeLabel: '0.14 EGP',
            isPositive: true,
            sparklinePoints: const [0.82, 0.55, 0.62, 0.3, 0.42, 0.12],
          ),
          Divider(color: AppColors.border, height: 16.h, thickness: 1.h),
          MiniCurrencyRow(
            flagAsset: ImgPath.flagEur,
            code: 'EUR',
            rate: '60.52',
            changeLabel: '0.22 EGP',
            isPositive: false,
            sparklinePoints: const [0.15, 0.4, 0.28, 0.6, 0.5, 0.78],
          ),
          Divider(color: AppColors.border, height: 16.h, thickness: 1.h),
          MiniCurrencyRow(
            flagAsset: ImgPath.flagGbp,
            code: 'GBP',
            rate: '70.02',
            changeLabel: '0.05 EGP',
            isPositive: false,
            sparklinePoints: const [0.2, 0.42, 0.3, 0.58, 0.48, 0.7],
          ),
          Divider(color: AppColors.border, height: 16.h, thickness: 1.h),
          MiniCurrencyRow(
            flagAsset: ImgPath.flagSar,
            code: 'SAR',
            rate: '13.87',
            changeLabel: '0.02 EGP',
            isPositive: true,
            sparklinePoints: const [0.8, 0.5, 0.6, 0.28, 0.38, 0.1],
          ),
          Divider(color: AppColors.border, height: 16.h, thickness: 1.h),
          MiniCurrencyRow(
            flagAsset: ImgPath.flagJpy,
            code: 'JPY',
            rate: '0.33',
            changeLabel: '0.0009 EGP',
            isPositive: true,
            sparklinePoints: const [0.85, 0.55, 0.65, 0.25, 0.4, 0.05],
          ),
        ],
      ),
    );
  }
}
