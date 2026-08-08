# Atualiza este repositorio com as configuracoes atuais do Claude Code.
# Rode antes de resetar o PC, para levar o estado mais recente.

$ErrorActionPreference = 'Stop'
$src  = "$env:USERPROFILE"
$repo = $PSScriptRoot

Write-Host "Coletando configuracoes atuais ..." -ForegroundColor Cyan
# Robocopy nao lanca excecao no PowerShell: com a origem faltando ele so devolve
# codigo >= 8 e o script seguiria em silencio, gravando um backup incompleto.
function Copiar-Pasta($origem, $destino) {
    if (-not (Test-Path $origem)) {
        Write-Host "  pulando $origem (nao existe nesta maquina)" -ForegroundColor Yellow
        return
    }
    robocopy $origem $destino /MIR /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy falhou ($LASTEXITCODE) em $origem" }
}

Copiar-Pasta "$src\.claude\rules"  "$repo\config\.claude\rules"
Copiar-Pasta "$src\.claude\skills" "$repo\config\.claude\skills"

Copy-Item "$src\.claude\settings.json"                   "$repo\config\.claude\"         -Force
Copy-Item "$src\.claude\plugins\installed_plugins.json"  "$repo\config\.claude\plugins\" -Force
Copy-Item "$src\.claude\plugins\known_marketplaces.json" "$repo\config\.claude\plugins\" -Force
Copy-Item "$src\.claude.json"                            "$repo\config\"                 -Force

# Rede de seguranca: se alguma credencial escapou para o stage, aborta antes do commit.
$suspeitos = Get-ChildItem "$repo\config" -Recurse -Force -File |
    Where-Object { $_.Name -match 'credential|\.env$|\.pem$|\.key$' -or $_.Extension -in '.db','.db-wal' }
if ($suspeitos) {
    Write-Host "ABORTADO - arquivo sensivel no stage:" -ForegroundColor Red
    $suspeitos | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor Red }
    exit 1
}

# O git tambem nao lanca excecao no PowerShell: sem checar o $LASTEXITCODE o
# script anunciava "Enviado para o GitHub" mesmo com o commit e o push falhando.
function Rodar-Git {
    param([string[]] $argumentos)
    git -C $repo @argumentos
    if ($LASTEXITCODE -ne 0) { throw "git $($argumentos -join ' ') falhou ($LASTEXITCODE)" }
}

Rodar-Git @('add', '-A')
if (git -C $repo status --porcelain) {
    Rodar-Git @('commit', '-m', 'chore: atualiza configuracoes do Claude Code')
    Rodar-Git @('push')
    Write-Host "`nEnviado para o GitHub." -ForegroundColor Green
} else {
    Write-Host "`nNada mudou desde o ultimo sync." -ForegroundColor Green
}
