import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

import 'mini_sparkline.dart';

class MiniCurrencyRow extends StatelessWidget {
  const MiniCurrencyRow({
    super.key,
    required this.flagAsset,
    required this.code,
    required this.rate,
    required this.changeLabel,
    required this.isPositive,
    required this.sparklinePoints,
  });

  final String flagAsset;
  final String code;
  final String rate;
  final String changeLabel;
  final bool isPositive;
  final List<double> sparklinePoints;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.good : AppColors.critical;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: SvgPicture.asset(
              flagAsset,
              width: 20.w,
              height: 18.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(code, style: AppTextStyle.b14)),
          MiniSparkline(
            points: sparklinePoints,
            color: color,
            width: 44.w,
            height: 16.h,
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTextStyle.b14,
                  children: [
                    const TextSpan(text: '= '),
                    TextSpan(text: rate, style: TextStyle(color: AppColors.accent)),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(changeLabel, style: AppTextStyle.r11.copyWith(color: color )),
            ],
          ),
        ],
      ),
    );
  }
}
