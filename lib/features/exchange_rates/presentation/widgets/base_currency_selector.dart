import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:axis/core%20/utils/img_paths.dart';

class BaseCurrencySelector extends StatelessWidget {
  const BaseCurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.accentStrong, width: .3.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: SvgPicture.asset(
                  ImgPath.flagEgy,
                  width: 20.w,
                  height: 18.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Egyptian Pound (EGP)',
                style: AppTextStyle.b12.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Text('Base currency', style: AppTextStyle.m12),
      ],
    );
  }
}
