@echo off
REM Copy ic_launcher.png to ic_launcher_foreground.png in all mipmap folders
copy "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" "android\app\src\main\res\mipmap-hdpi\ic_launcher_foreground.png"
copy "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" "android\app\src\main\res\mipmap-mdpi\ic_launcher_foreground.png"
copy "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" "android\app\src\main\res\mipmap-xhdpi\ic_launcher_foreground.png"
copy "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" "android\app\src\main\res\mipmap-xxhdpi\ic_launcher_foreground.png"
copy "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_foreground.png"
echo Foreground images created successfully!
pause
