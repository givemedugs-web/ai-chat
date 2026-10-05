@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Universal Modder - Game Library Scanner
cd /d "%~dp0"
echo ==========================================
echo   Game Library Scanner (single file)
echo   Detects Steam / Epic Games / itch.io installs,
echo   plus HTML browser-games in Documents/Desktop/Downloads.
echo   Output: game-library.json (same folder as this .bat)
echo ==========================================
set "PSFILE=%TEMP%\gf-scan-games.ps1"
if exist "%PSFILE%" del /q "%PSFILE%"
copy /y "%~f0" "%TEMP%\gf-src.txt" >nul
findstr /n /c:"@GAMEDATA@BEG""INDATA" "%TEMP%\gf-src.txt" > "%TEMP%\gf-marker.txt"
if not exist "%TEMP%\gf-marker.txt" ( echo ERROR: embedded scanner marker missing. & pause & exit /b 1 )
set MK=
for /f "usebackq tokens=1 delims=:" %%L in ("%TEMP%\gf-marker.txt") do if not defined MK set "MK=%%L"
if not defined MK ( echo ERROR: embedded scanner marker missing. & pause & exit /b 1 )
more +%MK% "%TEMP%\gf-src.txt" | findstr /c:"::@GAMEDATA@LINE" > "%PSFILE%.tmp"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$OutputEncoding=[Console]::OutputEncoding=[Text.Encoding]::UTF8; (Get-Content -LiteralPath '%PSFILE%.tmp' -Encoding UTF8) ^| ForEach-Object { $_ -replace '^::@GAMEDATA@LINE','' } ^| Set-Content -LiteralPath '%PSFILE%' -Encoding UTF8; Remove-Item -LiteralPath '%PSFILE%.tmp'"
del /q "%TEMP%\gf-src.txt" "%TEMP%\gf-marker.txt" 2>nul
for %%%%F in ("%PSFILE%") do if %%%%~zF equ 0 (
  echo ERROR: could not extract embedded scanner from this .bat.
  pause & exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$OutputEncoding=[Console]::OutputEncoding=[Text.Encoding]::UTF8; & '%PSFILE%'"
set "RC=%ERRORLEVEL%"
del /q "%PSFILE%" 2>nul
echo.
if "%RC%"=="0" (
  echo Done. game-library.json was written next to this .bat.
  echo Open game-fusion.html ^(or fused-game.html^), press
  echo "Import game-library.json", pick that file, and click
  echo -^> A / -^> B next to any game to load it instantly.
) else (
  echo Scanner exited with error code %RC% - see messages above.
)
pause
exit /b %RC%
:: @GAMEDATA@BEGINDATA Everything after this line is the embedded PowerShell scanner.
::@GAMEDATA@LINE# Universal Modder - Game Library Scanner (invoked by scan-games.bat)
::@GAMEDATA@LINE$ErrorActionPreference = 'SilentlyContinue'
::@GAMEDATA@LINE$games = @()
::@GAMEDATA@LINEfunction AddGame($name, $platform, $path) {
::@GAMEDATA@LINE    if ($name -and $path -and (Test-Path -LiteralPath $path)) {
::@GAMEDATA@LINE        $script:games += [pscustomobject]@{ name = [string]$name; platform = $platform; path = $path }
::@GAMEDATA@LINE    }
::@GAMEDATA@LINE}
::@GAMEDATA@LINE# ---- STEAM ----
::@GAMEDATA@LINE$steam = $null
::@GAMEDATA@LINEforeach ($r in @('HKCU:\Software\Valve\Steam','HKLM:\SOFTWARE\WOW6432Node\Valve\Steam','HKLM:\SOFTWARE\Valve\Steam')) {
::@GAMEDATA@LINE    $p = (Get-ItemProperty $r).'InstallPath'
::@GAMEDATA@LINE    if ($p) { $steam = $p; break }
::@GAMEDATA@LINE}
::@GAMEDATA@LINEif ($steam -and (Test-Path -LiteralPath $steam)) {
::@GAMEDATA@LINE    $sf = Join-Path $steam 'steamapps'
::@GAMEDATA@LINE    $libs = @($sf)
::@GAMEDATA@LINE    $lfp = Join-Path $sf 'libraryfolders.vdf'
::@GAMEDATA@LINE    if (Test-Path -LiteralPath $lfp) {
::@GAMEDATA@LINE        foreach ($ln in Get-Content -LiteralPath $lfp) {
::@GAMEDATA@LINE            if ($ln -match '"path"\s*"([^"]+)"') { $libs += ($matches[1] -replace '\\\\', '\') }
::@GAMEDATA@LINE        }
::@GAMEDATA@LINE    }
::@GAMEDATA@LINE    foreach ($lib in $libs) {
::@GAMEDATA@LINE        $a = Join-Path $lib 'steamapps'
::@GAMEDATA@LINE        if (-not (Test-Path -LiteralPath $a)) { continue }
::@GAMEDATA@LINE        foreach ($m in Get-ChildItem -LiteralPath $a -Filter 'appmanifest_*.acf') {
::@GAMEDATA@LINE            $txt = Get-Content -Raw -LiteralPath $m.FullName
::@GAMEDATA@LINE            $nm = $null; $sd = $null
::@GAMEDATA@LINE            if ($txt -match '"name"\s*"([^"]*)"') { $nm = $matches[1] }
::@GAMEDATA@LINE            if ($txt -match '"installdir"\s*"([^"]*)"') { $sd = $matches[1] }
::@GAMEDATA@LINE            if ($nm) {
::@GAMEDATA@LINE                $gp = Join-Path (Join-Path $a 'common') ($sd -replace '[\\/]', '\')
::@GAMEDATA@LINE                AddGame $nm 'Steam' $gp
::@GAMEDATA@LINE            }
::@GAMEDATA@LINE        }
::@GAMEDATA@LINE    }
::@GAMEDATA@LINE}
::@GAMEDATA@LINE# ---- EPIC GAMES ----
::@GAMEDATA@LINE$el = Join-Path $env:LOCALAPPDATA 'EpicGamesLauncher\Data\Manifests'
::@GAMEDATA@LINEif (Test-Path -LiteralPath $el) {
::@GAMEDATA@LINE    foreach ($f in Get-ChildItem -LiteralPath $el -Filter '*.item') {
::@GAMEDATA@LINE        try {
::@GAMEDATA@LINE            $j = Get-Content -Raw -LiteralPath $f.FullName | ConvertFrom-Json
::@GAMEDATA@LINE            if ($j.AppName) { AddGame $j.DisplayName 'Epic' $j.InstallLocation }
::@GAMEDATA@LINE        } catch {}
::@GAMEDATA@LINE    }
::@GAMEDATA@LINE}
::@GAMEDATA@LINE# ---- ITCH.IO ----
::@GAMEDATA@LINE$w = Join-Path $env:APPDATA 'itch\crumbs\downloads.json'
::@GAMEDATA@LINEif (Test-Path -LiteralPath $w) {
::@GAMEDATA@LINE    try {
::@GAMEDATA@LINE        $bt = Get-Content -Raw -LiteralPath $w | ConvertFrom-Json
::@GAMEDATA@LINE        foreach ($k in $bt.PSObject.Properties.Name) {
::@GAMEDATA@LINE            $v = $bt.$k
::@GAMEDATA@LINE            if ($v.target) { AddGame ([string]($v.title -join ' ')) 'itch.io' $v.target }
::@GAMEDATA@LINE        }
::@GAMEDATA@LINE    } catch {}
::@GAMEDATA@LINE}
::@GAMEDATA@LINE$it = Join-Path $env:LOCALAPPDATA 'itch\butler\apps'
::@GAMEDATA@LINEif (Test-Path -LiteralPath $it) {
::@GAMEDATA@LINE    foreach ($d in Get-ChildItem -LiteralPath $it -Directory) { AddGame $d.Name 'itch.io' $d.FullName }
::@GAMEDATA@LINE}
::@GAMEDATA@LINE# ---- HTML browser-games in Documents / Desktop / Downloads ----
::@GAMEDATA@LINE$roots = @(
::@GAMEDATA@LINE    (Join-Path $env:USERPROFILE 'Documents'),
::@GAMEDATA@LINE    (Join-Path $env:USERPROFILE 'Desktop'),
::@GAMEDATA@LINE    (Join-Path $env:USERPROFILE 'Downloads')
::@GAMEDATA@LINE)
::@GAMEDATA@LINEforeach ($root in $roots) {
::@GAMEDATA@LINE    if (-not (Test-Path -LiteralPath $root)) { continue }
::@GAMEDATA@LINE    foreach ($h in Get-ChildItem -LiteralPath $root -Recurse -Include *.html,*.htm -File -Depth 5) {
::@GAMEDATA@LINE        if ($h.Length -gt 5MB) { continue }
::@GAMEDATA@LINE        AddGame $h.Name 'HTML' $h.FullName
::@GAMEDATA@LINE    }
::@GAMEDATA@LINE}
::@GAMEDATA@LINE# ---- write game-library.json next to this script ----
::@GAMEDATA@LINE$out = Join-Path $PSScriptRoot 'game-library.json'
::@GAMEDATA@LINEif ($games.Count -eq 0) { Set-Content -LiteralPath $out -Value '[]' -Encoding UTF8 }
::@GAMEDATA@LINEelse { $games | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $out -Encoding UTF8 }
::@GAMEDATA@LINEWrite-Host ('Found ' + $games.Count + ' game(s). Wrote ' + $out)
::@GAMEDATA@LINEexit 0
::@GAMEDATA@LINE
