---
name: cotafrete-cif-fob
description: "CIF/FOB no cotafrete: quem paga e derivado da escolha, e o que cada transportadora recebe em cada modo"
metadata:
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-20T20:49:46.172Z
---

Regra do Enzo, implantada em 20/08/2026 (`24e4ce4` + `62d92bc`):

    CIF -> paga o REMETENTE
    FOB -> paga o DESTINATARIO

O campo "CNPJ de quem paga" **nao existe mais** no formulario. Virou um radio
de duas opcoes, e `CotacaoRequest.pagador_frete` e uma **propriedade derivada**
de `tipo_frete`. `extra="forbid"` no modelo faz `pagador_frete=...` levantar
erro em vez de ser ignorado calado.

## O que cada site recebe

| | CIF | FOB |
|---|---|---|
| Camilo (SSW) | `tp_frete=1` | `tp_frete=2` |
| Translovato | `value[payer_type]=1` (REMETENTE) | `=2` (DESTINATARIO) |
| Generoso | select `Remetente (CIF)` | `Destinatario (FOB)` |
| Jadlog | nao muda — o adapter do painel nao tem CNPJ no payload | idem |

## O bug que isso corrigiu

A Camilo tinha `tipo_frete = FRETE_FOB` **fixo no construtor** enquanto o
formulario mandava um CNPJ da Ventura como pagador — que e CIF. As duas
metades da mesma informacao viajavam separadas desde o inicio do projeto.
**Os precos da Camilo podem mudar** em relacao ao que a equipe conhecia.

## Generoso: a ponta travada troca de lado

O site trava no CNPJ da conta a ponta que a Ventura ocupa e deixa a outra
editavel. `pontas_a_digitar()` decide qual e qual. **No FOB o CNPJ travado do
destino traz SO o CEP** — cidade e rua vazias, o "Proximo" nao avanca e a
tela nao diz nada (a mensagem so aparece no `aria-invalid`). Solucao:
`_reativar_cep()` apaga e redigita **um digito**. Redigitar o CEP inteiro foi
o que comeu o zero a esquerda de `09.220-570`, que chegou no resumo como
`92.205-70`.

**How to apply:** ao mexer em qualquer adapter, lembrar que quem paga nunca e
digitado — sai de `req.tipo_frete`. A prova de ponta a ponta esta em
`tests/test_tipo_frete.py`; rodar ela antes de dar por pronto.

Ver [[cotafrete-estado-fase2]] e [[cotafrete-armadilhas-medidas]].
