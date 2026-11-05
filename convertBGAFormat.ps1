$DefaultFFmpegPath = "lib\ffmpeg\bin\ffmpeg.exe"
$DefaultWannaCriPath = "lib\wannacri\wannacri.exe"
$DefaultSourceDir = "mov"
$DefaultDestDir = "dat"
$KEY = "0x7F4551499DF55E68"

$BaseDir = $PSScriptRoot
$ConfigPath = Join-Path $BaseDir "config.ini"

$ConfigFFmpeg = ""
$ConfigWannaCri = ""
$ConfigSource = ""
$ConfigDest = ""

if (Test-Path $ConfigPath) {
    $lines = Get-Content $ConfigPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^\s*([^#=]+)\s*=\s*(.*)$') {
            $k = $matches[1].Trim()
            $v = $matches[2].Trim().Trim('"', "'")
            if ($k -eq "FFmpegPath" -and $v) { $ConfigFFmpeg = $v }
            if ($k -eq "WannaCRIPath" -and $v) { $ConfigWannaCri = $v }
            if ($k -eq "SourceDir" -and $v) { $ConfigSource = $v }
            if ($k -eq "DestDir" -and $v) { $ConfigDest = $v }
        }
    }
}

$FFmpegExe = if ($ConfigFFmpeg) { $ConfigFFmpeg } else { $DefaultFFmpegPath }
$WannaCriExe = if ($ConfigWannaCri) { $ConfigWannaCri } else { $DefaultWannaCriPath }
$SourceDirName = if ($ConfigSource) { $ConfigSource } else { $DefaultSourceDir }
$DestDirName = if ($ConfigDest) { $ConfigDest } else { $DefaultDestDir }

if (-not [System.IO.Path]::IsPathRooted($FFmpegExe)) {
    $FFmpegExe = Join-Path $BaseDir $FFmpegExe
}
if (-not (Test-Path $FFmpegExe)) {
    $FFmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($FFmpegCmd) { $FFmpegExe = $FFmpegCmd.Source }
}

if (-not [System.IO.Path]::IsPathRooted($WannaCriExe)) {
    $WannaCriExe = Join-Path $BaseDir $WannaCriExe
}
if (-not (Test-Path $WannaCriExe)) {
    $WannaCriCmd = Get-Command wannacri -ErrorAction SilentlyContinue
    if ($WannaCriCmd) { $WannaCriExe = $WannaCriCmd.Source }
}

if (-not (Test-Path $FFmpegExe) -or -not (Test-Path $WannaCriExe)) {
    Write-Host "请检查你的环境变量，或确认内置路径是否正确。" -ForegroundColor Red
    pause
    exit
}

$SourceDir = if ([System.IO.Path]::IsPathRooted($SourceDirName)) { $SourceDirName } else { Join-Path $BaseDir $SourceDirName }
$DestDir = if ([System.IO.Path]::IsPathRooted($DestDirName)) { $DestDirName } else { Join-Path $BaseDir $DestDirName }
$SourceDir = $SourceDir.TrimEnd('\')

if (-not (Test-Path -Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir | Out-Null
}

$FFmpegDir = Split-Path $FFmpegExe -Parent
$env:PATH = "$FFmpegDir;$env:PATH"

$Mp4Files = Get-ChildItem -Path $SourceDir -Filter "*.mp4" -Recurse -File

if ($Mp4Files.Count -eq 0) {
    Write-Host "未找到 MP4 文件。" -ForegroundColor Red
    pause; exit
}

Write-Host "找到 $($Mp4Files.Count) 个视频，开始处理..." -ForegroundColor Cyan

$count = 1
foreach ($file in $Mp4Files) {
    $path = $file.FullName
    $songName = $file.Directory.Name

    $FFMpegOutputPath = $path + ".ivf"
    $CRIOP = $path + ".usm"
    $FINALOP = Join-Path $DestDir ($songName + ".dat")

    if (Test-Path -Path $FINALOP) {
        Write-Host "`n[$count/$($Mp4Files.Count)] 跳过: $songName (dat已存在)" -ForegroundColor Yellow
        $count++
        continue
    }

    Write-Host "`n[$count/$($Mp4Files.Count)] 正在处理: $songName" -ForegroundColor Green

    Write-Host "FFmpeg 转换中..." -ForegroundColor DarkGray
    & $FFmpegExe -i "$path" -r 30 -an -c:v libvpx-vp9 -row-mt 1 "$FFMpegOutputPath" -y

    Write-Host "WannaCRI 封装中..." -ForegroundColor DarkGray

    Push-Location -Path $file.Directory.FullName
    try {
        & $WannaCriExe createusm --key $KEY "$FFMpegOutputPath"
    } finally {
        Pop-Location
    }

    if (Test-Path -Path $FFMpegOutputPath) { Remove-Item -Path $FFMpegOutputPath -Force }

    if (Test-Path -Path $CRIOP) {
        if (Test-Path -Path $FINALOP) { Remove-Item -Path $FINALOP -Force }
        Move-Item -Path $CRIOP -Destination $FINALOP -Force
        Write-Host "生成: $songName.dat" -ForegroundColor Cyan
    } else {
        Write-Host "错误:未找到生成的 .usm 文件" -ForegroundColor Red
    }

    $count++
}

Write-Host "`n完成,文件已输出到: $DestDir" -ForegroundColor Green