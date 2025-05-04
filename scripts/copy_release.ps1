$sourcePath = "$PSScriptRoot\..\build\windows\x64\runner\Release"
$destinationPath = "D:/src/ADBTools"

flutter build windows

# 检查目标目录是否存在，如果不存在则创建
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# 删除目标目录内容
Remove-Item -Path $destinationPath\* -Recurse -Force

# 复制文件和文件夹
Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse -Force