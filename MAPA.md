# MAPA — as fases

> **Claude:** este é o índice. Leia **uma fase por vez**, quando chegar nela.
> Não pré-carregue as próximas — você perde precisão e começa a pular passos.

| # | Fase | O que a pessoa ganha | Tempo | Portão (como você sabe que funcionou) |
|---|---|---|---|---|
| 0 | [Bússola](fases/00-bussola.md) | Sabe o que está construindo e pra quê | 20 min | Ela consegue dizer em uma frase o que o agente dela vai fazer |
| 1 | [O terreno](fases/01-vps.md) | Uma VPS ligada, acessível por SSH sem senha | 45 min | `ssh meu-agente 'uptime'` responde |
| 2 | [O corpo](fases/02-hermes.md) | Hermes instalado e sobrevivendo a reboot | 30 min | `hermes doctor` limpo + serviço volta após `reboot` |
| 3 | [A mente alugada](fases/03-modelo.md) | Um modelo respondendo, com custo sob controle | 25 min | Agente responde no terminal da VPS |
| 4 | [A voz](fases/04-telegram.md) | Conversa pelo celular, de qualquer lugar | 30 min | Ela manda "oi" no Telegram e o agente responde |
| 5 | [A memória](fases/05-segundo-cerebro.md) | Segundo cérebro em GitHub que não se perde | 60 min | Ela conta um fato hoje, o agente lembra amanhã em sessão nova |
| 6 | [As mãos](fases/06-skills.md) | A primeira skill útil de verdade | 40 min | A skill dispara e faz o trabalho |
| 7 | [O relógio](fases/07-rotinas.md) | O agente age sozinho, sem ser chamado | 30 min | Chega uma mensagem no horário marcado, sem ela pedir |
| 8 | [Os colegas](fases/08-subagentes.md) | Sub-agentes especializados *(opcional)* | 45 min | Uma tarefa delegada volta pronta |
| 9 | [Sobrevivência](fases/09-sobrevivencia.md) | Backup, custo, e o que fazer quando quebra | 30 min | Ela restaura o cérebro de um backup sozinha |

**Fases 0–5 são o núcleo.** Quem parar na 5 já tem um agente pessoal de verdade.
As 6–7 são o que faz ele valer o dinheiro. A 8 é para quem pegou gosto.

---

## Referência (consulte quando precisar, não leia inteiro)

| Arquivo | Quando abrir |
|---|---|
| [`referencia/runbook.md`](referencia/runbook.md) | Qualquer coisa quebrou. Sintoma → causa → comando. |
| [`referencia/seguranca.md`](referencia/seguranca.md) | Antes de conectar WhatsApp, e-mail ou qualquer coisa privada. **Obrigatório.** |
| [`referencia/custos.md`](referencia/custos.md) | Ela perguntou "quanto isso vai me custar?" |
| [`referencia/glossario.md`](referencia/glossario.md) | Ela travou num termo. Você também pode usar como fonte das analogias. |

## Templates (você copia para a VPS dela)

`templates/` tem os arquivos que viram o cérebro inicial do agente: `SOUL.md`, `USER.md`,
`AGENTS.md`, a estrutura de `memory/`, uma skill de exemplo e o `brain-sync.sh`.
Não copie cru — **preencha com o que ela te contou na Fase 0.**
