# Maimai BGA Packer
PowerShell程序，可以把你的mp4或其他视频转换成maimai的BGA<br>
程序可以进行批量转换,默认从mov文件夹转换,生成在dat文件夹<br>
需要[ffmpeg](https://github.com/FFmpeg/FFmpeg)和[WannaCRI](https://github.com/donmai-me/WannaCRI)(如不指定则会默认从环境变量中读取)<br>
可在config.ini指定路径 ```FFmpegPath WannaCRIPath SourceDir DestDir```(可选)<br>
```text
MaimaiBGAPacker/
├─ mov/                    # 源目录：两种放法可混用
│  ├─ Horizon Dream.mp4    # 平铺    → dat/Horizon Dream.dat
│  ├─ Lapis.mp4            # 平铺    → dat/Lapis.dat
│  ├─ Odysseus/
│  │  └─ pv.mp4            # 子文件夹 → dat/Odysseus.dat
│  │  └─ bg.jpg 
│  │  └─ track.mp3 
│  │  └─ maidata.txt 
│  ├─ 私は雨/
│  │  └─ pv.mp4            # 子文件夹 → dat/私は雨.dat
│  │  └─ bg.jpg 
│  │  └─ track.mp3 
│  │  └─ maidata.txt 
├─ dat/                    # 输出目录（自动创建）
└─ convertBGAFormat.ps1  
```
### 注
转换时间通常较长
已知问题:如果你用普通BGA直接转换，Xaleid ScopiX的BGA显示和原版游戏不一样