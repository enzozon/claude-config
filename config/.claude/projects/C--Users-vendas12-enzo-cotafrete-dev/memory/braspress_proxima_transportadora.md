---
name: braspress-proxima-transportadora
description: "Braspress foi implementada como transportadora automatica no Cotafrete em 02/09/2026 (branch dellavolpe-assistida, PR #14) — commitada e com PR aberto, producao ainda NAO atualizada"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1d9abed6-996f-4e68-a807-ee3af84ac63a
  modified: 2026-09-02T17:48:25.858Z
---

Braspress foi implementada como transportadora AUTOMATICA no Cotafrete em 02/09/2026, seguindo [[padrao-implementacao-transportadora]] do início ao fim: recon (`recon/recon_braspress.py`) → `carriers/braspress/mapping.py` (puro) → `carriers/braspress/adapter.py` (Playwright, dry-run por padrão) → fixtures reais (`tests/fixtures/braspress_*.html`) → testes (`tests/test_braspress_mapping.py`, `tests/test_braspress_dom.py`, 21 testes) → wiring em `web/app.py` (AUTOMATICAS/FABRICAS/NOMES/NOTAS) e `monitorar.py`.

**Achados que valem lembrar:**
- A "Área do Cliente" em www.braspress.com é só casca; quem faz login e cota é um iframe de outro domínio, `blue.braspress.com/site/w/cliente/view` → `.../site/w/cotacao/view`. O adapter vai direto nesse domínio.
- O CNPJ da Ventura (08.310.365/0001-24, que também é o usuário de login) fica SEMPRE travado num dos lados da carga pelo próprio site (CIF trava remetente, FOB trava destinatário) — por isso o cartão do vendedor tem um aviso fixo nisso (NOTAS["braspress"] em web/app.py), pedido explícito do Enzo.
- Formulário de UMA TELA SÓ (sem etapas). Máscaras medidas: peso/valor tratam dígitos digitados como centavos; comprimento/largura/altura mostram METROS mas aceitam o valor em CENTÍMETROS direto (100cm=1m, coincidência útil).
- Um envio real (confirmar_envio=True, "Calcular") provou o parser do resultado: cotação #373377732, R$ 1.295,87, 3 dias úteis. A RECUSA nunca foi vista de verdade — `ler_recusa` é um chute educado (convenção Bootstrap `.alert-danger`), marcado como tal no código.

**Why:** o Enzo pediu para seguir o mesmo roteiro das cinco anteriores e testar sem enviar antes de continuar — feito em duas etapas (dry-run aprovado, depois um "Calcular" real rodado pelo próprio Enzo via `!comando` porque o classificador do modo automático bloqueou o clique).

**How to apply:** commit `ad02a67` na branch `dellavolpe-assistida`, PR #14 aberto contra `main`, **NÃO mesclado e produção NÃO tocada** — o Enzo pediu explicitamente para parar em "commit + PR" desta vez, diferente do padrão de deploy imediato das anteriores. Antes de mesclar/deployar: confirmar com o Enzo, e considerar que a primeira recusa real em produção pode exigir ajustar `ler_recusa`.

Ver também [[padrao-implementacao-transportadora]].
