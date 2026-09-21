import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.isSelected,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isHighlighted ? AppColors.premium.withValues(alpha: 0.1) : theme.colorScheme.primaryContainer)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? (isHighlighted ? AppColors.premium : theme.colorScheme.primary)
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (isHighlighted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.premium,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? (isHighlighted ? AppColors.premium : theme.colorScheme.primary) : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '/ $duration',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
