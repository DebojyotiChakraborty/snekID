import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../common/widgets/cupertino_card.dart';

/// Warning banner for low confidence results
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      color: AppColors.warning.withValues(alpha: 0.15),
      radius: const BorderRadius.all(Radius.circular(40)),
      borderSide: BorderSide(
        color: AppColors.warning.withValues(alpha: 0.5),
        width: 1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                MingCuteIcons.mgc_warning_line,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Text(
                    AppStrings.lowConfidenceWarning,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
