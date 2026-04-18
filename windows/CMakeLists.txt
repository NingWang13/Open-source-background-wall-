cmake_minimum_required(VERSION 3.15)
project(wallpaper_app LANGUAGES CXX)

set(BINARY_NAME "wallpaper_app")
set(APPLICATION_ID "com.wallhaven.wallpaper_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Flutter configuration
set(FLUTTER_ROOT "$ENV{FLUTTER_ROOT}")
if(NOT FLUTTER_ROOT)
    message(FATAL_ERROR "FLUTTER_ROOT not set")
endif()

set(FLUTTER_ENGINE_LIBRARY "${FLUTTER_ROOT}/bin/cache/artifacts/engine/indows-release/flutter_engine.dll")
set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/cache/artifacts/engine/indows-release/flutter_windows.dll")

# Application libraries
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(flutter)

# Main executable
set(BUNDLE_DIR_NAME "${CMAKE_CFG_INTDIR}")

add_executable(${BINARY_NAME} WIN32
    "runner/main.cpp"
    "runner/win32_window.cpp"
    "runner/flutter_window.cpp"
    "runner/utils.cpp"
    "runner/win32_window_configuration.cpp"
)

apply_standard_settings(${BINARY_NAME})

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

target_include_directories(${BINARY_NAME} PRIVATE "${FLUTTER_ROOT}/cpp")

set_source_files_properties(
    "runner/*.cpp"
    "runner/*.h"
    PROPERTIES
    COMPILE_DEFINITIONS "FLUTTER_ENGINE_LIBRARY=${FLUTTER_ENGINE_LIBRARY}"
)

# Copy Flutter engine and assets
set(FLUTTER_ASSETS_DIR "${FLUTTER_ROOT}/bin/cache/artifacts/engine/indows-release/")
set(FLUTTER_SHELL_PROJECT_NAME "wallpaper_app")

build_bundle(TARGET ${BINARY_NAME})

# Install
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
install(DIRECTORY "${FLUTTER_ASSETS_DIR}" DESTINATION "${CMAKE_INSTALL_PREFIX}")
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")