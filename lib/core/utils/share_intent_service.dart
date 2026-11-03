import 'package:flutter/services.dart';

/// One-shot bridge for Android ACTION_SEND text intents.
/// The native side retains the text until Dart consumes it, so cold starts
/// and intents delivered to an already-running singleTop activity are safe.
class ShareIntentService {
  static const MethodChannel _channel =
      MethodChannel('com.opennutritracker/share_intent');

  static void setOnSharedText(void Function() callback) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedTextAvailable') callback();
    });
  }

  static Future<String?> consumeSharedText() async {
    try {
      final text = await _channel.invokeMethod<String>('getSharedText');
      if (text == null || text.trim().isEmpty) return null;
      return text;
    } on MissingPluginException {
      return null;
    }
  }
}
