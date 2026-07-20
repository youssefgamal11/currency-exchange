import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class AppTextStyle {
  static const fontFamily = 'Inter';
  static const playfairFamily = 'PlayfairDisplaySC';

  static TextStyle r10  = TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, fontFamily: fontFamily, color: AppColors.blue, height: 1);

  static TextStyle m14  = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, fontFamily: fontFamily, color: AppColors.blue, height: 1);

  static TextStyle sb22 = TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, fontFamily: playfairFamily, color: AppColors.blue, height: 1.3);

  static TextStyle b11  = TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, fontFamily: fontFamily,     color: AppColors.blue, height: 1);

  
  static TextStyle eb16 = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, fontFamily: fontFamily,     color: AppColors.blue, height: 1);
}