---
name: cotafrete-tres-transportadoras
description: "Como cotar em cada uma das três transportadoras-alvo do cotafrete, e qual credencial cada uma exige"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-12T19:37:40.845Z
---

O projeto cotafrete (repo privado `enzozon/cotafrete`) mira três transportadoras.
Levantado por recon read-only em 12/08/2026:

- **Jadlog** — tem DOIS caminhos. A API REST `/embarcador/api/frete/valor` exige
  token de contrato, que Enzo **ainda não tem**. Mas o **simulador público**
  devolve preço real **sem credencial nenhuma**: use
  `https://www.jadlog.com.br/siteInstitucional/simulacao.jad` (a URL divulgada,
  `/jadlog/simulacao`, é wrapper e dá `ViewExpiredException` no POST). É
  JSF/PrimeFaces com ViewState — só dá para automatizar por browser, não por
  HTTP puro. Form `#form_precifica`, botão `input[value="Simular"]`. Devolve
  valor, **não devolve prazo**. Preço de tabela/balcão, não o contratado.
- **Della Volpe** — formulário público WordPress/CF7, sem credencial, mas
  assíncrono: o preço só volta por e-mail (~15 min). Por isso o ingestor IMAP
  está na lista de pendências.
- **Translovato** — exige login. Ver [[translovato-credenciais-pendentes]].

**Why:** a suposição inicial era que sem token não dava para cotar Jadlog; o
simulador derruba isso e destrava a transportadora imediatamente. E cada uma
tem um modo diferente (síncrono / assíncrono / autenticado), o que define a
arquitetura de adapter de cada uma.

**How to apply:** ao implementar o adapter do simulador Jadlog, reaproveitar
`carriers/jadlog/mapping.py`, que já está pronto e testado — muda só o
transporte. Nunca submeter o formulário real da Della Volpe sem
`DV_ENVIO_REAL_AUTORIZADO=sim` E pedido explícito do Enzo: cada submit vira
cotação na fila de um vendedor.
