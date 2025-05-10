$sourcePath = "$PSScriptRoot\..\build\windows\x64\runner\Release"
$destinationPath = "D:/src/ADBTools"

$shouldBuild = $false
$shouldCopy = $false

# 定义函数用于输出帮助信息
function Show-HelpInfo {
    Write-Host "Usage: cli.ps1 [options]"
    Write-Host "Options:"
    Write-Host "  --build-windows    Build the Windows project using Flutter."
    Write-Host "  --copy             Copy the built files to the destination directory."
    Write-Host "  --help, -h         Show this help message and exit."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  cli.ps1 --build-windows"
    Write-Host "  cli.ps1 --copy"
    Write-Host "  cli.ps1 --build-windows --copy"
    Write-Host "  cli.ps1 -h"
    Write-Host ""
}

# 处理参数
if ($args.Length -eq 0) {
    Write-Host "Please select an option:"
    Write-Host "1. Build the Windows project"
    Write-Host "2. Copy the built files"
    Write-Host "3. Build and copy"
    Write-Host "4. Show help"
    $choice = Read-Host "Enter your choice (1-4)"
    switch ($choice) {
        "1" { $shouldBuild = $true }
        "2" { $shouldCopy = $true }
        "3" { 
            $shouldBuild = $true 
            $shouldCopy = $true 
        }
        "4" {
            Show-HelpInfo
            return
        }
        default {
            Write-Host "Invalid choice. Exiting." -ForegroundColor Red
            return
        }
    }
} else {
    foreach ($arg in $args) {
        switch ($arg) {
            "--build-windows" { $shouldBuild = $true }
            "--copy" { $shouldCopy = $true }
            "--help"{
                Show-HelpInfo
                return
            }
            "-h" {
                Show-HelpInfo
                return
            }
            default {
                Write-Host "Unknown parameter: $arg" -ForegroundColor Red
                return
            }
        }
    }
}

# 执行 flutter build windows
if ($shouldBuild) {
    Write-Host "=== Starting to build the Windows project... ==="
    flutter build windows
}

# 执行复制操作
if ($shouldCopy) {
    # 检查目标目录是否存在，如果不存在则创建
    Write-Host "=== Checking if the destination directory exists... ==="
    if (-not (Test-Path -Path $destinationPath)) {
        Write-Host "=== The destination directory does not exist. Creating it now... ==="
        New-Item -ItemType Directory -Path $destinationPath
    }

    # 删除目标目录内容
    Write-Host "=== Deleting the contents of the destination directory... ==="
    Remove-Item -Path $destinationPath\* -Recurse -Force

    # 复制文件和文件夹
    Write-Host "=== Copying files and folders... ==="
    Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse -Force
    Write-Host "=== File copying completed. ==="
}