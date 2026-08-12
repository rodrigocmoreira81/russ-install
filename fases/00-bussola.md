# Fase 0 — Bússola

**Tempo:** ~20 min · **Custo:** zero · **Pré-requisito:** nenhum

> **Claude:** esta fase não tem nenhum comando. É a mais importante mesmo assim.
> Quem pula ela constrói um agente genérico que não serve pra nada e abandona em duas
> semanas. Não deixe pular. Se ela estiver ansiosa para "começar de verdade", diga que
> isso *é* começar de verdade — e que são 20 minutos.

---

## Nivelamento (60 segundos)

Explique estas três coisas com as suas palavras, nesta ordem. Use analogia. Não leia em voz alta.

**O que é um agente (e o que não é).**
Um chatbot responde quando você pergunta e esquece tudo depois. Um agente tem três coisas
a mais: ele **lembra** (memória que persiste), ele **faz** (executa tarefas de verdade, não
só escreve texto), e ele **age sozinho** (acorda no horário marcado sem você chamar).
A analogia: chatbot é um atendente de balcão; agente é um assistente pessoal que trabalha
pra você mesmo quando você está dormindo.

**O que é uma VPS.**
É um computador de verdade, na nuvem, que é só seu e nunca desliga. Você aluga por mês, como
um apartamento. Por que não usar seu próprio computador? Porque seu computador dorme, viaja,
fica sem bateria e reinicia — e um assistente que só existe quando seu notebook está aberto
não é um assistente.

**O que é um "segundo cérebro".**
São arquivos de texto, guardados num repositório privado no GitHub, que o agente lê no começo
de toda conversa e escreve no fim. É a memória dele. A vantagem de ser texto em Git — e não
um banco de dados mágico — é que **você consegue ler, corrigir e ver o histórico**. Quando
o agente entender algo errado sobre você, você abre o arquivo e conserta.

---

## Passo 1 — O propósito

Faça estas três perguntas, **uma de cada vez**, esperando a resposta antes da próxima.
Não aceite resposta vaga: se ela disser "me ajudar no geral", puxe até um exemplo concreto.

1. **"Que tarefa chata você faz toda semana e queria não fazer mais?"**
   → Isto vira a primeira skill (Fase 6).

2. **"Que informação você gostaria de receber sem ter que ir buscar?"**
   *(ex.: resumo da agenda do dia, e-mails que precisam de resposta, um número do negócio)*
   → Isto vira a primeira rotina (Fase 7).

3. **"O que alguém precisaria saber sobre você para te ajudar bem?"**
   *(seu trabalho, com quem você fala, como você gosta que falem com você, seu fuso)*
   → Isto vira o `USER.md` (Fase 5).

Anote as três respostas literalmente no `ESTADO.md`. Você vai usar as três, de verdade,
nas fases seguintes — e vai lembrá-la disso quando chegar lá. Esse retorno é o que faz o
curso parecer feito sob medida.

> **Sinal de alerta:** se as respostas forem todas sobre "responder e-mail" ou "postar no
> LinkedIn", tudo bem — mas avise que integrações com e-mail e redes vêm **depois** do núcleo,
> e que a Fase 5 é onde o agente realmente começa a valer a pena.

---

## Passo 2 — O nome

Peça um nome para o agente. Não é enfeite: o nome define o tom, aparece em toda mensagem
do Telegram e é a primeira decisão de identidade. Se ela travar, ofereça três opções curtas
com personalidades diferentes e deixe escolher.

Pergunte junto: **"ele fala formal ou informal com você? Pode discordar de você?"**
Guarde a resposta — vira o `SOUL.md` na Fase 5.

---

## Passo 3 — O modo

Pergunte, com a diferença explicada em uma linha cada:

- **Copiloto** — você explica cada passo antes de executar. Mais lento, ela aprende.
- **Piloto** — você executa e resume. Mais rápido, ela entende menos.

Padrão é Copiloto. Registre no `ESTADO.md`.

---

## Passo 4 — Checklist de pré-requisitos

Confira um por um. **Não avance com nenhum item em aberto** — cada um deles trava uma fase
inteira mais à frente, e descobrir isso na Fase 4 é frustrante.

- [ ] **Cartão de crédito internacional** — para a VPS (Fase 1)
- [ ] **Conta no GitHub** — para o cérebro (Fase 5). Se não tiver: github.com, é grátis
- [ ] **Telegram no celular** — canal do agente (Fase 4)
- [ ] **Claude Code instalado** — onde você está rodando agora
- [ ] **3 a 5 horas** disponíveis, podendo ser em pedaços

---

## Passo 5 — Criar o ESTADO.md

Crie a pasta de trabalho (sugestão: `~/meu-agente/`) e escreva o `ESTADO.md` no formato
da seção 5 do `BOOTSTRAP.md`, já preenchido com: nome do agente, modo, e as três respostas
do Passo 1 em "Decisões tomadas".

---

## PORTÃO

Só avance quando **as três** forem verdade:

1. Ela consegue completar a frase: *"Meu agente vai me ajudar a ______"* com algo concreto.
2. O agente tem nome.
3. O checklist de pré-requisitos está inteiro marcado.

Se o item 1 falhar, volte ao Passo 1. É comum e não é problema — a maioria das pessoas
nunca parou pra pensar nisso.

---

### Fundo

*Abra este bloco se ela pedir "me explica melhor".*

**Por que memória em arquivos de texto e não num banco de dados?**
Três motivos práticos. (a) **Auditabilidade**: você abre e lê o que ele sabe sobre você —
tente fazer isso com os "embeddings" de um chatbot. (b) **Correção barata**: entendeu errado?
Você edita uma linha. (c) **Histórico**: o Git guarda cada mudança, com data, então você
consegue perguntar "quando ele passou a achar isso?".

O custo é que texto não escala infinitamente: lá pelos milhares de arquivos você precisa de
busca de verdade. Mas esse é um problema bom de ter, e demora muito para chegar.

**Por que não usar só o ChatGPT/Claude com memória ativada?**
Porque a memória deles é deles, não sua. Você não vê, não versiona, não leva embora e não
consegue fazer o agente agir às 7h da manhã sem você abrir o app. Este material é sobre ter
a coisa, não alugar.

**Isso não é overkill pra "só organizar minha agenda"?**
Talvez. Seja honesto sobre isso. O ponto de virada costuma ser quando a pessoa quer
**ação autônoma** (algo que acontece sem ela pedir) ou **contexto acumulado** (o agente
saber de coisas de três meses atrás). Se ela não quer nenhum dos dois, um app de tarefas
resolve melhor e você deveria dizer isso.
