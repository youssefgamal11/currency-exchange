import 'package:axis/core%20/routing/route_name.dart';
import 'package:axis/core%20/storage/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

import '../widgets/brand_lockup.dart';
import '../widgets/currency_flag_row.dart';
import '../widgets/feature_pills_row.dart';
import '../widgets/onboarding_headline.dart';
import '../widgets/onboarding_hero.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLockup(),
              SizedBox(height: 24.h),
              const OnboardingHero(),
              SizedBox(height: 24.h),
              const OnboardingHeadline(),
              SizedBox(height: 10.h),
              Text(
                'Live EGP rates for USD, EUR, GBP, SAR & JPY — with daily changes, '
                '7-day history charts, and full offline support.',
                style: AppTextStyle.m12,
              ),
              SizedBox(height: 16.h),
              FeaturePillsRow(),
              SizedBox(height: 24.h),
              CurrencyFlagRow(),
              SizedBox(height: 35.h),
              PrimaryButton(label: 'Start Tracking Rates', onPressed: () async {
                await HiveStorage.setOnboardingSeen();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  RouteName.exchangeRateListPage,
                );
              }),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
