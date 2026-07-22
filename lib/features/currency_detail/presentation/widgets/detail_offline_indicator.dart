import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

import '../bloc/currency_detail_bloc.dart';
import '../bloc/currency_detail_states.dart';

class DetailOfflineIndicator extends StatelessWidget {
  const DetailOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyDetailBloc, CurrencyDetailStates>(
      buildWhen: (p, c) => p.isOffline != c.isOffline,
      builder: (context, state) {
        if (!state.isOffline) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Text('Offline .', style: AppTextStyle.m12),
            ],
          ),
        );
      },
    );
  }
}
