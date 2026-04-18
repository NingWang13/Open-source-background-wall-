#include <flutter/flutter_view_controller.h>
#include <iostream>
#include <windows.h>

// Wallpaper setting implementation for Windows
#include <windows.h>
#include <string>

// Global reference for wallpaper channel
flutter::FlutterViewController* g_controller = nullptr;

bool SetDesktopWallpaper(const std::wstring& filePath, int location) {
    // location: 0 = both, 1 = home, 2 = lock (Windows doesn't differentiate)
    BOOL result = SystemParametersInfo(
        SPI_SETDESKWALLPAPER,
        0,
        (PVOID)filePath.c_str(),
        SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
    );
    return result != FALSE;
}

extern "C" {

// Called from Dart
__declspec(dllexport) int SetWallpaper(const wchar_t* filePath, int location) {
    if (filePath == nullptr) {
        return -1;
    }
    
    std::wstring path(filePath);
    BOOL result = SystemParametersInfo(
        SPI_SETDESKWALLPAPER,
        0,
        (PVOID)path.c_str(),
        SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
    );
    
    return result ? 0 : -1;
}

} // extern "C"

// Entry point
int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    PWSTR pCmdLine, int nCmdShow) {
    // Attach console for debugging
    #ifdef _DEBUG
    AllocConsole();
    FILE* fp;
    freopen_s(&fp, "CONOUT$", "w", stdout);
    #endif

    // Initialize Flutter
    flutter::DartProject project(L".");
    g_controller = new flutter::FlutterViewController(hInstance, project);
    
    if (!g_controller->engine()) {
        return EXIT_FAILURE;
    }
    
    return g_controller->Run();
}