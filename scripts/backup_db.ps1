param(
    [string]$DatabaseUrl = $env:DATABASE_URL,
    [string]$BackupDirectory = $env:BACKUP_DIR
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DatabaseUrl)) {
    throw 'DATABASE_URL doit contenir l''URL PostgreSQL. Ne la committez jamais.'
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($BackupDirectory)) {
    $BackupDirectory = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'elite-placo-backups'
}
$backupPath = [IO.Path]::GetFullPath($BackupDirectory)
$repoPrefix = $repoRoot.TrimEnd('\') + '\'
if ($backupPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "BACKUP_DIR doit être hors du dépôt : $repoRoot"
}

New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$output = Join-Path $backupPath "elite-placo-$stamp.dump"

if (-not (Get-Command pg_dump -ErrorAction SilentlyContinue)) {
    throw 'pg_dump est introuvable. Installez le client PostgreSQL avant de lancer la sauvegarde.'
}

& pg_dump $DatabaseUrl --format=custom --no-owner --no-privileges --file=$output
if ($LASTEXITCODE -ne 0) { throw "pg_dump a échoué avec le code $LASTEXITCODE" }
Write-Host "Sauvegarde créée hors du dépôt : $output"
