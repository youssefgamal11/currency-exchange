import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:axis/core%20/routing/route_name.dart';
import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:axis/features/currency_detail/presentation/args/currency_detail_args.dart';

import '../bloc/exchange_rates_bloc.dart';
import '../models/exchange_rates_view_data.dart';

class ExchangeRateListItem extends StatelessWidget {
  const ExchangeRateListItem({super.key, required this.item});

  final ExchangeRateViewData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        final lastUpdated = context.read<ExchangeRateBloc>().state.lastUpdated;
        Navigator.pushNamed(
          context,
          RouteName.currencyDetail,
          arguments: CurrencyDetailArgs(
            code: item.code,
            name: item.name,
            flagAsset: item.flagAsset,
            rate: item.rate,
            changeAbsolute: item.changeAbsolute,
            changePercent: item.changePercent,
            trend: item.trend,
            lastUpdated: lastUpdated,
          ),
        );
      },
      child: Container(
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
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    style: AppTextStyle.b14,
                    children: [
                      TextSpan(text: '1 ${item.code} = '),
                      TextSpan(text: item.rateLabel, style: const TextStyle(color: AppColors.accent)),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Text(item.changeLabel, style: AppTextStyle.r11.copyWith(color: item.color)),
              ],
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
