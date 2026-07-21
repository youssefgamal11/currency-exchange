import 'package:axis/core%20/utils/img_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class CurrencyFlagRow extends StatelessWidget {
  CurrencyFlagRow({super.key});

  final List<CurrencyFlagItem> items = [
    const CurrencyFlagItem(flagAsset:ImgPath.flagUsd , code: 'USD'),
    const CurrencyFlagItem(flagAsset:ImgPath.flagEur , code: 'EUR'),
    const CurrencyFlagItem(flagAsset:ImgPath.flagGbp , code: 'GBP'),
    const CurrencyFlagItem(flagAsset:ImgPath.flagSar , code: 'SAR'),
    const CurrencyFlagItem(flagAsset:ImgPath.flagJpy , code: 'JPY'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        items.length,
        (index) => Padding(
          padding:  EdgeInsetsDirectional.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: SvgPicture.asset(
                  items[index].flagAsset,
                  width: 22.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                items[index].code,
                style: AppTextStyle.b10.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyFlagItem {
  const CurrencyFlagItem({required this.flagAsset, required this.code});

  final String flagAsset;
  final String code;
}
