package com.beforeitcools.flutter_locatrip;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.beforeitcools.flutter_locatrip/secrets";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getApiKey")) {
                                String apiKey = BuildConfig.PLACES_API_KEY;
                                result.success(apiKey);
                            } else if (call.method.equals("getApiKey2")) {
                                String apiKey = BuildConfig.GEOCODING_API_KEY;
                                result.success(apiKey);
                            }else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
