import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:axis/core%20/utils/common_functions.dart';

import '../bloc/exchange_rates_bloc.dart';
import '../bloc/exchange_rates_states.dart';

class UpdateStatusRow extends StatelessWidget {
  const UpdateStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRateBloc, ExchangeRateStates>(
      buildWhen: (previous, current) => previous.lastUpdated != current.lastUpdated,
      builder: (context, state) {
        final updatedAt = state.lastUpdated != null
            ? CommonFunctions.formatTime(state.lastUpdated!)
            : '—';

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
      },
    );
  }
}
