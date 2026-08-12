# Fase 6 — As mãos (skills)

**Tempo:** ~40 min · **Portão:** a skill dispara sozinha e faz o trabalho

> **Claude:** volte ao `ESTADO.md` e releia a **resposta 1 da Fase 0** — a tarefa chata que
> ela queria não fazer mais. É essa skill que vocês vão construir. Não invente um exemplo
> genérico: o valor desta fase é ela ver a própria dor sendo resolvida. Diga isso a ela
> ("lembra que você falou que odiava X? é isso que a gente vai fazer agora").

---

## Nivelamento (60 segundos)

Uma **skill** é uma receita escrita em markdown que ensina o agente a fazer uma tarefa
específica, do jeito dela. É memória de **procedimento** — enquanto o segundo cérebro da
Fase 5 é memória de **fatos**.

A diferença que importa: o agente não carrega todas as skills o tempo todo. Cada skill tem
uma descrição, e ele lê a receita inteira **só quando a situação bate**. É por isso que dá
pra ter cinquenta skills sem estourar o contexto — e por isso a **descrição** é o campo mais
importante do arquivo. Descrição vaga = skill que nunca dispara.

Analogia: é a diferença entre alguém que sabe cozinhar em geral e alguém que tem o caderno de
receitas da sua avó. A segunda faz do **seu** jeito.

---

## Passo 1 — Ver o que já existe

Antes de escrever, olhe o que vem pronto:

```bash
hermes skills list          # o que já está instalado
hermes skills browse        # o catálogo
hermes skills search email  # buscar por assunto
```

Se existir algo próximo do que ela quer, instale e ajuste — sai mais rápido e ela aprende o
formato lendo código de verdade:

```bash
hermes skills inspect <nome>    # ver antes de instalar
hermes skills install <nome>
```

---

## Passo 2 — Anatomia de uma skill

Uma skill é uma pasta com um `SKILL.md` dentro:

```
~/.hermes/skills/minha-skill/SKILL.md
```

```markdown
---
name: resumo-do-dia
description: Resume os compromissos e pendências do dia. Use quando a pessoa
  perguntar "como está meu dia", "o que tenho hoje" ou pedir o resumo da manhã.
version: 1.0.0
metadata:
  hermes:
    tags: [rotina, agenda]
    category: productivity
---

# Resumo do dia

## Quando usar
- Ela pergunta como está o dia / o que tem hoje
- A rotina da manhã dispara

## Como fazer
1. Leia `memory/AAAA-MM-DD.md` de hoje
2. Liste os compromissos em ordem de horário
3. Destaque o que tem prazo hoje
4. Termine com UMA pergunta sobre a prioridade do dia

## Formato da resposta
- Máximo 8 linhas
- Sem saudação longa, direto ao ponto
- Emoji só para separar seções

## Nunca
- Não invente compromisso que não está na fonte
- Se a fonte estiver vazia, diga que está vazia
```

Três coisas para insistir com ela:

1. **A `description` é o gatilho.** Escreva as palavras que ela realmente usa. Se ela fala
   "me dá o panorama", isso tem que estar lá — não adianta descrição que só um manual usaria.
2. **A seção `Nunca` vale ouro.** É onde ela codifica o erro que o agente cometeu. Toda vez
   que ele fizer besteira, a correção vira uma linha aqui — e não acontece de novo.
3. **Formato explícito.** "Máximo 8 linhas" funciona; "seja conciso" não.

---

## Passo 3 — Construir a skill dela

Escreva **junto** com ela, não por ela. Método:

1. Peça pra descrever a tarefa como se estivesse ensinando um estagiário no primeiro dia.
2. Transcreva isso em passos numerados.
3. Pergunte: *"o que um estagiário faria de errado aqui?"* → vira a seção `Nunca`.
4. Pergunte: *"como você quer receber o resultado?"* → vira `Formato da resposta`.

Se a tarefa precisar de dado externo (agenda, e-mail, planilha), **pare e leia
[`referencia/seguranca.md`](../referencia/seguranca.md) com ela antes de conectar qualquer
coisa.** Não é formalidade — é onde ela decide conscientemente o que esse agente pode ver.

Salve e reinicie o gateway para ele enxergar a skill nova:

```bash
mkdir -p ~/.hermes/skills/NOME-DA-SKILL
# escreva o SKILL.md
hermes gateway restart
```

---

## Passo 4 — Testar e afinar

No Telegram, ela usa a skill **com as palavras dela**, não com o nome técnico. Se não disparar,
o problema é quase sempre a `description` — ajuste até disparar naturalmente.

Depois do primeiro resultado, pergunte: *"o que está errado nisso?"* Cada crítica vira uma
linha na skill. Duas ou três rodadas dessas e ela fica boa.

> Este ciclo — usar, criticar, ajustar o arquivo — é a habilidade mais importante do curso.
> Diga isso com todas as letras: **é assim que ela vai evoluir o agente sozinha, para sempre,
> sem precisar de você.** Se ela sair daqui sabendo só isso, já valeu.

---

## PORTÃO

1. Ela pede a coisa com as palavras naturais dela → a skill dispara.
2. O resultado está no formato que ela pediu.
3. Ela conseguiu fazer **pelo menos um** ajuste no `SKILL.md` sozinha e viu a mudança.

O item 3 é o que realmente importa. Sem ele, ela tem uma skill; com ele, ela tem autonomia.

Atualize o `ESTADO.md`: skill criada, o que faz, o que ainda falta afinar.

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Skill, prompt e memória — qual a diferença?**
**Memória** é o que ele sabe (fatos). **Skill** é como ele faz (procedimento). **Prompt** é o
que você pede agora (intenção). Escrever no lugar errado é o erro mais comum: instrução
permanente colada no chat toda vez deveria ser skill; fato sobre ela repetido em toda skill
deveria estar no `USER.md`.

**Quantas skills é demais?**
Não existe limite técnico relevante, porque só a descrição fica carregada. O limite é humano:
skills demais que fazem quase a mesma coisa começam a disparar uma no lugar da outra. Quando
isso acontecer, funda as duas.

**Skill pode rodar código?**
Pode — pode chamar scripts, APIs, ferramentas. Comece com markdown puro. Quando a receita
ficar repetitiva e determinística, aí vira script, e a skill passa a ser quem decide **quando**
rodar. Essa é a progressão natural.

**Onde arranjo mais skills?**
`hermes skills browse` traz o catálogo público. Vale olhar mesmo sem instalar: ler skill boa
dos outros é o jeito mais rápido de aprender a escrever a sua.
