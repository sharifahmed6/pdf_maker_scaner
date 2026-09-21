import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Mock state
  final bool isLoggedIn = false; // Toggle this for testing
  final bool isPremium = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account', theme),
          if (isLoggedIn) ...[
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_outline),
              ),
              title: const Text('John Doe'),
              subtitle: const Text('john.doe@example.com'),
              trailing: isPremium 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'PREMIUM', 
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                : const Text('FREE'),
            ),
            const Divider(),
            _buildListTile(Icons.cloud_outlined, 'Cloud Sync', theme, onTap: () {}),
            _buildListTile(Icons.credit_card, 'Manage Subscription', theme, onTap: () {}),
            _buildListTile(Icons.refresh, 'Restore Purchase', theme, onTap: () {}),
            _buildListTile(Icons.logout, 'Sign Out', theme, onTap: () {}, color: theme.colorScheme.error),
          ] else ...[
            _buildListTile(Icons.login, 'Sign In / Create Account', theme, onTap: () => context.push('/sign-in')),
            _buildListTile(Icons.workspace_premium, 'Upgrade to Premium', theme, onTap: () => context.push('/premium'), color: Colors.amber[700]),
          ],
          
          const SizedBox(height: 16),
          
          // Appearance
          _buildSectionHeader('Appearance', theme),
          _buildListTile(Icons.dark_mode_outlined, 'Theme', theme, trailing: const Text('System Default')),
          _buildListTile(Icons.language, 'Language', theme, trailing: const Text('English')),

          const SizedBox(height: 16),

          // App
          _buildSectionHeader('App', theme),
          _buildListTile(Icons.access_time, 'Recent Files', theme, trailing: const Icon(Icons.chevron_right, size: 20)),
          _buildListTile(Icons.settings, 'Default PDF Quality', theme, trailing: const Text('High')),

          const SizedBox(height: 16),

          // About
          _buildSectionHeader('About', theme),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', theme, trailing: const Icon(Icons.chevron_right, size: 20)),
          _buildListTile(Icons.description_outlined, 'Terms of Service', theme, trailing: const Icon(Icons.chevron_right, size: 20)),
          _buildListTile(Icons.star_border, 'Rate App', theme, trailing: const Icon(Icons.chevron_right, size: 20)),
          _buildListTile(Icons.mail_outline, 'Contact Us', theme, trailing: const Icon(Icons.chevron_right, size: 20)),
          
          const SizedBox(height: 32),
          
          // Version info
          Center(
            child: Text(
              'PDF Tools v1.0.0',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, ThemeData theme, {Widget? trailing, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
