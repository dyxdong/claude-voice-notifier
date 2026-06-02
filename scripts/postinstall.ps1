param(
    [string]$AppPath
)

# Per-user config directory
$userProfile = $env:USERPROFILE
$userConfigDir = Join-Path $userProfile '.claude-voice-notifier'

function Ensure-Dir($d) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    return (Test-Path $d)
}

# Create user config dir
if (-not (Ensure-Dir $userConfigDir)) {
    Write-Error "Failed to create $userConfigDir"
    exit 1
}

# Copy or merge config.ini
$sourceConfig = Join-Path $AppPath 'config.ini'
$destConfig = Join-Path $userConfigDir 'config.ini'
if (Test-Path $sourceConfig) {
    if (-not (Test-Path $destConfig)) {
        Copy-Item -Path $sourceConfig -Destination $destConfig -Force
    } else {
        # Merge: add keys from source that are missing in dest
        $src = @{}
        $dst = @{}
        $section = ''
        foreach ($line in Get-Content $sourceConfig) {
            if ($line -match '^\s*\[([^\]]+)\]\s*$') { $section = $matches[1]; continue }
            if ($line -match '^\s*([^=]+)=([^#;]*)') {
                $k = $matches[1].Trim(); $v = $matches[2].Trim()
                $key = "$section`:$k"
                $src[$key] = $v
            }
        }
        $section = ''
        foreach ($line in Get-Content $destConfig) {
            if ($line -match '^\s*\[([^\]]+)\]\s*$') { $section = $matches[1]; continue }
            if ($line -match '^\s*([^=]+)=') {
                $k = $matches[1].Trim(); $key = "$section`:$k"; $dst[$key] = $true
            }
        }
        $outLines = [System.Collections.ArrayList](Get-Content $destConfig)
        foreach ($entry in $src.GetEnumerator()) {
            if (-not $dst.ContainsKey($entry.Key)) {
                $parts = $entry.Key.Split(':',2)
                $sectionName = $parts[0]; $keyName = $parts[1]
                $pattern = "^\s*\[$([regex]::Escape($sectionName))\]\s*$"
                $headerMatch = $outLines | Select-String -Pattern $pattern | Select-Object -First 1
                if ($headerMatch) {
                    $insertPos = $headerMatch.LineNumber
                    for ($i = $insertPos; $i -lt $outLines.Count; $i++) {
                        if ($outLines[$i] -match '^\s*\[.+\]\s*$') { break }
                        $insertPos = $i + 1
                    }
                } else {
                    $outLines.Add('') | Out-Null
                    $outLines.Add("[$sectionName]") | Out-Null
                    $insertPos = $outLines.Count
                }
                $outLines.Insert($insertPos, "$keyName=$($entry.Value)") | Out-Null
            }
        }
        $outLines | Set-Content -Path $destConfig -Encoding UTF8
    }
}

# Copy media directory if user doesn't have it
$sourceMedia = Join-Path $AppPath 'media'
$destMedia = Join-Path $userConfigDir 'media'
if ((Test-Path $sourceMedia) -and (-not (Test-Path $destMedia))) {
    Copy-Item -Path $sourceMedia -Destination $destMedia -Recurse -Force
}

# Set folder icon via desktop.ini and attributes
$iconFile = Join-Path $AppPath 'app-icon.ico'
$desktopIni = Join-Path $userConfigDir 'desktop.ini'
@"
[.ShellClassInfo]
IconResource=$iconFile,0
ConfirmFileOp=0
NoSharing=1
"@ | Set-Content -Path $desktopIni -Encoding UTF8

# Set attributes
cmd /c "attrib +s `"$userConfigDir`""
cmd /c "attrib +h +s `"$desktopIni`""

Write-Host "Post-install user setup completed for $userConfigDir"
exit 0
