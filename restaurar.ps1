# Restaura as configuracoes do Claude Code a partir deste repositorio.
# Pre-requisito: Claude Code ja instalado (irm https://claude.ai/install.ps1 | iex)
# Use o RESTAURAR.bat para nao esbarrar na ExecutionPolicy do Windows novo.

$ErrorActionPreference = 'Stop'
$origem  = "$PSScriptRoot\config"
$destino = "$env:USERPROFILE"

if (-not (Test-Path "$origem\.claude.json")) {
    throw "Nao achei $origem\.claude.json - voce clonou o repositorio inteiro?"
}

# Nao sobrescreve as-cegas: guarda o que ja existe antes de copiar por cima.
if (Test-Path "$destino\.claude") {
    $antiga = "$destino\.claude.antes-da-restauracao-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Ja existe um .claude - movendo para $antiga" -ForegroundColor Yellow
    Move-Item "$destino\.claude" $antiga
}

Write-Host "Restaurando rules, skills e settings ..." -ForegroundColor Cyan
robocopy "$origem\.claude" "$destino\.claude" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null

Write-Host "Restaurando .claude.json ..." -ForegroundColor Cyan
Copy-Item "$origem\.claude.json" $destino -Force

Write-Host ""
Write-Host "Pronto. Agora abra o Claude Code e:" -ForegroundColor Green
Write-Host "  1. rode /login           (o token nao vem no repo, por seguranca)"
Write-Host "  2. rode /plugin          e reinstale os plugins da lista abaixo"
Write-Host ""

# Mostra o que precisa ser reinstalado - o codigo dos plugins nao vem no repo,
# eles se rebaixam sozinhos do marketplace.
$p = Get-Content "$origem\.claude\plugins\installed_plugins.json" -Raw | ConvertFrom-Json
Write-Host "Plugins que estavam instalados:" -ForegroundColor Cyan
$p.PSObject.Properties | ForEach-Object {
    $_.Value.PSObject.Properties | ForEach-Object { Write-Host "  - $($_.Name)" }
}
