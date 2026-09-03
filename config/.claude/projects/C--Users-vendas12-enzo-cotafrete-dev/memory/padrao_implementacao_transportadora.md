---
name: padrao-implementacao-transportadora
description: "Roteiro passo a passo usado para implementar cada transportadora automatica no Cotafrete (Camilo, Jadlog, Translovato, Generoso, Della Volpe)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1d9abed6-996f-4e68-a807-ee3af84ac63a
  modified: 2026-09-01T20:46:25.820Z
---

Toda transportadora nova adicionada ao Cotafrete seguiu, sem excecao, este roteiro. Confirmado repetidas vezes ao longo do desenvolvimento (Camilo/SSW, Jadlog, Translovato, Generoso, Della Volpe) sem o Enzo pedir um caminho diferente — e o pedido explicito de 01/09/2026 foi justamente "salve na memoria como foi feito todas as outros [...] para implementarmos amanha o outro sem problemas".

**Why:** duas licoes caras, repetidas no codigo varias vezes: (1) seletor DOM deduzido de PRINT em vez do HTML real quebra silenciosamente — ja aconteceu na Della Volpe e no popup de aviso do SSW/Camilo, e o comentario "medido no DOM, nao deduzido de print" aparece em varios arquivos como cicatriz; (2) confiar em preco/campo preenchido sem checar o popup de aviso do site gerou cotacoes fantasmas (preco calculado atras de uma recusa de negocio real, ex.: cidade nao atendida, CNPJ nao cadastrado).

**How to apply**, na ordem:

1. **Recon primeiro, sempre.** Um script solto em `recon/recon_<slug>.py` (ou `recon_<slug>_<coisa>.py`) que abre o site de verdade (as vezes logado, credenciais do `.env`) e extrai o DOM real: `name=` dos campos, estrutura dos popups de aviso, comportamento de selects em cascata (estado->cidade), mensagens de recusa. NUNCA deduzir seletor de uma imagem/print.
2. **`carriers/<slug>/mapping.py`** — camada PURA (zero Playwright, zero rede). Define `SLUG`, `NOME`, `MODO`, `campos_obrigatorios(req)`, `validar(req)`, `preparar_payload(req)` (dict chaveado por ROTULO, nao por name= de HTML), formatadores proprios do site (cada site tem sua propria regra de casas decimais/separador — nunca presumir que dois sites formatam igual) e `normalizar_resposta(raw)`.
3. **`carriers/<slug>/adapter.py`** — camada de BROWSER (Playwright). Localiza campo por label/placeholder quando da, cai para `name=` real medido no recon como ultimo recurso (nunca XPath posicional). Implementa `cotar(req, confirmar_envio=False)`: dry-run por padrao (preenche, tira print, PARA antes do envio final); `confirmar_envio=True` exige trava explicita no `.env` e so entao clica no botao final.
4. **Fixtures de teste geradas do recon**, nao digitadas a mao — `tests/fixtures/<slug>_*.html`, HTML real capturado (ou reproduzido fielmente) do site, carregado via `file://` nos testes Playwright. E o que garante que o teste falha se o site mudar de verdade, em vez de testar uma suposicao.
5. **Provar com dry-run ANTES de qualquer coisa real.** Rodar o adapter contra o site de verdade em modo dry-run, olhar o screenshot (`teste_real/<slug>/<timestamp>/preenchido.png`), confirmar que cada campo esperado apareceu certo — inclusive campos "opcionais" que mudam o resultado (caso real: CNPJ remet/destin da Camilo mudavam o valor do frete).
6. **So depois, envio real** — e so com dado que o site reconhece (CNPJ de cliente cadastrado de verdade, nao um CNPJ de teste sintetico: um CNPJ de teste ja disparou recusa por "nao cadastrado" que nao aconteceria com cliente real).
7. **Wiring em `web/app.py`**: entrar em `AUTOMATICAS`, ganhar uma fabrica em `FABRICAS` (`_cotar_<slug>(req)`), entrar em `NOMES` e `NOTAS`. Testes de consistencia (padrao `tests/test_dellavolpe_automatica.py`) travam que toda `AUTOMATICAS` tem fabrica e vice-versa.
8. **`monitorar.py` NAO precisa mais de sincronizacao manual** desde a reforma de 01/09/2026: as colunas da tabela agora vem de `slugs_do_periodo()`, derivado do que aparece em `resultado` — uma transportadora nova aparece sozinha assim que gerar o primeiro resultado.
9. **Credenciais em AMBOS os `.env`** (dev e producao) — sao arquivos separados, nao versionados, e ja aconteceu de faltar um dos dois.
10. **Deploy**: skill `commit-pt`, commit + push (branch `dellavolpe-assistida` foi o branch de trabalho usado repetidamente sem criar um novo por PR — abrir PR contra `main` e mesclar com `gh pr merge`), checar `resultado.status in ('validando','enviando','solicitacao_enviada')` no banco de PRODUCAO antes de reiniciar, `git pull` em `cotafrete-producao`, matar o processo da porta 8000 e subir `Servidor.bat` de novo, confirmar `HTTP 200`.

Ver tambem [[braspress-proxima-transportadora]].
