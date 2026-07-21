import 'package:flutter/material.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/theme/text_style.dart';

class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyle.eb25,
        children: [
          const TextSpan(text: "Track the Pound's "),
          TextSpan(
            text: 'true value,',
            style: AppTextStyle.eb25.copyWith(color: AppColors.accent),
          ),
          const TextSpan(text: ' in real time.'),
        ],
      ),
    );
  }
}
