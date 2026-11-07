import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _doneKey = 'onboarding_done';

  static Future<bool> isDone() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_doneKey) ?? false;
    } catch (_) {
      // If storage is unavailable, don't trap the user on the intro screen.
      return true;
    }
  }

  static Future<void> markDone() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_doneKey, true);
    } catch (_) {}
  }
}

/// Whether the first-run intro was already completed. main() overrides this
/// with the stored value; the default (true) keeps tests and previews on /home.
final onboardingDoneProvider = Provider<bool>((ref) => true);
