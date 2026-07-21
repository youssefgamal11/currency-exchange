import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:axis/features/_shared/widgets/mini_sparkline.dart';

import '../models/exchange_rate.dart';

class ExchangeRateListItem extends StatelessWidget {
  const ExchangeRateListItem({super.key, required this.item});

  final ExchangeRate item;

  @override
  Widget build(BuildContext context) {
    final color = item.isPositive ? AppColors.good : AppColors.critical;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Center(
              child: SvgPicture.asset(
                item.flagAsset,
                width: 18.w,
                height: 18.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
     
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.code, style: AppTextStyle.b14),
                SizedBox(height: 2.h),
                Text(item.name, style: AppTextStyle.m12),
              ],
            ),
          ),
          MiniSparkline(
            points: item.sparklinePoints,
            color: color,
            width: 44.w,
            height: 20.h,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTextStyle.b14,
                  children: [
                    TextSpan(text: '1 ${item.code} = '),
                    TextSpan(text: item.rate, style: const TextStyle(color: AppColors.accent)),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 12.sp,
                    color: color,
                  ),
                  SizedBox(width: 2.w),
                  Text(item.changeLabel, style: AppTextStyle.r11.copyWith(color: color)),
                ],
              ),
            ],
          ),
          SizedBox(width: 6.w),
          Icon(Icons.chevron_right_rounded, size: 20.sp, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
