import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class FeaturePillsRow extends StatelessWidget {
  const FeaturePillsRow({super.key});

  final List<String> labels = const ['Live Rates', '7-Day Charts', 'Offline Cache', 'Daily Δ']    ;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7.w,
      runSpacing: 7.h,
      children: List.generate(labels.length, (index)=>Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Text(labels[index], style: AppTextStyle.m12),
            ),)
  
    );
  }
}
