---
name: dellavolpe-turnstile-e-o-favorito
description: "A Della Volpe pôs Cloudflare Turnstile e saiu das automáticas em 31/08/2026; combinado com o Enzo: fazer o bookmarklet em 01/09/2026"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-31T20:46:50.557Z
---

Em **31/08/2026** a Della Volpe pôs **Cloudflare Turnstile** no formulário
público. Não é mais o reCAPTCHA v3 invisível: é uma caixa **"Confirme que é
humano"**. Sem ela marcada o Contact Form 7 recusa como spam e **nenhum e-mail
é gerado** — as cotações #78 a #84 falharam todas assim.

**Medido com envio real autorizado pelo Enzo em 31/08/2026** (e-mail
`vendas2@venturainformatica.com.br`), e o teste **refutou** a hipótese dele de
que o segundo clique resolveria:

- `_wpcf7_turnstile_response` vazio antes do 1º clique
- vazio ainda 30s depois da recusa
- 2º clique recusado igual; nada enviado nas duas vezes
- o widget **escala** para a caixa interativa — não é espera que resolve
- a flag `--disable-blink-features=AutomationControlled` (a que salvou a
  Generoso) **não** muda nada aqui

**Já feito, no branch `dellavolpe-assistida`** (557 testes passando, **não
commitado** até 31/08): ela saiu de `AUTOMATICAS`, entrou em "Precisa de você"
com a rota `/email/{cotacao_id}/{slug}` — tela com o texto pronto (o mesmo do
WhatsApp) e o endereço `comercial@dellavolpe.com.br`, que está impresso no
formulário deles. Cadastro novo `POR_EMAIL` em `web/transportadoras.py`.

**COMBINADO PARA 01/09/2026:** fazer a **opção 1, o bookmarklet**. Um favorito
na barra do navegador que, com o site da Della Volpe aberto, preenche o
formulário inteiro; o vendedor só marca a caixa e aperta enviar. É o que o
Enzo pediu: *"que já abrisse o site com tudo preenchido só para o humano
apertar no botão"*.

Por que só assim: o servidor roda numa máquina e o vendedor está no navegador
dele, e uma página não pode escrever dentro de outra origem. O bookmarklet é o
único caminho que roda no contexto da página deles.

**Why:** o Enzo duvida que respondam e-mail fora do formulário — ele conhece o
processo deles. E a parte cara para o vendedor não é clicar, é digitar 15
campos.

**How to apply:** o favorito busca os dados no Cotafrete (CORS liberado do
nosso lado) e usa o mapeamento de campos já medido em `SELETOR_POR_ROTULO`, em
`carriers/dellavolpe/adapter.py`. Instalação uma vez por máquina. Frágil a
mudança no site deles — mesma fragilidade que o adapter já tinha.

**A linha que não se cruza:** marcar a caixa "confirme que é humano" por
código. Preencher campo é conveniência; marcar a caixa seria derrubar o
controle que o dono do site instalou. Ver [[cotafrete-armadilhas-medidas]] e
[[mensagens-de-erro-por-transportadora]].
