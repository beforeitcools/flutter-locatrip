import 'package:flutter/services.dart';

class KakaoKeyLoader {
  static const MethodChannel _channel = MethodChannel('api_key_loader');

  static Future<String?> getNativeAppKey(String key) async {
    const platform =
        MethodChannel('com.beforeitcools.flutter_locatrip/secrets');
    try {
      final apiKey = await platform.invokeMethod<String>('getApiKey');
      print('apikey $apiKey');
      return apiKey ?? '';
    } catch (e) {
      print("Failed to get API key: $e");
      return '';
    }
  }

  /*static Future<String?> getApiKey2(String key) async {
    const platform =
    MethodChannel('com.beforeitcools.flutter_locatrip/secrets');
    try {
      final apiKey = await platform.invokeMethod<String>('getApiKey2');

      return apiKey ?? '';
    } catch (e) {
      print("Failed to get API key: $e");
      return '';
    }
  }*/
}
