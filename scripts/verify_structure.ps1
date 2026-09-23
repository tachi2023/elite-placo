param(
    [switch] $SkipBuilds
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$requiredPaths = @(
    'apps/api/pom.xml',
    'apps/api/src/main',
    'apps/mobile/pubspec.yaml',
    'apps/mobile/lib',
    'apps/web/package.json',
    'apps/web/src',
    'packages/api-contracts/README.md',
    'render.yaml',
    'docker-compose.yml'
)

foreach ($relativePath in $requiredPaths) {
    $absolutePath = Join-Path $root $relativePath
    if (-not (Test-Path $absolutePath)) {
        throw "Structure manquante : $relativePath"
    }
}

$forbiddenSecrets = Get-ChildItem $root -Recurse -File -Force |
    Where-Object {
        -not $_.FullName.Contains('\.git\') -and
        $_.Name -match '^(login.*\.json|update_pwd\.sql|run-local.*\.log)$'
    }

if ($forbiddenSecrets) {
    $paths = $forbiddenSecrets.FullName -join ', '
    throw "Fichiers sensibles ou runtime detectes : $paths"
}

Write-Host 'Structure monorepo valide.'

if (-not $SkipBuilds) {
    Push-Location (Join-Path $root 'apps/api')
    mvn.cmd -B -Plocal test
    Pop-Location

    Push-Location (Join-Path $root 'apps/web')
    npm.cmd run build
    Pop-Location
}
