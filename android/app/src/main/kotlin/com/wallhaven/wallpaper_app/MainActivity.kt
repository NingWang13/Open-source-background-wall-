package com.wallhaven.wallpaper_app

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wallhaven.wallpaper_app/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setWallpaper" -> {
                    val filePath = call.argument<String>("filePath")
                    val location = call.argument<Int>("location") ?: 0 // 0=both, 1=home, 2=lock
                    
                    if (filePath != null) {
                        try {
                            setWallpaper(filePath, location)
                            result.success("Wallpaper set successfully")
                        } catch (e: Exception) {
                            result.error("WALLPAPER_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                "getWallpaper" -> {
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun setWallpaper(filePath: String, location: Int) {
        val wallpaperManager = WallpaperManager.getInstance(context)
        val file = File(filePath)
        
        if (!file.exists()) {
            throw Exception("File not found: $filePath")
        }

        val bitmap = BitmapFactory.decodeFile(filePath)
        
        when (location) {
            1 -> { // Home screen
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }
            }
            2 -> { // Lock screen
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }
            }
            else -> { // Both
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }
            }
        }
    }
}