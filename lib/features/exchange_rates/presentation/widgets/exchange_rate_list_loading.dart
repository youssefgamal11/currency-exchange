import 'package:flutter/material.dart';

import 'package:axis/core%20/theme/colors.dart';

class ExchangeRateListLoading extends StatelessWidget {
  const ExchangeRateListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
