import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import 'auth_provider.dart';

class EmailVerificationScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const EmailVerificationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have sent a verification link to your email address. Please check your inbox and verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                text: 'I Have Verified',
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).sendEmailVerification();
                  onContinue();
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Resend Verification Email',
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email resent!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
