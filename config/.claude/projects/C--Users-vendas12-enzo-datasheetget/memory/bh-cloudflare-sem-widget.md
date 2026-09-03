---
name: bh-cloudflare-sem-widget
description: A caixa do Cloudflare no B&H vive num closed shadow root — só se acha pelo input cf-turnstile-response.
metadata:
  type: project
---

Resolvido e confirmado a funcionar no servidor em 2026-09-01. Percebeu-se porque é que `scrapers/bhphotovideo.py` não encontrava
nada na página de desafio do servidor, apesar de a foto do ecrã mostrar a caixa
"Confirme que é humano": o widget está dentro de um **closed shadow root**. O
`page_source` serializa o hospedeiro como `<div></div>` vazio e o
`querySelectorAll` não entra lá — daí "zero iframes, zero checkboxes".

A única âncora no DOM normal é `input[name=cf-turnstile-response]`
(`id="cf-chl-widget-<aleatório>_response"`). O clique sai a 21px da esquerda da
moldura vizinha (altura ~65px) e a meio na vertical — medido na captura do
servidor: caixa 299x64 em (390,304), quadrado de x+9 a x+32.

**Why:** gastaram-se três rondas a afinar o clique quando o problema era não
haver alvo visível ao JS; a foto do ecrã e o `page_source` contradiziam-se e foi
essa contradição que deu o diagnóstico.

**How to apply:** um clique por CDP (`Input.dispatchMouseEvent`) atravessa o
shadow fechado; `switch_to.frame` e ActionChains não. Se um dia o Cloudflare
mudar o layout, medir outra vez pelo `.png` guardado em vez de adivinhar. Ver
[[servidor-datasheet-chrome-109]] e [[casasbahia-akamai-bloqueio]].
