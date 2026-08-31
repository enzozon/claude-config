---
name: translovato-regras-do-portal
description: "Regras de negócio e armadilhas do portal Translovato medidas no recon de 18/08/2026 — produto, fator de cubagem, unidades e rota de envio"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-18T19:01:02.233Z
---

Recon e dry-run da Translovato concluídos em **18/08/2026**. Credenciais já
estão no `.env` (`TRANSLOVATO_CNPJ`, `TRANSLOVATO_USUARIO`, `TRANSLOVATO_SENHA`)
e funcionam — substitui [[translovato-credenciais-pendentes]].

**Regras de negócio que o Enzo confirmou:**
- Remetente é **sempre a Ventura**, destinatário é o cliente final.
- Login é sempre o mesmo, mas o **CNPJ do remetente varia entre 3**:
  `08.310.365/0001-24`, `05.954.058/0001-98` (ALIANCA COM DE PROD E) e
  `20.837.281/0001-49`.
- Produto é **sempre `SUPR.INFORMATICA`**, qualquer que seja a mercadoria real.

**Armadilhas medidas (todas silenciosas — erram o preço sem dar erro):**
- O **fator de cubagem vem do PRODUTO**, não é constante. Sem produto
  selecionado o fator é 1 e o peso cubado sai **270× menor** (0,03 em vez de
  8,10 para 0,027 m³). Fator do SUPR.INFORMATICA = 300 kg/m³.
- É o **CNPJ do remetente** que dispara `/portal-do-cliente/get-products` e
  popula a lista de produtos. Sem ele o dropdown fica vazio para sempre.
- Medidas são em **METROS com vírgula** (`0,3` = 30 cm), não centímetros.
- CEP vai **sem máscara** (8 dígitos); CNPJ vai **com máscara** (18 caracteres).
- "QUANTIDADE DE PARES" é campo de outro produto e some ao escolher
  SUPR.INFORMATICA.

**Rotas:** envio real é `POST /portal-do-cliente/simular-cotacao` (action do
`#quotationForm`) — é a única que cria cotação, e o recon a bloqueia sempre.
Consultas inofensivas: `get-cnpj`, `get-products`, `get-cities`,
`validate-cep-attend`. O botão "Simular cotação" tem reCAPTCHA **invisível**;
o login **não** tem captcha. Com sessão válida dá para ir direto a
`/portal-do-cliente/solicitacao-de-cotacao`.

**Why:** cada um desses detalhes, errado, produz cotação com preço errado sem
nenhuma mensagem na tela — o modo de falha mais caro deste projeto.

**How to apply:** ao escrever `carriers/translovato/mapping.py`, converter cm→m
dividindo por 100 e formatando com vírgula, e travar o produto em
SUPR.INFORMATICA. Conferir sempre cubagem e peso cubado lidos de volta da tela
antes de aceitar um resultado. Ver [[cotafrete-armadilhas-medidas]] e
[[cotafrete-tres-transportadoras]].
