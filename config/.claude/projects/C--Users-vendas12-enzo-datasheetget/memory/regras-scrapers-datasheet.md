---
name: regras-scrapers-datasheet
description: Regras fixas para mexer nos scrapers deste projeto — não mudar arquitetura, mesmas bibliotecas, só corrigir bugs.
metadata:
  type: feedback
---

Regras dadas pelo utilizador, válidas para **todos** os ficheiros de `scrapers/`:

- **Nunca mudar a arquitetura.** Seguir sempre o mesmo padrão do código que já lá
  está: classe que herda de `BaseScraper`, método `executar()`, carregamento
  dinâmico pelo `scraper_manager.py`, encaminhamento por regex no `config.py`.
- **Mesmas bibliotecas.** Nada de dependências novas. O que há: `undetected_chromedriver`
  3.5.5, `selenium`, `bs4`, `requests`, `Pillow`, `deep_translator`, `python-docx`, `fpdf`.
- **Mesma formatação** do código existente (comentários em português, `print` com
  emojis e prefixo `[SITE]`, `except` curtos na mesma linha).
- **Só corrigir os bugs dos sites que não estão a funcionar** — não refazer o que já corre.
- O alvo é **Windows Server 2012 R2**, com **Chrome 109** (o último que lá corre):
  `version_main=109` nas opções do `uc.Chrome`, ver [[servidor-datasheet-chrome-109]].
- **Avisar assim que se encontra um problema**, mesmo que esteja fora do pedido.

**Why:** o servidor é antigo e a app é uma API Flask com uma thread por pedido; qualquer
biblioteca nova ou mudança de estrutura parte os 54 scrapers de uma vez.

**How to apply:** antes de editar, ler um scraper vizinho que funcione e copiar o padrão.
Ficheiros partilhados (`utils/generator.py`, `scrapers/base.py`) só se mexem com autorização
explícita, porque afetam todos os sites. Nomes de ficheiros temporários têm de ser únicos
(uma thread por pedido). Ver [[bh-cloudflare-sem-widget]].
