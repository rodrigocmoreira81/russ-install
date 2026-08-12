# Do Zero ao Agente

**Construa seu próprio agente pessoal — rodando 24/7, com memória que não se perde.**
Guiado pelo Claude, do zero, mesmo que você nunca tenha aberto um terminal.

---

## Como começar

Instale o [Claude Code](https://claude.com/claude-code), abra o terminal, e cole isto:

```
Leia https://raw.githubusercontent.com/rodrigocmoreira81/do-zero-ao-agente/main/BOOTSTRAP.md
e me guie na construção do meu agente.
```

É isso. A partir daí o Claude vira seu instalador-tutor: ele explica, você executa,
ele confere se funcionou antes de seguir. Você pode parar a qualquer momento e retomar
depois — ele anota onde vocês pararam.

---

## O que você vai ter no final

- Um servidor seu na nuvem, ligado 24 horas
- Um agente com nome, personalidade e contexto sobre a sua vida
- Conversando com você pelo **Telegram**, do celular, de onde estiver
- Com **memória versionada em GitHub** — ele lembra do que importa, e você vê o histórico
- Com **habilidades** que você ensina e **rotinas** que rodam sozinhas
- E, principalmente: **entendendo como tudo isso funciona**

---

## Quanto custa e quanto demora

| | |
|---|---|
| **Tempo** | 3 a 5 horas, em quantas sessões você quiser |
| **VPS** | ~R$ 40–90/mês (recomendação: 2 vCPU / 8 GB) |
| **Modelo de IA** | de ~R$ 0 (plano que você já tem) a ~R$ 150/mês de uso |
| **Pré-requisitos** | cartão internacional, conta GitHub, Telegram, Claude Code |

Detalhes honestos em [`referencia/custos.md`](referencia/custos.md).

---

## As 10 fases

| # | Fase | O que você ganha |
|---|---|---|
| 0 | Bússola | Clareza sobre o que você está construindo e pra quê |
| 1 | O terreno | Uma VPS acessível por SSH |
| 2 | O corpo | Hermes instalado e sobrevivendo a reboot |
| 3 | A mente alugada | Um modelo respondendo, custo sob controle |
| 4 | A voz | Conversa por Telegram |
| 5 | A memória | Segundo cérebro em GitHub |
| 6 | As mãos | Sua primeira skill |
| 7 | O relógio | Rotinas automáticas |
| 8 | Os colegas | Sub-agentes especializados *(opcional)* |
| 9 | Sobrevivência | Backup, custo, e o que fazer quando quebra |

Mapa completo com os portões de verificação: [`MAPA.md`](MAPA.md).

---

## Por que "segundo cérebro em GitHub"?

Porque a diferença entre um chatbot e um agente é **memória que persiste e evolui**.

Aqui a memória do seu agente é um repositório Git privado: arquivos de texto que ele lê
no começo de cada conversa e escreve no fim. Isso te dá três coisas que um chatbot nunca
vai ter — você **enxerga** o que ele sabe, você **corrige** o que ele entendeu errado, e
você tem **histórico** de tudo que mudou.

É a mesma arquitetura que roda o Russ, agente pessoal que opera em produção desde 2026:
agenda, e-mail, WhatsApp, newsletter, rotinas. Este material é a destilação dessa
construção — incluindo os erros.

---

## Isso é seguro?

Você vai construir algo com acesso a coisas privadas suas. O material trata isso com
seriedade: chaves nunca passam pelo chat, o repositório do cérebro é sempre privado,
e a Fase 5 tem uma parada obrigatória em [`referencia/seguranca.md`](referencia/seguranca.md)
antes de conectar qualquer integração sensível.

Leia essa página antes de decidir se quer conectar WhatsApp ou e-mail. Sem drama e sem
susto — só o que você precisa saber para decidir com informação.

---

## Créditos

Método construído por **Rodrigo Moreira** a partir do Russ.
Roda sobre o [Hermes Agent](https://hermes-agent.nousresearch.com) (NousResearch), open source.
Inspirado no trabalho de Bruno Okamoto sobre segundo cérebro para agentes.

Quebrou algo ou está desatualizado? Abra uma issue.
