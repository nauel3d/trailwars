param([switch]$Format, [string]$RojoPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    if (-not $RojoPath) {
        $RojoPath = if (Test-Path -LiteralPath '.tools/rojo/rojo.exe') { '.tools/rojo/rojo.exe' } else { 'rojo' }
    }
    foreach ($binary in @('.tools/luau/luau.exe','.tools/luau/luau-compile.exe','.tools/stylua/stylua.exe','.tools/selene/selene.exe')) {
        if (-not (Test-Path -LiteralPath $binary)) { throw "Missing $binary. Run scripts/bootstrap.ps1 first." }
    }
    if ($Format) { & '.tools/stylua/stylua.exe' src dev tests } else { & '.tools/stylua/stylua.exe' --check src dev tests }
    if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
    & '.tools/selene/selene.exe' src dev tests
    if ($LASTEXITCODE -ne 0) { throw 'Lint failed.' }
    $sources = @(Get-ChildItem -LiteralPath src,dev,tests -Recurse -Filter '*.luau' | Select-Object -ExpandProperty FullName)
    & '.tools/luau/luau-compile.exe' --null @sources
    if ($LASTEXITCODE -ne 0) { throw 'Luau compilation failed.' }
    python scripts/headless_tests.py
    if ($LASTEXITCODE -ne 0) { throw 'Headless adapter generation failed.' }
    & '.tools/luau/luau.exe' '.tools/foundation-tests.generated.luau'
    if ($LASTEXITCODE -ne 0) { throw 'Headless foundation tests failed.' }
    & '.tools/luau/luau.exe' 'tests/SnapLayoutTests.luau'
    if ($LASTEXITCODE -ne 0) { throw 'Snap responsive layout tests failed.' }
    & '.tools/luau/luau.exe' 'tests/MotionModelTests.luau'
    if ($LASTEXITCODE -ne 0) { throw 'Decorative motion/rank model tests failed.' }
    New-Item -ItemType Directory -Path dist -Force | Out-Null
    & $RojoPath build default.project.json -o dist/TrailWars.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Production Rojo build failed.' }
    & $RojoPath build preview.project.json -o dist/TrailWarsPreview.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Preview Rojo build failed.' }
    & $RojoPath build local-gameplay.project.json -o dist/TrailWarsLocalGameplay.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Local gameplay build failed.' }
    & $RojoPath build gameplay.project.json -o dist/TrailWarsMultiplayerGameplay.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Multiplayer gameplay build failed.' }
    & $RojoPath build gameplay-tests.project.json -o dist/TrailWarsAutomatedGameplayTests.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Gameplay test build failed.' }
    python scripts/check_artifacts.py
    if ($LASTEXITCODE -ne 0) { throw 'Artifact boundary validation failed.' }
    Write-Output "PASS: format, lint, $($sources.Count) Luau files compiled, foundation/gameplay tests, five builds and artifact boundaries."
    Write-Output 'Compile/lint success is not Roblox typechecking or engine/device validation.'
} finally { Pop-Location }
