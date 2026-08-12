# Fase 7 — O relógio (rotinas)

**Tempo:** ~30 min · **Portão:** chega uma mensagem no horário marcado, sem ela pedir nada

> **Claude:** aqui o agente deixa de ser ferramenta e vira presença. Até agora ele só existia
> quando chamado; a partir de hoje ele aparece sozinho. Use a **resposta 2 da Fase 0** —
> a informação que ela queria receber sem ir buscar. Releia no `ESTADO.md` antes de começar.

---

## Nivelamento (60 segundos)

**Cron** é o agendador do Unix — o despertador do sistema. Você diz "toda segunda às 8h,
faça isso" e ele faz, para sempre, sem ninguém ligado.

O que muda no caso de um agente: um cron comum roda um comando fixo. Um cron do Hermes roda
**um prompt** — ou seja, o agente acorda, pensa com todo o contexto e a memória dele, e entrega
o resultado no Telegram. A diferença entre "às 7h envie este texto" e "às 7h olhe minha
agenda, meus e-mails e minha memória, e me diga o que importa hoje".

A sintaxe `0 7 * * *` assusta e não precisa: são cinco campos — **minuto, hora, dia do mês,
mês, dia da semana** — e `*` significa "qualquer". Então `0 7 * * *` é "minuto 0 da hora 7,
todo dia". O Hermes também aceita formato humano: `30m`, `every 2h`.

---

## Passo 1 — Confirmar o fuso (a pegadinha)

Cron usa o fuso **do servidor**. Se a VPS estiver em UTC e ela pedir 9h, chega às 6h da manhã —
e ela vai achar que está tudo quebrado.

```bash
ssh meu-agente 'timedatectl | grep "Time zone"; date'
```

Se vocês fizeram a Fase 1 direito, já está em `America/Sao_Paulo` e ela agenda no horário de
Brasília, direto, sem conta nenhuma. **Aproveite para mostrar o retorno:** aquela linha
aparentemente boba da Fase 1 acabou de economizar um problema chato.

Se estiver em UTC e ela não quiser mudar, a regra é somar 3 horas: 9h BRT = `0 12 * * *`.

---

## Passo 2 — A primeira rotina

Comece pelo brief da manhã — é o que dá vontade de continuar:

```bash
hermes cron create '0 7 * * *' \
  "Bom dia. Leia meu diário de hoje e de ontem na memória, veja o que ficou pendente e me mande um resumo de no máximo 6 linhas com o que importa hoje. Se não houver nada relevante, responda apenas [SILENT]." \
  --name brief-matinal \
  --deliver telegram:ID_DELA
```

O `ID_DELA` é o número que ela pegou com o @userinfobot na Fase 4 — está no `ESTADO.md`.

Confira e teste **sem esperar até amanhã**:

```bash
hermes cron list
hermes cron run brief-matinal      # roda no próximo tick
```

---

## Passo 3 — `[SILENT]`: a regra que salva a rotina

Repare no fim do prompt acima. Isso não é detalhe.

**Rotina que fala todo dia, mesmo sem ter o que dizer, vira spam — e spam é desinstalado em
duas semanas.** É a causa número um de morte de agente pessoal.

O marcador `[SILENT]` diz ao Hermes: se não há nada que valha a pena, não entregue nada. O
agente decide se aquele dia merece uma mensagem. Coloque isso em **toda** rotina que ela criar.

Diga a frase inteira pra ela: *"a rotina só te procura quando tem algo pra dizer."* É a
diferença entre um assistente e um alarme.

---

## Passo 4 — Mais duas rotinas (e onde parar)

Duas boas candidatas, ambas nascidas da resposta 2 da Fase 0:

| Rotina | Quando | Para quê |
|---|---|---|
| Fechamento do dia | `0 21 * * *` | Perguntar o que aconteceu e gravar na memória — alimenta a Fase 5 sozinho |
| Revisão semanal | `0 18 * * 0` | Ler a semana, promover o que virou permanente para a memória curada |

A revisão semanal é a mais subestimada: é ela que impede o cérebro de virar depósito e o custo
de subir sozinho.

> **Segure a mão dela em três rotinas.** Quem cria dez no primeiro dia recebe dez mensagens
> irrelevantes e desliga tudo. Melhor três que ela lê de verdade.

Rotinas que não usam LLM (checagem de disco, watchdog) podem rodar com `--no-agent --script`,
sem custo nenhum de modelo. Vale mencionar, sem construir agora.

---

## Passo 5 — Operar as rotinas

Comandos que ela vai usar de verdade — deixe anotado no `ESTADO.md`:

```bash
hermes cron list              # o que está agendado
hermes cron list --all        # inclui as pausadas
hermes cron pause <nome>      # silenciar sem apagar (férias!)
hermes cron resume <nome>
hermes cron run <nome>        # rodar agora, para testar
hermes cron runs              # histórico de execuções — o que rodou e o que falhou
hermes cron remove <nome>
```

`hermes cron runs` é o primeiro lugar a olhar quando uma rotina "não chegou".

---

## PORTÃO

O único teste que vale é o do tempo real: **espere o horário chegar** (ou agende para dali a
5 minutos com `*/5 * * * *` e apague depois).

Passou se a mensagem chega no Telegram, sozinha, no horário certo, e o conteúdo é útil.

Chegou mas está ruim? Não é falha do cron — é o prompt da rotina. Ajuste com
`hermes cron edit` e rode de novo. Duas ou três rodadas.

Não chegou? → [`referencia/runbook.md`](../referencia/runbook.md), seção *"Cron não roda"*.

Atualize o `ESTADO.md`: rotinas criadas, horários, ID de entrega.

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Cron do Hermes vs. crontab do Linux — quando usar cada um?**
Se a tarefa precisa **pensar** (ler contexto, decidir, escrever bem), é cron do Hermes.
Se é mecânica e determinística (o `brain-sync.sh` da Fase 5, um backup), é crontab do Linux —
não precisa de LLM e não custa nada. Usar o agente para copiar arquivo é pagar caro por `cp`.

**O que acontece se o agente estiver ocupado na hora?**
O Hermes enfileira. E se a VPS estiver desligada na hora exata, aquela execução é perdida —
não roda "atrasada". Mais um motivo para o lingering da Fase 2.

**Dá pra rotina disparar por evento em vez de horário?**
Dá — via webhook, o agente reage a algo que aconteceu (e-mail novo, formulário preenchido).
É o passo natural depois, e bem mais poderoso que horário. Mas horário primeiro: é mais fácil
de depurar e ensina o conceito.

**Como eu descubro que uma rotina parou de funcionar?**
Essa é a pergunta certa, e a resposta honesta é que rotina silenciosa que quebrou parece
rotina silenciosa que não tinha nada a dizer. Duas defesas: `hermes cron runs` na revisão
semanal, e uma rotina de heartbeat semanal que fala **sempre**, mesmo que só para dizer
"estou vivo, rodei N tarefas essa semana".
