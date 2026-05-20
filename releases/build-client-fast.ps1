## FIGURE OUT HOW TO RUN THIS SCRIPT WITHOUT HAVING TO ELEVATE PERMISSIONS IN POWERSHELL
# this script builds the client-fast release
# run this from the repo root: .\releases\builds-client-fast.ps1

# client-fast contains:
# base + client

# output : releases/BAW-BOP-client-fast-VX.X.zip
# rename VX.X to the actual version before uploading to GitHub.

$ErrorActionPreference = "Stop"

# initialze paths relative to repo root
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outputDir = Join-Path $repoRoot "releases"
$tempDir = Join-Path $outputDir "_temp-client-fast"
$zipName = "BAW-BOP-client-fast-VX.X.zip"
$zipPath = Join-Path $outputDir $zipName

# clean up any previous builds
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# create temp folder for mods
$modsDir = Join-Path $tempDir "mods"
New-Item -ItemType Directory -Path $modsDir -Force | Out-Null

# copy from base/
Write-Host "COPYING BASE MODS:"
$baseCount = (Get-ChildItem (Join-Path $repoRoot "base\mods\*.jar")).Count
Copy-Item (Join-Path $repoRoot "base\mods\*.jar") $modsDir
Write-Host "  $baseCount base mods"

# copy from client/mods/
Write-Host "COPYING CLIENT MODS:"
$clientCount = (Get-ChildItem (Join-Path $repoRoot "client\mods\*.jar")).Count
Copy-Item (Join-Path $repoRoot "client\mods\*.jar") $modsDir
Write-Host "  $clientCount client mods"

# count total number of mods
$totalCount = (Get-ChildItem (Join-Path $modsDir "*.jar")).Count
Write-Host ""
Write-Host "Total: $totalCount mods"

# create zip file
Write-Host "ZIPPING MODS"
Compress-Archive -Path (Join-Path $tempDir "*") -DestinationPath $zipPath
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Created: $zipName ($zipSize MB)"
Write-Host "Make sure to rename VX.X to the version number before uploading."

# clean up temp foolder
Remove-Item $tempDir -Recurse -Force
