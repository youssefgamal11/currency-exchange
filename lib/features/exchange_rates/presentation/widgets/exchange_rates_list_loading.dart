import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:axis/core%20/theme/colors.dart';

class ExchangeRateListLoading extends StatelessWidget {
  const ExchangeRateListLoading({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.borderStrong,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => const _ShimmerListItem(),
      ),
    );
  }
}

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        children: [
          ShimmarContainer(width: 36.w, height: 36.w, radius: 8.r),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmarContainer(width: 44.w, height: 12.h, radius: 4.r),
              SizedBox(height: 6.h),
              ShimmarContainer(width: 72.w, height: 10.h, radius: 4.r),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmarContainer(width: 96.w, height: 12.h, radius: 4.r),
              SizedBox(height: 8.h),
              ShimmarContainer(width: 64.w, height: 10.h, radius: 4.r),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmarContainer extends StatelessWidget {
  const ShimmarContainer({super.key, required this.width, required this.height, required this.radius});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
