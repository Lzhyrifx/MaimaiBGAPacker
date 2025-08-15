param([string]$path, [string]$id)

$KEY = "0x7F4551499DF55E68"

$FFMpegOutputPath = $path + ".ivf"
$CRIOP = $path + ".usm"
$FINALOP = [System.IO.Path]::GetDirectoryName($path)
$FINALOP = [System.IO.Path]::Combine($FINALOP, $id + ".dat")

ffmpeg -i "$path" -r 30 -c:v  libvpx-vp9 "$FFMpegOutputPath" -y
wannacri createusm --key $KEY $FFMpegOutputPath
Remove-Item -Path $FFMpegOutputPath

if ([System.IO.File]::Exists($FINALOP)) {
    Remove-Item -Path $FINALOP
}
Rename-Item -Path "$CRIOP" -NewName $FINALOP