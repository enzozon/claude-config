---
name: servidor-datasheet-chrome-109
description: O servidor do datasheetget só tem Chrome 109 — sites React modernos (Ingram) não montam a página lá; a saída é chamar a API JSON de dentro do browser
metadata: 
  node_type: memory
  type: project
  originSessionId: 730bae61-d66d-4f2a-979a-e0abc3b1d64b
  modified: 2026-09-02T19:27:11.274Z
---

O servidor (Windows Server 2012 R2, `\\SERVIDOR2`, saída pelo IP 187.64.131.203, output em
`\\SERVIDOR2\Publico\Datasheet\`) tem **apenas Chrome 109** instalado — é o último suportado
nesse SO. Confirmado em 2026-08-31 pelo próprio utilizador.

**Why:** com o Chrome 109 a app React da Ingram (`br.ingrammicro.com/cep/app/...`) recebe o
esqueleto HTML (19 KB) e os cookies do Akamai, mas o `<div id="root">` fica vazio para sempre
(só o spinner azul). Localmente, com Chrome 151, a mesma página monta em ~10 s. Não é bloqueio
por user-agent (testado com UA de Chrome 109 aqui: carrega). Em 2026-09-02 o Ingram foi
resolvido a **chamar a API JSON da própria página com `fetch()` via `execute_async_script`**,
com os cabeçalhos `IM-SiteCode/IM-Environment/IM-CorrelationID/IM-ApiKey` que a página manda
(vistos no log de performance). A leitura pelo HTML montado ficou como reserva (`extrair_do_html`).

**How to apply:** qualquer scraper novo ou corrigido usa `version_main=109`. Quando um site
React "não carrega" no servidor mas carrega aqui, não perder tempo com timeouts: gravar HTML +
PNG (padrão `guardar_pagina`), e procurar o endereço JSON que a página usa (performance log
`goog:loggingPrefs`) para o chamar de dentro do browser. `intelbras.py:164` continua em
`version_main=144` — ainda não pedido. Chrome 109 é de janeiro de 2023, o que por si só faz o
Akamai desconfiar: ver [[casasbahia-akamai-bloqueio]]. Regras de edição: [[regras-scrapers-datasheet]].
