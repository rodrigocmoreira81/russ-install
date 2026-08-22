# Fase 9 — Sobrevivência

**Tempo:** ~30 min · **Portão:** ela restaura o cérebro num diretório novo, sozinha

> **Claude:** esta é a fase que ninguém quer fazer e que decide se o agente ainda vai existir
> em seis meses. Ela é a última porque só faz sentido depois que existe algo a perder.
> Não termine o curso sem ela — a taxa de abandono mora aqui.

---

## Nivelamento (60 segundos)

Três coisas matam agente pessoal, nesta ordem de frequência:

1. **Quebrou e ela não soube consertar** → abandonou
2. **A conta veio maior que o esperado** → desligou
3. **Virou spam** → silenciou e esqueceu (isso o `[SILENT]` da Fase 7 já cobriu)

Esta fase é sobre as duas primeiras. E sobre uma quarta, mais rara e pior: perder o cérebro.

Boa notícia, e diga isso a ela: **o servidor é descartável.** Se a VPS pegar fogo hoje, com o
cérebro no GitHub ela reconstrói tudo em cerca de uma hora seguindo as Fases 1 a 4. O que não
se recompra é a memória.

---

## Passo 1 — Provar que o backup existe

Backup que nunca foi restaurado não é backup — é esperança. Faça o teste de verdade, agora:

```bash
# num diretório novo, restaurar o cérebro do zero
cd /tmp && rm -rf teste-restore
git clone git@github-cerebro:USUARIA/meu-cerebro.git teste-restore
ls teste-restore/ && ls teste-restore/memory/ | tail -5
```

**Ela** roda esse comando, não você. O objetivo é ela sentir que sabe fazer.

Confira junto: os arquivos de identidade estão lá? A memória dos últimos dias está lá?
Se faltar coisa, o `brain-sync.sh` não está pegando tudo — conserte agora.

Confirme também que o sync está vivo:

```bash
ssh meu-agente 'cd ~/.hermes/workspace && git log --oneline -5'
```

Se o commit mais recente for de três dias atrás, o cron da Fase 5 morreu. **Este é o momento
de descobrir isso, não daqui a três meses.**

---

## Passo 2 — O que o Git NÃO salva

Diga com clareza: o `.gitignore` da Fase 5 protege as chaves de vazarem — e, por consequência,
elas **não estão no backup**. Se a VPS sumir, ela precisa refazer:

- Token do bot Telegram → BotFather (`/token`)
- Chave de API do modelo → painel do provedor
- Deploy key do cérebro → gerar nova

Isso é o desenho correto, não uma falha. Mas ela precisa de uma lista do que vai ter que
refazer. Escreva essa lista no `ESTADO.md`, na seção *"Se eu perder a VPS"* — **sem as chaves,
só onde buscar cada uma.**

Se ela usa gerenciador de senhas, este é o momento de guardar os originais lá.

---

## Passo 3 — Custo sob controle

```bash
hermes status
hermes insights --days 30
```

Olhem juntos o gasto real do primeiro mês e comparem com o que ela esperava. Se estourou, os
três lugares para mexer, em ordem de impacto:

1. **Memória inchada** — contexto grande em toda mensagem. Rode a revisão semanal da Fase 7.
2. **Modelo caro para tarefa boba** — rotina mecânica não precisa de modelo de raciocínio.
3. **Rotina frequente demais** — de hora em hora raramente é necessário; diário quase sempre basta.

Combine uma checagem mensal no calendário dela. Cinco minutos.

---

## Passo 4 — Atualizar sem quebrar

```bash
hermes update
hermes doctor
```

A regra, aprendida no susto: **atualizar, verificar, ter caminho de volta.** Update
automático sem verificação já derrubou agente em produção — o serviço reinicia, sobe, morre
alguns segundos depois, e ninguém percebe até a rotina da manhã não chegar.

Ensine o hábito mínimo: depois de todo update, `hermes doctor` **e** mandar um "oi" no
Telegram. Trinta segundos que evitam uma semana de agente morto.

---

## Passo 5 — O reflexo mais importante

Quando algo quebrar, o instinto dela vai ser desistir ou chamar alguém. Ensine o terceiro
caminho, que é o que ela vai realmente usar:

> **Abra o Claude Code e diga:**
> *"Meu agente Hermes na VPS parou de responder. Conecta em `ssh meu-agente`, olha os logs
> com `journalctl --user -u hermes-gateway -n 50`, e me ajuda a descobrir o que houve.
> O runbook está em `referencia/runbook.md` no repo do curso."*

Ela tem um sysadmin de plantão e não sabe. Deixe essa frase escrita no `ESTADO.md`, pronta
para copiar. É provavelmente a linha mais útil do curso inteiro.

Mostre os três comandos de primeiro diagnóstico:

```bash
export XDG_RUNTIME_DIR=/run/user/0
systemctl --user status hermes-gateway.service     # está no ar?
journalctl --user -u hermes-gateway -n 50          # o que ele disse antes de morrer?
hermes doctor                                       # o que está torto?
```

---

## PORTÃO — e fim do curso

1. Ela restaurou o cérebro num diretório novo, com as próprias mãos ✅
2. A lista *"se eu perder a VPS"* está no `ESTADO.md` ✅
3. Ela sabe ver quanto gastou ✅
4. Ela tem a frase de socorro anotada ✅

---

## Fechamento (não pule isto)

Peça ao agente dela, pelo Telegram, para escrever a **primeira entrada de memória sobre a
própria criação**:

> *"Escreve no seu diário de hoje um resumo de como você foi construído: quando, por quem,
> o que você é capaz de fazer hoje, e o que a gente ainda quer que você aprenda."*

Depois peça pra ela abrir o GitHub e ler o commit.

Fecha o ciclo em três níveis: o agente exercita a memória, ela vê a memória funcionando de
ponta a ponta, e o cérebro nasce com uma origem escrita. É o melhor momento do curso —
e, se ela for dar uma palestra sobre isso um dia, é o slide final.

**Diga o que vem depois**, para não terminar no vazio:
- Conectar agenda e e-mail (com [`seguranca.md`](../referencia/seguranca.md) do lado)
- Uma skill nova por semana, sempre nascida de um incômodo real
- Ler o cérebro pelo Claude Code na máquina dela, clonando o repo
- Fase 8, se um dia doer

---

### Fundo

**Com que frequência devo mexer nisso?**
O padrão que funciona: **cinco minutos por semana** (revisão da memória, olhar `cron runs`) e
**meia hora por mês** (custo, update, backup). Menos que isso, o agente apodrece devagar.

**E se eu quiser trocar de VPS?**
Fases 1 a 4 na máquina nova, clonar o cérebro, refazer as chaves. Cerca de uma hora. Esse é
justamente o valor de não ter nada preso ao servidor.

**Como sei se está valendo a pena?**
Uma pergunta honesta uma vez por mês: *"se eu desligasse isso hoje, do que eu sentiria falta?"*
Se a resposta for "nada", ou o agente está mal configurado ou ela não precisava dele — e as
duas conclusões são úteis.
