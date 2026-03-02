package com.example.applicazione_psnat

import android.content.ContentValues
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "save_qr_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "saveImage") {

                    val bytes = call.argument<ByteArray>("bytes")
                    val name = call.argument<String>("name")

                    if (bytes == null || name == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    val resolver = applicationContext.contentResolver

                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, "$name.png")
                        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/QR Boxes")
                    }

                    val uri = resolver.insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        contentValues
                    )

                    if (uri != null) {
                        resolver.openOutputStream(uri)?.use { stream ->
                            stream.write(bytes)
                            result.success(true)
                        }
                    } else {
                        result.success(false)
                    }
                }
            }
    }
}
