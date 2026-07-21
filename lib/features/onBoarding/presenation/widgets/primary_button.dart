import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accentStrong, AppColors.accent],
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyle.b15.copyWith(color: const Color(0xFF241605)),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18.sp,
                color: const Color(0xFF241605),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
