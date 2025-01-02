package com.beforeitcools.flutter_locatrip;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;


public class MainActivity extends FlutterActivity {

    // Define a variable to hold the Places API key.
    String apiKey = BuildConfig.PLACES_API_KEY;

    // Log an error if apiKey is not set.
    if (TextUtils.isEmpty(apiKey) || apiKey.equals("DEFAULT_API_KEY")) {
        Log.e("Places test", "No api key");
        finish();
        return;
    }

    // Initialize the SDK
    Places.initializeWithNewPlacesApiEnabled(getApplicationContext(), apiKey);

    // Create a new PlacesClient instance
    PlacesClient placesClient = Places.createClient(this);

    /*private static final String CHANNEL = "com.beforeitcools.flutter_locatrip/secrets";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getApiKey")) {
                                String apiKey = BuildConfig.PLACES_API_KEY; // Replace with PLACES_API_KEY if needed
                                result.success(apiKey);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }*/
}
