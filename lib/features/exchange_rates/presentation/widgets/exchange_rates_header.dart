import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class ExchangeRateHeader extends StatelessWidget {
  const ExchangeRateHeader({super.key, this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Exchange Rates', style: AppTextStyle.eb25),
        InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Icon(Icons.refresh_rounded, size: 18.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
