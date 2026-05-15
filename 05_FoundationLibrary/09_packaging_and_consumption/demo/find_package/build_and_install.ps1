# Build + install QmlAdvCore to a local prefix, then build the find_package
# consumer demo pointing at that prefix.
#
# Usage:
#   .\build_and_install.ps1 [-QtCMake <path>]
$ErrorActionPreference = "Stop"

param(
    [string]$QtCMake = "$env:USERPROFILE\Qt\6.11.1\msvc2022_64\bin\qt-cmake.bat"
)

$Here          = Split-Path -Parent $MyInvocation.MyCommand.Path
$SectionRoot   = Resolve-Path (Join-Path $Here "..\..")
$LibRoot       = Join-Path $SectionRoot "QmlAdvCore"
$InstallPrefix = Join-Path $SectionRoot "_install"
$LibBuild      = Join-Path $SectionRoot "build\_lib"
$ConsumerBuild = Join-Path $Here "build"

Write-Host "==> Qt:       $QtCMake"
Write-Host "==> Library:  $LibRoot"
Write-Host "==> Prefix:   $InstallPrefix"
Write-Host ""

# 1. Configure + build the library
& $QtCMake -S $LibRoot -B $LibBuild `
    -DCMAKE_BUILD_TYPE=Release `
    "-DCMAKE_INSTALL_PREFIX=$InstallPrefix"
cmake --build $LibBuild --parallel --config Release

# 2. Install to the local prefix
cmake --install $LibBuild --config Release

# 3. Configure + build the consumer pointing at that prefix
& $QtCMake -S $Here -B $ConsumerBuild `
    -DCMAKE_BUILD_TYPE=Release `
    "-DCMAKE_PREFIX_PATH=$InstallPrefix"
cmake --build $ConsumerBuild --parallel --config Release

Write-Host ""
Write-Host "==> Done. Run:"
Write-Host "    $ConsumerBuild\Release\QmlAdvCoreFindPkgDemo.exe"
