## FIGURE OUT HOW TO RUN THIS SCRIPT WITHOUT HAVING TO ELEVATE PERMISSIONS IN POWERSHELL
# this script builds the client-fancy release
# run this from the repo root: .\releases\builds-client-fancy.ps1

# client-fancy contains:
# base + client + visuals mods + visuals shaderpacks

# output : releases/BAW-BOP-client-fancy-VX.X.zip
# rename VX.X to the actual version before uploading to GitHub.

$ErrorActionPreference = "Stop"

# initialze paths relative to repo root
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outputDir = Join-Path $repoRoot "releases"
$tempDir = Join-Path $outputDir "_temp-client-fancy"
$zipName = "BAW-BOP-client-fancy-VX.X.zip"
$zipPath = Join-Path $outputDir $zipName

# clean up any previous builds
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# create temp folders for mods and shaderpacks
$modsDir = Join-Path $tempDir "mods"
$shaderDir = Join-Path $tempDir "shaderpacks"
New-Item -ItemType Directory -Path $modsDir -Force | Out-Null
New-Item -ItemType Directory -Path $shaderDir -Force | Out-Null

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

# copy from visuals/mods/
Write-Host "COPYING VISUALS MODS:"
$visualsCount = (Get-ChildItem (Join-Path $repoRoot "visuals\mods\*.jar")).Count
Copy-Item (Join-Path $repoRoot "visuals\mods\*.jar") $modsDir
Write-Host "  $visualsCount visuals mods"

# copy from visuals/shaderpacks/
Write-Host "COPYING SHADERPACKS:"
$shaderCount = (Get-ChildItem (Join-Path $repoRoot "visuals\shaderpacks\*.zip")).Count
Copy-Item (Join-Path $repoRoot "visuals\shaderpacks\*.zip") $shaderDir
Write-Host "  $shaderCount shaderpacks"

# count total number of mods
$totalMods = (Get-ChildItem (Join-Path $modsDir "*.jar")).Count
Write-Host ""
Write-Host "Total: $totalMods mods, $shaderCount shaderpacks"

# create zip file
Write-Host "ZIPPING MODS"
Compress-Archive -Path (Join-Path $tempDir "*") -DestinationPath $zipPath
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Created: $zipName ($zipSize MB)"
Write-Host "Make sure to rename VX.X to the version number before uploading."

# clean up temp foolder
Remove-Item $tempDir -Recurse -Force