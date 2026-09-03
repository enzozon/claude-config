---
name: sessao-03-09-caca-bugs
description: "Sessão de 03/09/2026: varredura de erros em produção e correção de 7 bugs reais nas transportadoras automáticas (Generoso, Translovato, Jadlog) + causa raiz de interrompidos fantasma"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9f14f864-7582-4981-b1ce-7968ec6c770a
  modified: 2026-09-03T20:38:42.681Z
---

Em 03/09/2026 rodamos uma sessão inteira de caça a bugs: puxar os erros mais frequentes do banco de produção (`cotafrete-producao/cotafrete.db`), investigar cada um contra os prints reais em `teste_real/<transportadora>/...`, corrigir a causa raiz no código, testar, e só então commit + push + deploy em produção. Metodologia repetida 7 vezes ao longo do dia.

**Bugs corrigidos e já em produção (main, 7 commits, do `49ac058` até `7800bae`):**

1. Generoso: "carga ultrapassou os limites" virava erro genérico → agora recusa com os limites reais.
2. Translovato: alerta "CNPJ não cadastrado" no CNPJ do *destinatário* travava no overlay (timeout 45s) → agora fecha o alerta e segue com o CEP do formulário.
3. **Causa raiz**: `marcar_interrompidas` (core/banco.py) carimbava "interrompido" em cotações de ANTES de uma transportadora nova existir, toda vez que ela entrava em `AUTOMATICAS`. Corrigido com `AUTOMATICA_DESDE` (web/app.py) — dict slug→data de nascimento.
4. Generoso: "etapa do destino não avançou" era na verdade "Ainda não atendemos essa origem" (praça fora da malha), aviso que `_erros_da_tela` não pegava.
5. Jadlog: cotava frete FOB mesmo eles só fazendo CIF (não coletam no fornecedor/cliente) → recusa antes de abrir navegador/chamar API.
6. **Bug meu**: o fix #4 usava `m.AVISO_CEP_NAO_ATENDIDO` mas o adapter da Generoso não importa como `m` → `NameError` quebrando 100% das cotações da Generoso por ~20min até eu perceber e corrigir.
7. Generoso: duas cotações concorrentes (mesmo usuário logado) se pisavam no "Alterar empresa" — que é estado DA CONTA, não da aba. Cotação #130 saiu com o CNPJ errado por rodar junto com a #131. Corrigido com `_TRAVA_CONTA` (threading.Lock) serializando `cotar()`.
8. Bug cross-transportadora: pasta de evidência (`teste_real/.../<timestamp>/`) usava `strftime("%Y%m%d-%H%M%S")`, só até o segundo — duas cotações da mesma transportadora no mesmo segundo colidiam e uma sobrescrevia o print da outra. Corrigido nas 6 transportadoras com print (`%f` de microssegundo).
9. Generoso: reconhecido também o aviso "CEP de destino não pode ser o mesmo de coleta" (origem/destino caindo na mesma empresa do grupo Ventura, mesmo endereço cadastrado) — mensagem diferente do #4, mesma classe de sintoma.

**Banco de produção corrigido retroativamente** (registros antigos com `status='erro'` reclassificados para `'recusado'` com o motivo certo, só onde havia certeza pelo print): 13 + 4 registros da Generoso. Backup feito antes de cada correção em massa (`cotafrete.db.bak-<timestamp>`).

**Decidido deixar como está** (não vale a pena reconstruir): 4 erros antigos do Camilo e 3 da Generoso (CNPJ sem endereço) de antes dos respectivos fixes existirem — o texto real da recusa foi perdido porque o código antigo descartava o aviso sem guardar. [[padrao_implementacao_transportadora]]

**Why:** o Enzo queria limpar o acúmulo de "erro" genérico no painel, que escondia recusas de verdade das transportadoras atrás de mensagens técnicas — cada correção seguiu o padrão: reproduzir contra print real → fix no `mapping.py`/`adapter.py` → teste que reproduz o print real → suíte completa (692-714 testes, sempre 0 falhas reais) → commit → push → pull em produção → checar cotação em andamento → restart → verificar HTTP 200.

**How to apply:** próxima sessão pode rodar a mesma varredura (status por transportadora, agrupar `erro` por mensagem, abrir os prints mais frequentes) para achar a próxima rodada. Restam como baixa prioridade: Della Volpe (não é mais automática) e login-Generoso-senha-vazia (já documentado como autorresolutivo).
