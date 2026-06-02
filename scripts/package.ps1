param(
    [string]$Version
)

Set-StrictMode -Version Latest

if (-not $Version) {
    $pkg = Get-Content -Raw "package.json" | ConvertFrom-Json
    $Version = $pkg.version
}

$appVersion = $Version
$ver = "v$Version"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Split-Path -Parent $scriptDir
Set-Location $root

$dist = Join-Path $root "dist"
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Path $dist | Out-Null

Write-Host "Preparing files into $dist"

# Copy binaries and scripts using PowerShell file copy to avoid external process file-handle issues
$binDist = Join-Path $dist "bin"
$hooksDist = Join-Path $dist "hooks"
$mediaDist = Join-Path $dist "media"
$installerDist = Join-Path $dist "installer"

New-Item -ItemType Directory -Path $binDist -Force | Out-Null
New-Item -ItemType Directory -Path $hooksDist -Force | Out-Null
New-Item -ItemType Directory -Path $mediaDist -Force | Out-Null
New-Item -ItemType Directory -Path $installerDist -Force | Out-Null

Copy-Item -Path ".\bin\ClaudeVoiceNotifier.exe" -Destination $binDist -Force
Copy-Item -Path ".\bin\claude-voice-notifier.cmd" -Destination $binDist -Force
Copy-Item -Path ".\hooks\*" -Destination $hooksDist -Recurse -Force
Copy-Item -Path ".\media\*" -Destination $mediaDist -Recurse -Force

Copy-Item -Path config.ini -Destination $dist -Force
Copy-Item -Path README.md -Destination $dist -Force
Copy-Item -Path LICENSE.md -Destination $dist -Force
Copy-Item -Path app-icon.ico -Destination $dist -Force

# Create a dedicated installer source folder so the installer does not bundle build artifacts.
$installerBinDist = Join-Path $installerDist "bin"
$installerHooksDist = Join-Path $installerDist "hooks"
$installerMediaDist = Join-Path $installerDist "media"
New-Item -ItemType Directory -Path $installerBinDist -Force | Out-Null
New-Item -ItemType Directory -Path $installerHooksDist -Force | Out-Null
New-Item -ItemType Directory -Path $installerMediaDist -Force | Out-Null
Copy-Item -Path "$binDist\*" -Destination $installerBinDist -Recurse -Force
Copy-Item -Path "$hooksDist\*" -Destination $installerHooksDist -Recurse -Force
Copy-Item -Path "$mediaDist\*" -Destination $installerMediaDist -Recurse -Force
Copy-Item -Path "$dist\config.ini" -Destination $installerDist -Force
Copy-Item -Path "$dist\README.md" -Destination $installerDist -Force
Copy-Item -Path "$dist\LICENSE.md" -Destination $installerDist -Force
Copy-Item -Path "$dist\app-icon.ico" -Destination $installerDist -Force
# Copy postinstall helper and ensure it's included in installer source
Copy-Item -Path "scripts\postinstall.ps1" -Destination $installerDist -Force
Copy-Item -Path "scripts\postinstall.ps1" -Destination $dist -Force

$zipName = "claude-voice-notifier-windows-x64-$ver.zip"
$zipPath = Join-Path $root $zipName

Write-Host "Creating ZIP: $zipPath"
Start-Sleep -Seconds 1
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($dist, $zipPath)

Move-Item -Path $zipPath -Destination $dist -Force

# Build installer if Inno Setup Compiler is available
$iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$installerPath = $null
if (Test-Path $iscc) {
    Write-Host "Inno Setup found, building installer..."
    # Pass an absolute SourcePath to ISCC so the compiler can locate files regardless of its working directory
    $installerDistAbs = (Get-Item $installerDist).FullName
    $sourceArg = "/DSourcePath=$installerDistAbs"
    $isccArgs = @("scripts\\installer.iss", "/O$dist", "/DMyAppVersion=$ver", "/DAppVersion=$appVersion", $sourceArg)
    & $iscc @isccArgs
    Write-Host "Installer build finished (look in $dist)"
    $installerPath = Join-Path $dist "claude-voice-notifier-windows-x64-$ver.exe"
} else {
    Write-Host "Inno Setup compiler not found at $iscc. Skipping installer build."
    Write-Host "To build installer locally, install Inno Setup and re-run this script."
}

Write-Host "Generating SHA256"
$shaFile = Join-Path $dist "sha256-$ver.txt"
if (Test-Path $shaFile) { Remove-Item $shaFile -Force }
$hashLines = @()
$zipDistPath = Join-Path $dist $zipName
$hashLines += "$(Get-FileHash $zipDistPath -Algorithm SHA256 | Select-Object -ExpandProperty Hash)  $zipName"
if ($installerPath -and (Test-Path $installerPath)) {
    $hashLines += "$(Get-FileHash $installerPath -Algorithm SHA256 | Select-Object -ExpandProperty Hash)  $(Split-Path $installerPath -Leaf)"
}
Set-Content -Path $shaFile -Value $hashLines -Encoding ASCII

# Verify icon configuration and generated artifacts.
$verifyOk = $true
$issueText = Get-Content "scripts\installer.iss"
if ($issueText -match 'SetupIconFile=.*app-icon\.ico') {
    Write-Host "[OK] Setup installer icon configured to app-icon.ico"
} else {
    Write-Warning "[WARN] SetupIconFile is not configured to app-icon.ico"
    $verifyOk = $false
}
if ($issueText -match 'UninstallDisplayIcon=.*app-icon\.ico') {
    Write-Host "[OK] Uninstall display icon configured to app-icon.ico"
} else {
    Write-Warning "[WARN] UninstallDisplayIcon is not configured to app-icon.ico"
    $verifyOk = $false
}
if ($issueText -match 'IconFilename: ".*app-icon\.ico"') {
    Write-Host "[OK] Start menu shortcut icon configured to app-icon.ico"
} else {
    Write-Warning "[WARN] Shortcut IconFilename is not configured to app-icon.ico"
    $verifyOk = $false
}
if (Test-Path (Join-Path $installerDist "app-icon.ico")) {
    Write-Host "[OK] Installer source contains app-icon.ico"
} else {
    Write-Warning "[WARN] app-icon.ico is missing from installer source folder"
    $verifyOk = $false
}
if ($installerPath -and (Test-Path $installerPath)) {
    Write-Host "[OK] Installer executable generated: $installerPath"
} else {
    Write-Warning "[WARN] Installer executable was not generated"
    $verifyOk = $false
}

if ($verifyOk) {
    Write-Host "All icon configuration checks passed."
} else {
    Write-Warning "One or more icon configuration checks failed. Inspect scripts\installer.iss and rerun the packaging script."
}

Write-Host "Done. Dist artifacts are in: $dist"
