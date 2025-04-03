@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM 设置控制台支持Unicode
reg add "HKCU\Console" /v "FaceName" /t REG_SZ /d "Consolas" /f > nul 2>&1
reg add "HKCU\Console" /v "CodePage" /t REG_DWORD /d 65001 /f > nul 2>&1

REM 自动匹配当前目录下所有视频文件
for %%V in (*.mp4,*.mkv,*.avi) do (
    set "video_file=%%V"
    set "base_name=%%~nV"
    set "extension=%%~xV"
    
    REM 生成MKV格式输出文件名
    set "output_file=!base_name!_sub.mkv"
    
    REM 查找同名srt字幕
    if exist "!base_name!.srt" (
        echo [发现匹配] 视频 "!video_file!" + 字幕 "!base_name!.srt"
        
        REM 执行MKV封装命令
        ffmpeg -v error -i "!video_file!" -i "!base_name!.srt" ^
          -map 0 -map 1 ^
          -c:v copy -c:a copy ^
          -c:s srt ^
          -metadata:s:s:0 language=chi ^
          -sub_charenc UTF-8 ^
          -y "!output_file!"
        
        if errorlevel 1 (
            echo [失败] 处理文件 "!video_file!" 时出错
        ) else (
            echo [成功] 输出文件: "!output_file!"
        )
        echo.
    ) else (
        echo [跳过] 未找到字幕 "!base_name!.srt"
        echo.
    )
)

echo 所有任务已完成
pause