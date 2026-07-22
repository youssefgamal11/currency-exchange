import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class CurrentRateCard extends StatelessWidget {
  const CurrentRateCard({super.key, required this.code, required this.rate});

  final String code;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.accentTint,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Rate', style: AppTextStyle.m12),
          SizedBox(height: 8.h),
          Text.rich(
            TextSpan(
              style: AppTextStyle.eb25.copyWith(color: AppColors.accent),
              children: [
                const TextSpan(text: '1 '),
                TextSpan(text: '$code = '),
                TextSpan(text: rate.toStringAsFixed(2)),
                const TextSpan(text: ' EGP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
