import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentStrong, AppColors.accent],
            ),
          ),
          child: Text(
            '£',
            style: AppTextStyle.eb18.copyWith(color: const Color(0xFF241605)),
          ),
        ),
        SizedBox(width: 11.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Currency Exchange Tracker', style: AppTextStyle.eb16),
            Text('EGP Exchange Tracker', style: AppTextStyle.m12),
          ],
        ),
      ],
    );
  }
}
