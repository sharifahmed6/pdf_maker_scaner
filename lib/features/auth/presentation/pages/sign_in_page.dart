import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/auth_text_field.dart';
import '../../../../core/presentation/components/social_login_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Logo placeholder
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.picture_as_pdf, size: 48, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Back',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your account, Premium features, and cloud files.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Email/Password Form
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
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text('Forgot Password?', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sign In'),
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
              label: 'Continue with Google',
              icon: Icons.g_mobiledata, // Placeholder
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialLoginButton(
              label: 'Continue with Apple',
              icon: Icons.apple,
              onPressed: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Links
            TextButton(
              onPressed: () => context.push('/sign-up'),
              child: const Text("Don't have an account? Sign Up"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              child: const Text('Continue without account'),
            ),
          ],
        ),
      ),
    );
  }
}
