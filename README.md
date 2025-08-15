# Maimai BGA Packer
A powershell program that convert your mp4 or other videos into maimai's BGA.
[ffmpeg](https://github.com/FFmpeg/FFmpeg) and [WannaCRI](https://github.com/donmai-me/WannaCRI) required and the environment varibles needed to be configured.
[Pre-compiled ffmpeg for windows is here.](https://ffmpeg.org/download.html#build-windows)

    Usage:
    convertBGAFormat.ps1 -path [path] -id [musicId]
And then a \[id\].dat file will be created, you can add it into your game and enjoy it.
## Known issue(s):
- The BGA of Xaleid ScopiX does not shows the same as the original game if you directly convert with a normal BGA.