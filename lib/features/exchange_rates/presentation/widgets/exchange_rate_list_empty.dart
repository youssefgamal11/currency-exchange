import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class ExchangeRateListEmpty extends StatelessWidget {
  const ExchangeRateListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 32.sp, color: AppColors.textTertiary),
          SizedBox(height: 8.h),
          Text('No exchange rates available', style: AppTextStyle.m12),
        ],
      ),
    );
  }
}
