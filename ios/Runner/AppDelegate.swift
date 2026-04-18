import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let wallpaperChannel = FlutterMethodChannel(
            name: "com.wallhaven.wallpaper_app/wallpaper",
            binaryMessenger: controller.binaryMessenger
        )
        
        wallpaperChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "setWallpaper":
                if let args = call.arguments as? [String: Any],
                   let filePath = args["filePath"] as? String {
                    self?.setWallpaper(filePath: filePath, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
                }
            case "getWallpaper":
                // iOS cannot programmatically set wallpaper to Home/Lock screen
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setWallpaper(filePath: String, result: @escaping FlutterResult) {
        guard let image = UIImage(contentsOfFile: filePath) else {
            result(FlutterError(code: "FILE_ERROR", message: "Could not load image", details: nil))
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // Store result callback
        wallPaperResult = result
    }
    
    private var wallPaperResult: FlutterResult?
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            wallPaperResult?(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
        } else {
            wallPaperResult?("Wallpaper saved to Photos. Go to Settings > Wallpaper to set it.")
        }
        wallPaperResult = nil
    }
}