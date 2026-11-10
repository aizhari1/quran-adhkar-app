import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays a bundled adhan (Android raw resource) so the user can hear a voice
/// before choosing it.
class AdhanPreview {
  static const _channel = MethodChannel('quran_adhkar/audio');

  static Future<void> play(String rawName) async {
    try {
      await _channel.invokeMethod<bool>('preview', rawName);
    } on MissingPluginException {
      // not on Android
    } catch (e) {
      debugPrint('adhan preview failed: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopPreview');
    } on MissingPluginException {
      // not on Android
    } catch (e) {
      debugPrint('adhan preview stop failed: $e');
    }
  }
}
