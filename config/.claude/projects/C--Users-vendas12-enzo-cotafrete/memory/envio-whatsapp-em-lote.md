---
name: envio-whatsapp-em-lote
description: "Decisao do Enzo (19/08/2026) — mandar a cotacao para as 14 transportadoras de WhatsApp com envio guiado e contador honesto de 'abertas', nao disparo automatico"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-19T16:13:13.190Z
---

Enzo decidiu em **19/08/2026**, para implementar depois ("depois que eu testar
decido... mas acho que a melhor opcao seria salvar mesmo como voce falou 1 de
14 abertas"): botao **"Enviar para todos"** guiado na tela de resultado.

Como funciona: caixinhas para escolher quais transportadoras; um botao abre a
primeira conversa; ao voltar para a aba, a pagina ja avancou e destaca a
proxima, mostrando **"3 de 14 abertas"**; progresso salvo por cotacao, para
poder parar no meio e continuar.

**O rotulo e "abertas", nunca "enviadas"** — a pagina sabe que a conversa foi
aberta, nao que o vendedor apertou enviar. Enzo aprovou justamente essa versao
honesta.

Caminhos descartados, com o motivo:
- **Lista de transmissao** (ideia inicial dele): o destinatario so recebe se
  tiver o nosso numero salvo na agenda dele. As transportadoras nao tem, e
  **nao da erro** — a mensagem simplesmente nao chega.
- **Grupo**: as transportadoras se veem cotando o mesmo frete.
- **Abrir 14 abas de uma vez**: o navegador bloqueia a partir da segunda, e
  nao economiza envio nenhum.
- **API oficial (Meta Cloud API)**: unico jeito de disparar sozinho, mas as
  respostas caem no numero da API e nao no celular do vendedor — precisaria de
  uma tela de caixa de entrada, senao manda 14 e ninguem le as respostas.
  Tambem exige numero dedicado e modelo aprovado pela Meta. Nao descartado
  para sempre; adiado.
- **Bibliotecas nao-oficiais** (Baileys, whatsapp-web.js): risco de banimento
  permanente do numero comercial da Ventura. Nao usar.

**Why:** 14 mensagens identicas em dois minutos, mesmo enviadas a mao, podem
parecer spam para o WhatsApp — espacar e mais seguro. E qualquer solucao que
prometa "enviado" sem poder confirmar cria uma cotacao que o vendedor acha que
saiu e nao saiu.

**How to apply:** mexe na tela de `/cotacao/{id}` em `web/app.py`, no bloco que
monta os links `wa.me` a partir de `web/transportadoras.py`. Ver
[[mensagens-de-erro-por-transportadora]], que e a outra mudanca pendente na
mesma tela.
