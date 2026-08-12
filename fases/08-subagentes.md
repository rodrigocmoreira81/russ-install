# Fase 8 — Os colegas (sub-agentes)

**Tempo:** ~45 min · **Opcional** · **Portão:** uma tarefa delegada volta pronta

> **Claude:** esta fase é opcional e você deve dizer isso na cara dela. Sub-agente resolve um
> problema que a maioria das pessoas **ainda não tem**. Se ela chegou aqui uma semana depois de
> instalar, o conselho honesto é: use o agente único por um mês, e volte quando doer.
> Só siga se ela responder sim a pelo menos uma pergunta do Passo 1.

---

## Nivelamento (60 segundos)

Um **sub-agente** é outro agente, na mesma VPS, com identidade, memória e skills próprias —
mas parte do mesmo time. O agente principal delega tarefas a ele.

O ganho não é velocidade, é **contexto separado**. Um agente que sabe de finanças, marketing e
saúde ao mesmo tempo carrega tudo em toda conversa: mais caro, mais lento e mais confuso.
Separar dá a cada um um cérebro menor e mais afiado.

O custo é real: mais processos, mais memória para curar, mais coisa para quebrar. O Russ roda
seis gateways — e isso exige manutenção.

---

## Passo 1 — Ela precisa disso mesmo?

Faça as três perguntas. **Nenhum "sim" = pule a fase** e vá para a Fase 9. Sem culpa.

1. Ela já se pegou pedindo coisas de **domínios muito diferentes** ao mesmo agente, e ele
   misturou os assuntos?
2. Existe uma área com **vocabulário e regras próprias** (finanças, saúde, jurídico) que
   polui as outras conversas?
3. Ela quer que **outra pessoa** use um agente do time, sem ver o resto?

O caso 3 é o mais legítimo e o menos citado: separar por **quem acessa**, não só por assunto.

---

## Passo 2 — Criar o profile

No Hermes, sub-agente é um **profile**: config, skills e memória próprias.

```bash
hermes profile list
hermes profile create financeiro     # ou o nome do domínio dela
```

Cada profile ganha:
- `~/.hermes/profiles/<nome>/config.yaml` — modelo e ferramentas próprias
- `~/.hermes/profiles/<nome>/skills/` — skills só dele
- `~/.hermes/profiles/<nome>/SOUL.md` — identidade própria
- `~/.hermes/agents/<nome>/workspace/` — memória de trabalho

Comandos com profile levam a flag **antes** do subcomando — pegadinha que confunde:

```bash
hermes --profile financeiro cron list     # certo
hermes cron list --profile financeiro     # ERRADO (mexe no principal)
```

---

## Passo 3 — Dar identidade

Escreva o `SOUL.md` do sub-agente como na Fase 5, mas **estreito de propósito**. Um bom
`SOUL.md` de sub-agente diz o que ele **não** faz tanto quanto o que faz:

```markdown
Você cuida de finanças pessoais. Você NÃO opina sobre agenda, saúde ou
relacionamento — se perguntarem, devolva para o agente principal.
```

Fronteira explícita é o que evita virar cópia mais fraca do principal.

Um sub-agente pode ter modelo **mais barato** que o principal, se a tarefa dele for mecânica.
Boa economia, e é o momento de mostrar isso na prática.

---

## Passo 4 — Delegação

Duas formas:

```bash
# assíncrona (preferida) — cria um card, o sub-agente pega e trabalha
hermes kanban create "Fechar as contas do mês" --assignee financeiro

# síncrona — resposta única, na hora
hermes --profile financeiro -z "resuma meus gastos deste mês"
```

A assíncrona é melhor para tarefa longa: não trava o principal e deixa rastro auditável.

Se ela quiser o sub-agente com canal próprio no Telegram, é outro bot (Fase 4 de novo) e
outro serviço de gateway. Faça só se o caso 3 do Passo 1 for o motivo dela.

---

## PORTÃO

1. `hermes profile list` mostra o novo profile
2. Uma tarefa delegada volta com resultado coerente
3. O sub-agente **recusa** algo fora do escopo dele (teste isso de propósito — é o item que
   prova que a fronteira funciona)

Atualize o `ESTADO.md`: profiles criados, domínio de cada um, como delega.

---

### Fundo

**Por que não um agente só com skills demais?**
Porque skill não separa contexto — separa procedimento. Cinquenta skills num agente só ainda
é um cérebro só, com uma memória só e um tom só. Sub-agente separa memória e identidade.

**Eles compartilham memória?**
Depende de como for montado. O padrão útil: cada um tem memória de trabalho própria, e o
segundo cérebro (Fase 5) é compartilhado, com o que é comum a todos. Cuidado com a tentação de
compartilhar tudo — aí você tem um agente com nomes diferentes.

**Isso multiplica o custo?**
O custo de modelo é por uso, não por profile — dois agentes usados metade do tempo custam
parecido com um usado o dobro. O que multiplica de verdade é **RAM na VPS** (cada gateway é um
processo) e **seu tempo de manutenção**. Esse segundo é o caro.

**Quando parar de criar sub-agente?**
Quando ela não souber de cabeça o que cada um faz. Se precisa consultar uma lista para lembrar,
já passou do ponto.
