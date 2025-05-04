$sourcePath = "$PSScriptRoot\..\build\windows\x64\runner\Release"
$destinationPath = "D:/src/ADBTools"

Write-Host "开始构建 Windows 项目..."
flutter build windows

# 检查目标目录是否存在，如果不存在则创建
Write-Host "正在检查目标目录是否存在..."
if (-not (Test-Path -Path $destinationPath)) {
    Write-Host "目标目录不存在，正在创建..."
    New-Item -ItemType Directory -Path $destinationPath
}

# 删除目标目录内容
Write-Host "正在删除目标目录内容..."
Remove-Item -Path $destinationPath\* -Recurse -Force

# 复制文件和文件夹
Write-Host "正在复制文件和文件夹..."
Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse -Force
Write-Host "文件复制完成。"