---
name: cotafrete-estado-fase2
description: "Onde o cotafrete esta em 25/08/2026 — 4 transportadoras automaticas, filtro no ar, e as duas pastas que ja se confundiram uma vez"
metadata:
  node_type: memory
  type: project
  originSessionId: ebdc2a9f-5e47-4b30-a16f-6793b031032f
  modified: 2026-08-25T14:30:00.000Z
---

**EM PRODUCAO desde 19/08/2026.** Em 25/08 produção está em `5c2c4c4` e dev em `764990e`:
retentativa, filtro de transportadoras e as recusas com a voz do proprio site.
**426 testes + 1 xfail.**

## Hospedagem

Duas pastas, cada uma com `.venv`, `.env` e banco proprios:

| | `enzo/cotafrete/` | `enzo/cotafrete-producao/` |
|---|---|---|
| para que | desenvolvimento | a equipe usa |
| sobe com | `Cotafrete.bat` (**porta 8001**) | `Servidor.bat` (0.0.0.0:8000) |
| atualiza | edicao direta | so `git pull` |

**Em 25/08 as duas se confundiram de verdade.** `Servidor.bat` existe nas duas
pastas e escutava na 8000 nas duas; nada na tela dizia qual era qual. A empresa
passou a manha na pasta de DEV — quatro cotacoes reais (Rayane, Eliane, vendas6)
caíram no banco de dev e foram migradas na mao para producao como #16 a #19.
Hoje o `Servidor.bat` **se recusa a subir de fora de `cotafrete-producao`**
(trava dentro do proprio arquivo, olhando `%~dp0`). Nao dava para simplesmente
apagar a copia da dev: o arquivo e versionado e as duas pastas sao o MESMO
repositorio, entao a exclusao chegaria em producao no `git pull` seguinte.

Maquina do Enzo, IP fixo **192.168.1.250**. Sem autenticacao de verdade.

**Rodar pytest DENTRO da pasta de producao mexe no banco de producao** —
`web/app.py` faz `banco = Banco()` e `marcar_interrompidas()` no import. Desde
24/08 ha uma guarda de idade (`ESPERA_MAXIMA_S`, hoje **300s**) que protege
cotacao recem-criada; ainda assim, o certo e rodar teste na pasta de dev.
Backup consistente: `sqlite3.connect(...).backup()`, com o servidor parado.
A pasta `backup/` e gitignored (tem CNPJ de cliente).

## Transportadoras

**Automaticas:** camilo, jadlog, translovato, **generoso**.
**Por WhatsApp:** 14 em `web/transportadoras.py`. O vendedor escolhe quais
cotar no painel de filtro (`core/selecao.py`: `None` = todas, inclusive as
futuras; `""` = nenhuma).

**Generoso cota LOGADA** (`GENEROSO_USUARIO`/`_SENHA` no .env). Deslogada so
confirma recebimento; logada devolve preco, protocolo e prazo na hora. O site
**trava no CNPJ da conta `08.310.365/0001-24`** a ponta que a Ventura ocupa —
origem no CIF, destino no FOB — e a tela avisa quando o vendedor digitou outro.

**Della Volpe**: o bloqueio da janela CAIU em 25/08/2026. Headless continua
sem enviar (o CF7 marca como spam), mas a janela headed pode ficar FORA DA TELA
— medidos 14 sinais de impressao digital, todos identicos aos da janela normal,
e `--window-position=-3000,-3000` nao e puxado de volta pelo Windows. Dois
envios reais aceitos, e-mail confirmado pelo Enzo.

Falta para ela entrar em `AUTOMATICAS`: entrar **desmarcada por padrao** no
filtro (cada submit vira cotacao na fila de um vendedor de la) e o ingestor
IMAP, porque ela so responde por e-mail.

## Em aberto

1. **Medir a concorrencia** — QUATRO navegadores disputando duas vagas
   (`NAVEGADORES_SIMULTANEOS = 2`), teto `ESPERA_MAXIMA_S = 300` contado desde a
   CRIACAO da cotacao. Generoso leva 34-43s. Adiado varias vezes; e o risco que
   sobrou.
2. **Backup automatico do banco** — hoje e manual.
3. **Renomear `enzo/cotafrete` para `cotafrete-dev`** — o Windows nao solta o
   diretorio enquanto o Claude Code estiver aberto nele. Nada no codigo depende
   do nome; a trava do `Servidor.bat` procura `cotafrete-producao`, nao o nome
   da dev.
4. **Apagar o historico antes de mandar o link para a equipe** (ideia do Enzo):
   sao tres tabelas (`cotacao`, `resultado`, `whatsapp_aberto`), mais
   `sqlite_sequence` para zerar a numeracao, mais os prints orfaos em
   `teste_real/`. Servidor parado.
5. Fase 3: ingestor IMAP para as propostas em PDF.

## Pendencias

- **`DV_ENVIO_REAL_AUTORIZADO=sim` esta no `.env` da pasta de DEV** (nao na de
  producao, como esta nota dizia antes de 25/08). Nao dispara — Della Volpe
  esta fora de `AUTOMATICAS` — mas e uma bomba com o pino solto.
- **Opcao "Terceiro"** existe no select da Generoso e nao foi implementada.
- **Translovato recusa todo frete FOB** — a regra dela e "sai sempre da
  Ventura". Comportamento correto, cartao vermelho esperado.
- Tres erros da Generoso/Translovato ainda sem tratamento proprio: "a etapa do
  destino nao avancou" (sem mensagem visivel), login recusado, e timeout da
  Translovato. Caem na retentativa por sorte, nao por entendimento.

**Why:** o sistema virou multiusuario e ganhou a quarta transportadora sem
nunca ter medido quanta gente aguenta ao mesmo tempo. Ver
[[cotafrete-cif-fob]], [[cotafrete-armadilhas-medidas]] e
[[mensagens-de-erro-por-transportadora]].
