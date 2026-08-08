# claude-config

Configurações do Claude Code, para restaurar depois de formatar o PC.

**Repositório privado.** Contém identificadores da conta (`userID`, `machineID`,
e-mail em `oauthAccount`) dentro do `.claude.json`. Nenhuma credencial.

## Restaurar num PC novo

```powershell
# 1. instalar o Claude Code
irm https://claude.ai/install.ps1 | iex

# 2. clonar este repo
gh repo clone enzozon/claude-config
```

**3. Duplo-clique em `RESTAURAR.bat`.**

Use o `.bat`, não o `.ps1` direto: num Windows recém-instalado a
`ExecutionPolicy` vem `Restricted` e bloqueia o script com
*"não pode ser carregado porque a execução de scripts foi desabilitada"*.
O `.bat` contorna isso só naquele processo, sem alterar a segurança da máquina.

**4. Abra o Claude Code:** rode `/login`. Os plugins voltam sozinhos — o script
corrige os caminhos e o Claude Code rebaixa o cache do marketplace. Confira com
`claude plugin list`: os 8 devem aparecer como `enabled`. Só use `/plugin` se
algum ficar como `failed to load` (o script imprime a lista do que era).

## O que tem aqui

| Caminho | O quê |
|---|---|
| `config/.claude/rules/` | Suas regras globais (ecc: common, react, typescript, web) |
| `config/.claude/skills/` | Skills próprias — hoje vazio: não havia `~/.claude/skills`. As skills em uso vêm dos plugins |
| `config/.claude/settings.json` | Hooks, permissões, statusline |
| `config/.claude/plugins/*.json` | Lista de plugins e marketplaces para reinstalar |
| `config/.claude.json` | Config principal |

## O que NÃO tem, e por quê

| Fora | Motivo |
|---|---|
| `.credentials.json` | Token OAuth vivo da conta. `/login` recria em 10s |
| `.claude-mem/*.db` | O banco de memória guardava uma chave de API do Google em texto puro, capturada de uma conversa antiga |
| `plugins/cache/` | ~200 MB de código de plugin que se rebaixa sozinho do marketplace |
| `projects/` | Histórico de conversas; dois arquivos passavam de 100 MB, que o GitHub rejeita |

## Atualizar antes de formatar

```powershell
powershell -ExecutionPolicy Bypass -File sincronizar.ps1
```

Ele recolhe as configs atuais, **aborta se detectar qualquer credencial no
stage**, commita e envia.
