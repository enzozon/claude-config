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

# Os JSONs de plugin gravam caminhos absolutos com o nome de usuario da maquina
# antiga (ex.: C:\Users\Enzo). Se o PC novo tem outro usuario, o Claude Code
# procura os marketplaces num caminho inexistente e todo plugin quebra com
# "failed to load: cache-miss". Reescreve o prefixo para o perfil atual.
Write-Host "Ajustando caminhos dos plugins para o usuario atual ..." -ForegroundColor Cyan
$perfilJson = $destino -replace '\\', '\\'          # C:\Users\x -> C:\\Users\\x (formato JSON)
$padrao     = '[A-Za-z]:\\\\Users\\\\[^\\"]+\\\\\.claude'
$semBom     = New-Object System.Text.UTF8Encoding($false)  # Set-Content -Encoding utf8 poe BOM e quebra o parser

foreach ($nome in 'known_marketplaces.json', 'installed_plugins.json') {
    $arquivo = "$destino\.claude\plugins\$nome"
    if (-not (Test-Path $arquivo)) { continue }

    $texto = [System.IO.File]::ReadAllText($arquivo)
    $novo  = $texto -replace $padrao, "$perfilJson\\.claude"
    if ($novo -ne $texto) {
        [System.IO.File]::WriteAllText($arquivo, $novo, $semBom)
        Write-Host "  $nome reescrito para $destino" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Pronto. Agora abra o Claude Code e:" -ForegroundColor Green
Write-Host "  1. rode /login              (o token nao vem no repo, por seguranca)"
Write-Host "  2. rode 'claude plugin list' e confira se os 8 aparecem como enabled."
Write-Host "     Se algum der 'cache-miss', use /plugin para reinstalar da lista abaixo."
Write-Host ""

# O codigo dos plugins nao vem no repo: com os caminhos corrigidos acima, o
# Claude Code rebaixa o cache sozinho do marketplace no primeiro uso.
$p = Get-Content "$origem\.claude\plugins\installed_plugins.json" -Raw | ConvertFrom-Json
Write-Host "Plugins que estavam instalados:" -ForegroundColor Cyan
$p.PSObject.Properties | ForEach-Object {
    $_.Value.PSObject.Properties | ForEach-Object { Write-Host "  - $($_.Name)" }
}
