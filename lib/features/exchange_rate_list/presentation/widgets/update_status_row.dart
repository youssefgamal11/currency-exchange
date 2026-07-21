import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class UpdateStatusRow extends StatelessWidget {
  const UpdateStatusRow({super.key, required this.updatedAt});

  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: const BoxDecoration(color: AppColors.good, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text('Updated $updatedAt', style: AppTextStyle.m12),
      ],
    );
  }
}
