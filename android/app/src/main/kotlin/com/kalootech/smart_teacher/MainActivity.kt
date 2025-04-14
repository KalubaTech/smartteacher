package com.kalootech.smart_teacher

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "smart_teacher/files"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "savePdf") {
                val fileName = call.argument<String>("fileName")
                val pdfBytes = call.argument<ByteArray>("pdfBytes")

                if (fileName != null && pdfBytes != null) {
                    val savedPath = savePdfToMediaStore(fileName, pdfBytes)
                    if (savedPath != null) {
                        result.success(savedPath)
                    } else {
                        result.error("SAVE_ERROR", "Failed to save PDF", null)
                    }
                } else {
                    result.error("ARGUMENT_ERROR", "Invalid arguments", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun savePdfToMediaStore(fileName: String, pdfBytes: ByteArray): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                put(MediaStore.Downloads.RELATIVE_PATH, "Documents/Smart Teacher")
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            uri?.let {
                resolver.openOutputStream(it)?.use { outputStream ->
                    outputStream.write(pdfBytes)
                    outputStream.flush()
                    return it.toString()
                }
            }
            null
        } else {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
            val targetDir = File(downloadsDir, "Smart Teacher")
            if (!targetDir.exists()) targetDir.mkdirs()

            val file = File(targetDir, fileName)
            FileOutputStream(file).use { outputStream ->
                outputStream.write(pdfBytes)
                outputStream.flush()
            }
            file.absolutePath
        }
    }
}
