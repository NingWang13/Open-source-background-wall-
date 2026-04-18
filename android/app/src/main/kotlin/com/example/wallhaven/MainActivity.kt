package com.example.wallhaven

import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.IOException
import java.net.URL

class MainActivity: FlutterActivity() {
    private val CHANNEL = "wallhaven/wallpaper"
    private val scope = CoroutineScope(Dispatchers.Main + Job())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "setWallpaper" -> {
                    val url = call.argument<String>("url")
                    val screen = call.argument<String>("screen") ?: "home"
                    if (url != null) {
                        scope.launch {
                            try {
                                setWallpaperFromUrl(url, screen)
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("WALLPAPER_ERROR", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "URL is required", null)
                    }
                }
                "setWallpaperFromFile" -> {
                    val path = call.argument<String>("path")
                    val screen = call.argument<String>("screen") ?: "home"
                    if (path != null) {
                        scope.launch {
                            try {
                                setWallpaperFromFile(path, screen)
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("WALLPAPER_ERROR", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private suspend fun setWallpaperFromUrl(url: String, screen: String) {
        withContext(Dispatchers.IO) {
            try {
                val bitmap = BitmapFactory.decodeStream(URL(url).openStream())
                setBitmapAsWallpaper(bitmap, screen)
            } catch (e: IOException) {
                throw Exception("Failed to download image: ${e.message}")
            }
        }
    }

    private suspend fun setWallpaperFromFile(path: String, screen: String) {
        withContext(Dispatchers.IO) {
            try {
                val bitmap = BitmapFactory.decodeFile(path)
                setBitmapAsWallpaper(bitmap, screen)
            } catch (e: Exception) {
                throw Exception("Failed to load image: ${e.message}")
            }
        }
    }

    private fun setBitmapAsWallpaper(bitmap: Bitmap, screen: String) {
        val wallpaperManager = WallpaperManager.getInstance(applicationContext)
        
        when (screen) {
            "home" -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
            "lock" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                } else {
                    throw Exception("Lock screen wallpaper not supported on this device")
                }
            }
            "both" -> {
                wallpaperManager.setBitmap(bitmap)
            }
            else -> wallpaperManager.setBitmap(bitmap)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
}