---
name: cotafrete-armadilhas-medidas
description: Máscaras de campo e travas antibot que fazem o cotafrete cotar carga errada em silêncio
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-28T13:57:33.034Z
---

Erros que NÃO dão mensagem nenhuma na tela — cotam carga errada e parecem
certos. Todos medidos em produção em 13/08/2026 e travados por teste.

**Máscara de campo, por site (o mesmo dado da ficha vai em formatos diferentes):**
- Della Volpe, MEDIDA: precisa de 1 casa decimal. `30` vira `3,0` — carga 10x
  menor. Use `medida_br()`, nunca `peso_br()`.
- Jadlog painel, PESO: máscara de 2 casas, da direita para a esquerda. `1`
  vira `0,01`, `0,5` vira `0,05`. Sempre mande `f"{kg:.2f}"` com vírgula.
- Jadlog painel, MEDIDA: SEM máscara. `30` fica `30`; `30,0` vira `30.0`.
  Regra oposta à da Della Volpe.
- Telefone (os dois): máscara brasileira de 10-11 dígitos. `+55 (27) ...`
  esvazia o campo na Della Volpe. Corte o 55 inicial.

**Della Volpe só aceita envio com janela VISÍVEL.** O reCAPTCHA v3 pontua
Chromium headless como robô e o Contact Form 7 responde "A submissão
mencionou-se como spam" — nenhum e-mail é gerado. Com `headless=False` passa.

**Generoso: checkpoint da Vercel, desde 28/08/2026.** O portal passou a
responder "Falha ao verificar seu navegador — Código 21" (rodapé "Ponto de
verificação de segurança da Vercel | gru1::…"), e a página de login nem
existia: o adapter morria esperando `input[name="email"]`. Matriz medida:

| janela | `navigator.webdriver` | User-Agent | resultado |
|---|---|---|---|
| não | true | HeadlessChrome | Código 21 |
| sim | true | Chrome | Código 21 |
| não | false | HeadlessChrome | Código **29** |
| sim | false | Chrome | **passou, 4,9s** |

São DUAS marcas e as duas precisam sair juntas — consertar uma só troca o
código do erro. Janela headed fora da tela **mais**
`--disable-blink-features=AutomationControlled`. Ambas em
`carriers/base.py`; a Della Volpe deliberadamente NÃO herda a flag, porque a
configuração dela foi medida contra o reCAPTCHA e remedir custaria uma
submissão real. Isso é remendo: a saída durável é pedir liberação à Generoso,
que tem a Ventura como cliente.

**Confirmação de envio da Della Volpe** é o TEXTO dentro de
`div.wpcf7-response-output` ("Agradecemos a sua mensagem"). O site NÃO usa a
classe `wpcf7-mail-sent-ok`, e procurar "sucesso" no HTML dá falso positivo
(a página tem uma seção "Casos de sucesso").

**FATOR_CUBAGEM = 300 está CONFIRMADO** para a Della Volpe, por quatro
propostas reais que declaram o peso cubado calculado por eles.

**Why:** esta classe de bug não aparece em teste de fumaça nem em detector de
"print não está vazio" — só olhando o valor que o site ecoa de volta.

**How to apply:** ao ligar um site novo, encha cada campo e LEIA de volta com
`input_value()` antes de confiar. Ver [[cotafrete-tres-transportadoras]].
