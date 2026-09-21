import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/auth_text_field.dart';
import '../../../../core/presentation/components/social_login_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_outlined, size: 36, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create Your Account',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to use Premium features and sync your files.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            const AuthTextField(
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              hintText: 'Email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (val) {},
                  activeColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {},
              child: const Text('Create Account'),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
                Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
              ],
            ),
            const SizedBox(height: 24),
            
            // Social Auth
            SocialLoginButton(
              label: 'Sign up with Google',
              icon: Icons.g_mobiledata, // Placeholder
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialLoginButton(
              label: 'Sign up with Apple',
              icon: Icons.apple,
              onPressed: () {},
            ),
            
            const SizedBox(height: 24),
            
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Already have an account? Sign In"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
