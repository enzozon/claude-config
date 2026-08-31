---
name: mensagens-de-erro-por-transportadora
description: "Ideia do Enzo (18/08/2026) — traduzir erro técnico de cada transportadora em aviso que o vendedor entende, na própria tela de resultado"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-28T14:51:36.742Z
---

**FEITO em 28/08/2026.** `MENSAGENS_DE_ERRO` + `mensagem_amigavel()` em
`web/app.py`, cobrindo a Generoso; testes em `tests/test_mensagens_erro.py`.
A frase entra ANTES do texto técnico no cartão, nunca no lugar dele.

Duas lições da implementação:

- **A tradução é o último recurso.** Recusa e credencial já viram frase boa na
  FONTE (`motivo_recusa`), que é onde a classificação deve morar — a
  retentativa lê o status, não o texto. Cada entrada no mapa é dívida: quer
  dizer que o adapter ainda devolve como "não sabemos" algo classificável.
- **As marcas casam sem acento.** O mesmo adapter escreve "endereço" numa
  linha e "endereco" na outra; casar só uma forma deixava metade dos erros
  reais sem tradução.

Pedido original, de **18/08/2026**: na tela de resultado da cotação, mostrar
exceções em linguagem de vendedor, no lugar da mensagem técnica da
transportadora.

Exemplos que ele deu:
- **"TRANSLOVATO NÃO ATENDE ESSE CEP"** — o site responde
  *"Desculpe, o CEP informado não está em nossa região"* num sweet-alert.
  Vale checar antes de preencher: o endpoint `/solicitacao-de-cotacao/
  validate-cep-attend` responde isso logo depois do CEP, então dá para avisar
  o vendedor na hora em vez de deixar a cotação falhar no fim.
- **"JADLOG aceita apenas 1 volume por cotação"** — a calculadora do painel
  cota UM pacote por vez; a regra combinada é N cálculos separados, um por
  volume.

A lista cresce conforme formos testando cada site — cada erro novo que
aparecer vira uma linha aqui e uma mensagem na tela.

**Why:** o vendedor não sabe o que é "sweet-alert", "timeout" ou "praça fora da
malha". Se a tela mostrar o erro cru, ele não sabe se o problema é o sistema,
a internet dele, ou a carga — e liga para o Enzo. Uma frase clara resolve
sozinha.

**How to apply:** um mapa de exceção por transportadora (slug → mensagem), lido
na hora de montar o cartão de resultado em `web/app.py`. Erro conhecido vira
frase amigável; erro desconhecido continua mostrando o texto original, para não
esconder informação. Ver [[translovato-regras-do-portal]] e
[[cotafrete-armadilhas-medidas]].
