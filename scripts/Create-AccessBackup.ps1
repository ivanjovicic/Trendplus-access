param(
    [string]$SourceMdbPath = (Join-Path $PSScriptRoot '..\Trend plus.mdb'),
    [string]$BackupRoot = (Join-Path $PSScriptRoot '..\backups\cutoff')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-AbsolutePath {
    param([string]$Path)

    return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
}

try {
    $repoRoot = Resolve-AbsolutePath (Join-Path $PSScriptRoot '..')
    $sourceResolved = Resolve-AbsolutePath $SourceMdbPath

    if ([System.IO.Path]::GetFileName($sourceResolved) -ne 'Trend plus.mdb') {
        throw "Refusing to back up anything except 'Trend plus.mdb'. Current source: $sourceResolved"
    }

    $sourceExpected = Join-Path $repoRoot 'Trend plus.mdb'
    $sourceExpectedResolved = [System.IO.Path]::GetFullPath($sourceExpected)
    if ($sourceResolved -ne $sourceExpectedResolved) {
        throw "Refusing to use a non-repo source path. Expected: $sourceExpectedResolved; actual: $sourceResolved"
    }

    if (-not (Test-Path -LiteralPath $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $backupFileName = "Trend plus_$timestamp_pre-cutoff-backup.mdb"
    $backupPath = Join-Path $BackupRoot $backupFileName
    $manifestPath = [System.IO.Path]::ChangeExtension($backupPath, '.manifest.txt')

    if (Test-Path -LiteralPath $backupPath) {
        throw "Backup target already exists: $backupPath"
    }

    Copy-Item -LiteralPath $sourceResolved -Destination $backupPath

    $sourceHash = Get-FileHash -LiteralPath $sourceResolved -Algorithm SHA256
    $backupHash = Get-FileHash -LiteralPath $backupPath -Algorithm SHA256
    $sourceInfo = Get-Item -LiteralPath $sourceResolved
    $backupInfo = Get-Item -LiteralPath $backupPath

    $manifest = @(
        "Access backup manifest"
        "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
        "Source path: $sourceResolved"
        "Source SHA256: $($sourceHash.Hash)"
        "Source size bytes: $($sourceInfo.Length)"
        "Backup path: $backupPath"
        "Backup SHA256: $($backupHash.Hash)"
        "Backup size bytes: $($backupInfo.Length)"
        "Backup folder: $BackupRoot"
        "Rule: do not modify the original MDB"
    ) -join [Environment]::NewLine

    Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8

    Write-Host "Backup created successfully."
    Write-Host "Source : $sourceResolved"
    Write-Host "Backup : $backupPath"
    Write-Host "Manifest: $manifestPath"
    Write-Host "SHA256  : $($backupHash.Hash)"
}
catch {
    Write-Error $_
    Write-Host ''
    Write-Host 'Manual fallback instructions:'
    Write-Host '1. Copy Trend plus.mdb to a timestamped backup folder outside the working MDB location.'
    Write-Host '2. Record SHA-256 for both the source and the backup.'
    Write-Host '3. Save a text manifest with the source path, backup path, hashes, sizes, and timestamp.'
    Write-Host '4. Do not open or modify the MDB while preparing the backup.'
    exit 1
}
