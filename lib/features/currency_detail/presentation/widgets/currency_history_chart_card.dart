import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

import '../bloc/currency_detail_bloc.dart';
import '../bloc/currency_detail_events.dart';
import '../bloc/currency_detail_states.dart';
import 'currency_history_chart.dart';
import 'currency_history_chart_error.dart';
import 'currency_history_chart_loading.dart';

class CurrencyHistoryChartCard extends StatelessWidget {
  const CurrencyHistoryChartCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-Day History', style: AppTextStyle.b14),
          SizedBox(height: 12.h),
          BlocBuilder<CurrencyDetailBloc, CurrencyDetailStates>(
            builder: (context, state) {
              if (state.status.isFailure) {
                return CurrencyHistoryChartError(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () => context.read<CurrencyDetailBloc>().add(
                    GetCurrencyHistoryEvent(code: code),
                  ),
                );
              }

              if (!state.status.isSuccess) {
                return const CurrencyHistoryChartLoading();
              }

              if (state.history.length < 2) {
                return CurrencyHistoryChartError(
                  message: 'Not enough history data to draw a chart.',
                  onRetry: () => context.read<CurrencyDetailBloc>().add(
                    GetCurrencyHistoryEvent(code: code),
                  ),
                );
              }

              return CurrencyHistoryChart(history: state.history, trend: state.weekTrend);
            },
          ),
        ],
      ),
    );
  }
}
