import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/onboarding_prefs.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'القرآن والأذكار',
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 32,
                  color: AppColors.deepEmerald,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'رفيقك للقرآن والأذكار ومواقيت الصلاة، بدون إنترنت',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  await OnboardingPrefs.markDone();
                  if (context.mounted) context.go('/home');
                },
                child: const Text('ابدأ الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
