import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class CurrencyDetailHeader extends StatelessWidget {
  const CurrencyDetailHeader({
    super.key,
    required this.code,
    required this.name,
    required this.flagAsset,
  });

  final String code;
  final String name;
  final String flagAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
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
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.sp, color: AppColors.textPrimary),
          ),
        ),
        SizedBox(width: 12.w),
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
            child: SvgPicture.asset(flagAsset, width: 18.w, height: 18.w, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(code, style: AppTextStyle.eb18),
            Text(name, style: AppTextStyle.m12),
          ],
        ),
      ],
    );
  }
}
