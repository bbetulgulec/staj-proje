package com.example.my_wear_os_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.my_wear_os_app/data";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("sendDataToWearOS")) {
                        String data = call.argument("data");
                        // Veriyi Wear OS cihazına gönderin
                        result.success("Data sent: " + data);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
}
