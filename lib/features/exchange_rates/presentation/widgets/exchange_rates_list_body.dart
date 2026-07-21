import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/exchange_rate_bloc.dart';
import '../bloc/exchange_rate_events.dart';
import '../bloc/exchange_rate_states.dart';
import 'exchange_rate_list_empty.dart';
import 'exchange_rate_list_error.dart';
import 'exchange_rate_list_item.dart';
import 'exchange_rate_list_loading.dart';

class ExchangeRateListWidget extends StatelessWidget {
  const ExchangeRateListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRateBloc, ExchangeRateStates>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        if (state.status.isSuccess) {
          if (state.exchangeRateList.isEmpty) {
            return const ExchangeRateListEmpty();
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ExchangeRateBloc>().add(const GetExchangeRateEvent()),
            child: ListView.separated(
              itemBuilder: (context, index) {
                return ExchangeRateListItem(item: state.exchangeRateList[index]);
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 12.h);
              },
              itemCount: state.exchangeRateList.length,
            ),
          );
        } else if (state.status.isFailure) {
          return ExchangeRateListError(
            message: state.errorMessage ?? 'Something went wrong',
            onRetry: () =>
                context.read<ExchangeRateBloc>().add(const GetExchangeRateEvent()),
          );
        } else {
          return const ExchangeRateListLoading();
        }
      },
    );
  }
}
