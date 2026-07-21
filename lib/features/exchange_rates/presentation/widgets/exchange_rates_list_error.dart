import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class ExchangeRateListError extends StatelessWidget {
  const ExchangeRateListError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 32.sp, color: AppColors.critical),
          SizedBox(height: 8.h),
          Text(message, style: AppTextStyle.m12, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyle.b14.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
