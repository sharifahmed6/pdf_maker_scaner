import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/components/premium_benefit_tile.dart';
import '../../../../core/presentation/components/subscription_plan_card.dart';

class PremiumPaywallPage extends StatefulWidget {
  const PremiumPaywallPage({super.key});

  @override
  State<PremiumPaywallPage> createState() => _PremiumPaywallPageState();
}

class _PremiumPaywallPageState extends State<PremiumPaywallPage> {
  bool isYearlySelected = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Restore', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Area
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.premium.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, size: 64, color: AppColors.premium),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unlock Premium',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Get more from your PDF workflow.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Benefits List
            const PremiumBenefitTile(
              title: 'PDF to Word Conversion',
              description: 'Convert your PDFs into editable Word documents securely on the cloud.',
            ),
            const PremiumBenefitTile(
              title: 'AI PDF Summary',
              description: 'Quickly get the main points and summary of long documents.',
            ),
            const PremiumBenefitTile(
              title: 'Chat with PDF',
              description: 'Ask questions and get instant answers from your documents.',
            ),
            const PremiumBenefitTile(
              title: 'AI OCR',
              description: 'Advanced AI text recognition that preserves formatting and tables.',
            ),
            const PremiumBenefitTile(
              title: 'Cloud Sync',
              description: 'Securely sync your files across all your devices.',
            ),
            const PremiumBenefitTile(
              title: 'Ad-Free Experience',
              description: 'Enjoy a completely uninterrupted, ad-free workflow.',
            ),
            
            const SizedBox(height: 32),
            
            // Subscription Plans
            Row(
              children: [
                Expanded(
                  child: SubscriptionPlanCard(
                    title: 'MONTHLY',
                    price: '\$2.99',
                    duration: 'month',
                    isSelected: !isYearlySelected,
                    onTap: () => setState(() => isYearlySelected = false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SubscriptionPlanCard(
                    title: 'YEARLY',
                    price: '\$19.99',
                    duration: 'year',
                    isSelected: isYearlySelected,
                    isHighlighted: true,
                    onTap: () => setState(() => isYearlySelected = true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // CTA
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Start Premium'),
            ),
            
            const SizedBox(height: 24),
            
            // Legal
            Text(
              'Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Terms of Service', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                ),
                Text('•', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                TextButton(
                  onPressed: () {},
                  child: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
