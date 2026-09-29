# Módulo A1 — Busca no cérebro (qmd)

**Quando:** depois de umas 3–4 semanas de uso, quando o cérebro passa de ~100 arquivos ·
**Tempo:** ~40 min · **Portão:** uma rotina real usa a busca e acha algo que o agente não
acharia lendo arquivo por arquivo

> **Claude:** módulo avançado, fora do núcleo. Não ofereça antes da Fase 9 concluída — com
> um cérebro de 20 arquivos, ler tudo é mais simples que buscar. O valor aparece quando o
> agente começa a "esquecer" coisas que estão escritas.

---

## Nivelamento (60 segundos)

Com o tempo, o cérebro vira centenas de arquivos. O agente não lê tudo a cada conversa, então
ele passa a responder "não sei" sobre coisas que **estão escritas**, só que num arquivo que ele
não abriu.

O **qmd** é um buscador que roda **dentro da VPS**, sem mandar nada para fora. Ele combina duas
buscas:
- **por palavra** (acha "Bitwarden" quando você escreve "Bitwarden")
- **por significado** (acha "cofre de senhas" quando você escreve "onde guardo as chaves")

A analogia: até agora o agente tinha uma estante. O qmd é o bibliotecário que sabe em qual
prateleira está cada assunto.

---

## Passo 1 — Instalar

```bash
ssh meu-agente 'node --version'           # precisa de Node 22+
ssh meu-agente 'npm install -g @tobilu/qmd && qmd --version'
```

Sem GPU (o caso de toda VPS barata), force CPU em **tudo** que chama o qmd:
`QMD_FORCE_CPU=1`. Na primeira indexação ele baixa os modelos de embedding (algumas centenas de
MB), uma vez só.

---

## Passo 2 — Coleções por grau de confiança

Não indexe o cérebro como um bloco só. Separe por **quanto dá para confiar** no conteúdo, e deixe
o material bruto fora da busca padrão, senão diário velho ganha de decisão curada.

Copie [`templates/qmd/index.yml`](../templates/qmd/index.yml) para `~/.config/qmd/index.yml` na
VPS, troque `NOME_DO_AGENTE` e os caminhos, e rode:

```bash
ssh meu-agente 'export QMD_FORCE_CPU=1; qmd update && qmd embed && qmd status'
```

| Coleção | O que tem | Na busca padrão? |
|---|---|---|
| `cerebro-identidade` | SOUL, USER, AGENTS, MAP | sim |
| `cerebro-curado` | decisões, lições, projetos | sim |
| `cerebro-skills` | como fazer cada coisa | sim |
| `cerebro-diario` | diários brutos | **não**, só com `-c` |
| `cerebro-sessoes` | transcrições | **não**, só com `-c` |

---

## Passo 3 — As três travas (aprendidas em produção)

1. **Rerank SEMPRE desligado sem GPU.** O rerank por LLM levou **4 minutos** por busca numa VPS
   de 4 vCPU, contra **2 segundos** sem ele. O MCP do qmd vem com `rerank: true` por padrão, e
   o agente vai usar o padrão. Escreva a regra no `AGENTS.md` e use o wrapper do passo 4.
2. **Uma coleção por chamada.** Na versão 2.5.x, `qmd query` híbrido com zero ou duas-ou-mais
   flags `-c` volta "No results" sem erro. O wrapper faz uma busca por coleção, em paralelo.
3. **Trocou coleção? Reconstrua.** Mudar o `index.yml` deixa documentos-fantasma no índice que
   o `cleanup` não remove. A via certa é `rm ~/.cache/qmd/index.sqlite*` (confira o caminho com
   `qmd status`) e depois `qmd update && qmd embed`.

---

## Passo 4 — O agente só usa o que está no caminho dele

Esta é a lição mais cara: **instalar o qmd como MCP não faz o agente usá-lo.** O MCP fica atrás
da busca de ferramentas do Hermes e, em produção, o agente continuou lendo arquivo por arquivo
por semanas (~100–150 leituras manuais por dia) com o qmd instalado e ocioso.

O que funcionou foi um **comando curto, com as travas embutidas, citado dentro das rotinas**:

```bash
scp templates/scripts/brain-search meu-agente:~/.hermes/scripts/brain-search
ssh meu-agente 'chmod +x ~/.hermes/scripts/brain-search && ~/.hermes/scripts/brain-search "assunto de teste"'
```

E, nas rotinas da Fase 7 que decidem alguma coisa (brief, cobranças, radar), uma linha
explícita no prompt:

> *"Antes de marcar algo como pendente ou urgente, rode `~/.hermes/scripts/brain-search "<pessoa
> ou assunto>"`. O resultado é pista, não fato: confirme no arquivo antes de afirmar. A busca só
> pode **rebaixar** um item (já resolvido, já respondido), nunca criar um novo."*

O MCP pode ficar instalado também, para conversas livres. Configure no `config.yaml` com
`env: {QMD_FORCE_CPU: '1'}`.

---

## Passo 5 — Manter o índice vivo

Crontab do Linux, não cron do Hermes (é mecânico, não precisa de modelo):

```bash
scp templates/scripts/qmd-index.sh meu-agente:~/.hermes/scripts/
ssh meu-agente 'chmod +x ~/.hermes/scripts/qmd-index.sh'
# crontab -e na VPS:  20 4 * * * ~/.hermes/scripts/qmd-index.sh
```

`qmd update` é incremental (~1 s); `qmd embed` só processa o que mudou.

**Par recomendado: compactação mensal.** Diário com mais de 30 dias vira um resumo mensal em
`memory/archive/`. O cérebro para de crescer sem controle, e a busca fica melhor, não pior. O
padrão que funciona é "a skill de revisão cura o conteúdo, um script move os arquivos", com modo
`--check`, tudo-ou-nada, e nada sai do Git.

---

## PORTÃO

1. `brain-search "<algo que você sabe que está num diário antigo>" --diario` acha o arquivo ✅
2. Uma rotina real rodou com a instrução do Passo 4 e citou algo encontrado pela busca ✅
3. `qmd status` mostra `Pending: 0` na manhã seguinte (o cron indexou) ✅

Registre no `ESTADO.md`: coleções, horário do cron e quais rotinas usam a busca.

---

### Fundo

**Por que não um banco vetorial na nuvem?** Porque o cérebro é privado e o qmd roda local, em
SQLite, sem chave de API, sem custo por consulta e sem mandar texto para fora. Para um cérebro de
alguns milhares de arquivos, sobra.

**A busca pode inventar?** Não, ela só aponta arquivos. Quem pode inventar é o agente ao
*interpretar* o trecho. Por isso a regra "pista, não fato: confirme na fonte".
