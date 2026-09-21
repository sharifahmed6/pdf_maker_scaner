import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PremiumBadge extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onTap;

  const PremiumBadge({
    super.key,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.premium.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 14, color: AppColors.premium),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: AppColors.premium,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.workspace_premium, color: AppColors.premium),
      onPressed: onTap,
      tooltip: 'Upgrade to Premium',
    );
  }
}
