---
name: casasbahia-akamai-bloqueio
description: "Casas Bahia — o Akamai reprova o Chrome lançado pelo chromedriver; resolvido em 2026-09-03 a ligar o scraper a um Chrome aberto à mão (porta 9222), com o lançamento antigo como reserva"
metadata: 
  node_type: memory
  type: project
  originSessionId: 730bae61-d66d-4f2a-979a-e0abc3b1d64b
  modified: 2026-09-03T16:57:10.555Z
---

Em 2026-08-31 corrigimos 5 bugs reais do `scrapers/casasbahia.py` e chegou a funcionar localmente
(51 specs). Em 2026-09-03 **já bloqueia também na máquina local** (customdeny em 1 s na página
de produto; a homepage carrega). O Chrome normal do utilizador, no MESMO IP (187.64.131.203,
partilhado com o servidor), abre a página inteira. Logo **não é IP: o sensor do Akamai reprova
o Chrome lançado pelo undetected_chromedriver** — o cookie `_abck` fica com `~-1~`.

**Why:** esgotado e sem efeito: aquecimento pela homepage (8 s e 20 s), Referer via
`window.location.href`, link sem utm, entrada vindo de uma pesquisa Google, `--lang=pt-BR`,
perfil persistente aquecido numa corrida anterior (`user_data_dir`), `--disable-http2`
(revertido). Suspeita: deteção do CDP (Runtime.enable) que o uc 3.5.5 não esconde.

**Solução (2026-09-03):** ligar-se a um Chrome aberto à mão com `--remote-debugging-port=9222`
(Selenium normal `webdriver.Chrome` + `options.debugger_address`, chromedriver do `Patcher` do uc).
Aprovado nos dois links de teste (27 e 50 specs) enquanto o Chrome lançado pelo chromedriver
continuava negado no mesmo minuto. O scraper abre uma aba própria, fecha-a no fim e faz `quit()`
sem derrubar o Chrome da pessoa. Sem Chrome na porta cai em `lancar_chrome()` (caminho antigo).
No servidor: `chrome.exe --remote-debugging-port=9222 --user-data-dir="C:\chrome_robo"`.

**How to apply:** não repetir essas variantes. O scraper agora imprime
`[Casas Bahia] Sensor do Akamai: ...` (lê o `_abck`) e grava `casasbahia_falha_<ts>.html/.png`
via `guardar_pagina`. Saídas reais que restam, ambas a decidir com o utilizador: ligar a um
Chrome aberto à mão (`options.debugger_address`) ou uma fonte de dados alternativa. Ver
[[servidor-datasheet-chrome-109]] e [[regras-scrapers-datasheet]].
