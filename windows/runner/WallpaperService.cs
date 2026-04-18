using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Windows.Storage;
using Windows.System.UserProfile;

namespace wallhaven
{
    public class WallpaperService
    {
        private static readonly HttpClient _httpClient = new HttpClient();

        public static async Task SetWallpaperFromUrlAsync(string url)
        {
            try
            {
                // Download image
                var response = await _httpClient.GetAsync(url);
                response.EnsureSuccessStatusCode();
                var imageData = await response.Content.ReadAsByteArrayAsync();

                // Save to temp file
                var tempFile = await ApplicationData.Current.TemporaryFolder.CreateFileAsync(
                    $"wallpaper_{Guid.NewGuid()}.jpg",
                    CreationCollisionOption.ReplaceExisting
                );
                await FileIO.WriteBytesAsync(tempFile, imageData);

                // Set as wallpaper
                await SetWallpaperAsync(tempFile.Path);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to set wallpaper: {ex.Message}");
            }
        }

        public static async Task SetWallpaperFromFileAsync(string filePath)
        {
            await SetWallpaperAsync(filePath);
        }

        private static async Task SetWallpaperAsync(string filePath)
        {
            if (!UserProfilePersonalizationSettings.IsSupported())
            {
                throw new Exception("Setting wallpaper is not supported on this device");
            }

            var file = await StorageFile.GetFileFromPathAsync(filePath);
            var settings = UserProfilePersonalizationSettings.Current;
            
            // Set both lock screen and desktop wallpaper
            await settings.SetLockScreenImageAsync(file);
            await settings.SetWallpaperImageAsync(file);
        }
    }
}