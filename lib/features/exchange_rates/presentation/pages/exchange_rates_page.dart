import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import '../bloc/exchange_rate_bloc.dart';
import '../bloc/exchange_rate_events.dart';
import '../widgets/base_currency_selector.dart';
import '../widgets/exchange_rate_header.dart';
import '../widgets/exchange_rate_list_body.dart';
import '../widgets/update_status_row.dart';

class ExchangeRateListPage extends StatelessWidget {
  const ExchangeRateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExchangeRateHeader(
                onRefresh: () => context.read<ExchangeRateBloc>().add(
                  const GetExchangeRateEvent(),
                ),
              ),
              SizedBox(height: 12.h),
              const UpdateStatusRow(),
              SizedBox(height: 16.h),
              const BaseCurrencySelector(),
              SizedBox(height: 16.h),
              const Expanded(child: ExchangeRateListWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
