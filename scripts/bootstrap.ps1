param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolRoot = Join-Path $projectRoot '.tools'
$lock = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'tools.lock.json') -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
foreach ($tool in $lock.PSObject.Properties) {
    $destination = Join-Path $toolRoot $tool.Name
    $archive = Join-Path $toolRoot ($tool.Name + '-' + $tool.Value.version + '.zip')
    if (-not (Test-Path -LiteralPath $archive)) {
        # The official API route avoids intermittent github.com release-edge 504s.
        Invoke-WebRequest -Uri $tool.Value.apiUrl -Headers @{ Accept = 'application/octet-stream' } -OutFile $archive
    }
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $tool.Value.sha256) { throw "Checksum mismatch for $($tool.Name). Remove the archive and investigate before retrying." }
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Expand-Archive -LiteralPath $archive -DestinationPath $destination -Force
    Write-Output "$($tool.Name) $($tool.Value.version): verified official release archive"
}
Write-Output 'Tools are project-local. No global PATH or application settings were changed.'
