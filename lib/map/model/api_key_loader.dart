import 'package:flutter/services.dart';

class ApiKeyLoader {
  static Future<String?> getApiKey(String key) async {
    /*try {
      final String? apiKey =
          await _channel.invokeMethod('getApiKey', {'key': key});
      return apiKey;
    } catch (e) {
      print("Error loading API Key: $e");
      return null;
    }*/
    const platform =
        MethodChannel('com.beforeitcools.flutter_locatrip/secrets');
    try {
      final apiKey = await platform.invokeMethod<String>('getApiKey');
      // print('apikey $apiKey');
      return apiKey ?? '';
    } catch (e) {
      print("Failed to get API key: $e");
      return '';
    }
  }

  static Future<String?> getApiKey2(String key) async {
    const platform =
        MethodChannel('com.beforeitcools.flutter_locatrip/secrets');
    try {
      final apiKey = await platform.invokeMethod<String>('getApiKey2');

      return apiKey ?? '';
    } catch (e) {
      print("Failed to get API key: $e");
      return '';
    }
  }
}
