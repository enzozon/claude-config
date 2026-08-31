# claude-config

Sincroniza configurações e memória do Claude Code entre computadores.

**Repositório privado.** Contém identificadores da conta (`userID`, `machineID`, e-mail em `oauthAccount`) dentro do `.claude.json`. Nenhuma credencial.

---

## ⚡ Quick Start

### Sincronizar (PC Atual)

**Duplo-clique em `SINCRONIZAR.bat`**

- ✅ Copia configurações atuais
- ✅ Sincroniza memória dos projetos (`.md` files)
- ✅ Comita e envia para GitHub
- ✅ Mostra status ao terminar

### Restaurar (PC Novo)

**1. Instalar Claude Code:**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**2. Clonar este repositório:**
```powershell
gh auth login
gh repo clone enzozon/claude-config
cd claude-config
```

**3. Configurar Git (necessário uma única vez):**
```powershell
git config --global user.name "Enzo Faroni Zon"
git config --global user.email "enzozon7b@gmail.com"
```

**4. Duplo-clique em `RESTAURAR.bat`**

- ✅ Restaura todas as configurações
- ✅ Carrega a memória dos projetos
- ✅ Ajusta caminhos automaticamente

**5. Abra Claude Code e faça login:**
```
/login                 (cria novo token)
claude plugin list     (verifica plugins)
```

---

## 📋 O que está sincronizado

| Item | O quê | Formato |
|------|-------|---------|
| **Configurações** | Settings, hooks, permissões | `settings.json` |
| **Plugins** | Lista de plugins instalados | `installed_plugins.json` |
| **Regras** | ECC common, react, typescript, web | `.md` files |
| **Memória** | Contexto dos projetos (cotafrete, etc) | `.md` files |

---

## ❌ O que NÃO está sincronizado

| Excluído | Por quê |
|----------|---------|
| `.credentials.json` | Token OAuth — `/login` recria em 10s |
| Histórico de conversas (`.jsonl`) | Muito grande (100+ MB) |
| Plugin cache (`plugins/cache/`) | ~200 MB — rebaixa automaticamente do marketplace |
| Histórico de projeto (`projects/**/*.jsonl`) | Histórico de conversas passadas |

---

## 🔄 Fluxo de Uso

### Scenario 1: Trabalhar no PC Atual → Levar para PC Novo

```
PC Atual:
1. Trabalha, edita memória dos projetos
2. Duplo-clique em SINCRONIZAR.bat
   ↓
GitHub (repositório atualizado)
   ↓
PC Novo:
3. Duplo-clique em RESTAURAR.bat
4. /login no Claude Code
✅ Pronto com tudo sincronizado!
```

### Scenario 2: Apenas Atualizar Memória

```
Edita: ~/.claude/projects/cotafrete/memory/*.md
Roda: SINCRONIZAR.bat
✅ Memória atualizada no GitHub
```

---

## 📝 Detalhes Técnicos

### SINCRONIZAR.bat

Copia e comita:
- `~/.claude/rules/` → `config/.claude/rules/`
- `~/.claude/skills/` → `config/.claude/skills/`
- `~/.claude/projects/*/memory/` → `config/.claude/projects/*/memory/`
- `~/.claude/settings.json` → `config/.claude/`
- Plugins JSON

**Segurança:** Aborta se detectar credenciais (`.env`, `.pem`, `.key`, `.db`)

### RESTAURAR.bat

Restaura `config/` → `~/.claude/`

**Inteligente:**
- Faz backup de config antiga antes de sobrescrever
- Ajusta caminhos de plugins para o novo usuário
- Não reexporta credenciais ou histórico grande

---

## 🛠 Troubleshooting

**"Arquivo não encontrado"**
- Verifique que clonou o repositório inteiro: `gh repo clone enzozon/claude-config`

**"ExecutionPolicy" error**
- Use `SINCRONIZAR.bat` ou `RESTAURAR.bat` (contornam automaticamente)
- Não execute `.ps1` direto

**Plugins aparecem "cache-miss"**
- Normal no primeiro uso — Claude Code rebaixa do marketplace
- Se persiste: `claude plugin list` e verifique paths

**Git não commita**
- Configure user.name e user.email como mostrado acima

---

## 📚 Mais informações

- Claude Code: https://claude.ai/
- Este repositório: https://github.com/enzozon/claude-config
- Memória do projeto: `config/.claude/projects/*/memory/MEMORY.md`
