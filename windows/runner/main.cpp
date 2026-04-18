#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <iostream>

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    PWSTR pCmdLine, int nCmdShow) {
  // Attach console on debug builds
  #ifdef _DEBUG
  AllocConsole();
  FILE* fp;
  freopen_s(&fp, "CONOUT$", "w", stdout);
  #endif

  // Create and run the Flutter window
  flutter::DartProject project(GetEnvironmentVariablePtr("FLUTTER_PROJECT") ?
                                std::wstring(GetEnvironmentVariablePtr("FLUTTER_PROJECT")) :
                                std::wstring(L"."));
  flutter::FlutterViewController controller(hInstance, project);
  if (!controller.engine()) {
    return EXIT_FAILURE;
  }
  
  return controller.Run();
}