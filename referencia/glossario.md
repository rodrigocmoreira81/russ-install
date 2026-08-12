# Glossário

> **Claude:** use como fonte das analogias, não para despejar definição.
> Quando ela travar num termo, explique em uma frase e siga — o entendimento profundo vem
> do uso, não da definição.

---

## Infraestrutura

**VPS** — *Virtual Private Server*. Um computador na nuvem, só seu, ligado 24/7. Você aluga
por mês, como um apartamento. Sem monitor: você entra pelo terminal.

**SSH** — o jeito de entrar num computador remoto pelo terminal, com a conversa criptografada.

**Chave pública / privada** — um cadeado de duas peças. A **privada** fica só com você e nunca
sai do seu computador; a **pública** você entrega ao servidor. O servidor tranca com a pública
e só a privada abre. Mais seguro que senha porque não dá para adivinhar por tentativa.

**Terminal** — a tela preta onde você digita comandos. Um jeito diferente de conversar com o
computador: em vez de clicar, você escreve o que quer.

**root** — o usuário administrador do Linux. Pode tudo, inclusive quebrar tudo.

**systemd** — o gerente de processos do Linux. Decide o que liga no boot, reinicia o que cai,
guarda os logs.

**serviço / daemon** — programa que roda em segundo plano, sem terminal aberto, e que o sistema
liga sozinho no boot. A diferença entre um funcionário que só trabalha enquanto você olha e
um que tem a chave da loja.

**lingering** — ajuste do systemd que mantém os serviços de um usuário rodando mesmo quando ele
não está logado. Sem ele, o agente morre no primeiro reboot. Ver Fase 2.

**cron** — o agendador do Unix. `0 7 * * *` = minuto 0, hora 7, todo dia. Cinco campos:
minuto, hora, dia do mês, mês, dia da semana. `*` = qualquer.

**UTC** — fuso de referência mundial. Brasília é UTC−3. Servidor em UTC agendando 9h entrega
às 6h da manhã — origem de muita confusão.

---

## Git e GitHub

**Git** — sistema que guarda o histórico de mudanças em arquivos. Como um "salvar" que nunca
apaga as versões anteriores.

**GitHub** — site que hospeda repositórios Git na internet.

**repositório (repo)** — a pasta versionada pelo Git.

**commit** — um ponto salvo no histórico, com data, autor e descrição.

**push / pull** — enviar suas mudanças para o GitHub / trazer as de lá.

**rebase** — reorganizar seus commits para ficarem depois dos que chegaram. É o que o
`brain-sync.sh` faz para as duas pontas convergirem em vez de brigar.

**conflito** — duas mudanças no mesmo trecho. O Git marca com `<<<<<<<` e pede que um humano
(ou o Claude) decida.

**deploy key** — chave SSH que dá acesso a **um único repositório**. Se vazar, o estrago é
limitado — diferente de um token pessoal, que abre a conta inteira.

**.gitignore** — lista do que o Git deve ignorar. É onde entram `.env` e credenciais. Tem que
existir **antes** do primeiro commit.

---

## Agentes e IA

**agente** — diferente de chatbot em três coisas: **lembra** (memória persistente), **faz**
(executa tarefas de verdade) e **age sozinho** (acorda no horário marcado). Chatbot é atendente
de balcão; agente é assistente pessoal.

**Hermes Agent** — o programa open source (NousResearch) que vira o corpo do agente: memória,
ferramentas, canais de mensagem, agendamento.

**gateway** — a parte que conecta o agente às plataformas de mensagem (Telegram, Discord...).

**profile / sub-agente** — outro agente na mesma máquina, com identidade, memória e skills
próprias. Ver Fase 8.

**modelo (LLM)** — a "mente alugada". O que raciocina e escreve. Cobrado por token.

**token** — pedaço de palavra (~4 caracteres). Unidade de cobrança. Você paga o que **entra**
(contexto) e o que **sai** (resposta) — e o que entra costuma ser muito maior.

**contexto** — tudo que o modelo enxerga naquela mensagem: histórico, memória, instruções.
Contexto grande = resposta melhor **e** conta maior.

**fallback** — modelo reserva, usado quando o principal falha. Sem ele, o agente emudece sem
explicar por quê.

**skill** — receita em markdown que ensina o agente a fazer uma tarefa do seu jeito. Memória de
**procedimento** (como fazer), diferente da memória de **fatos**.

**segundo cérebro** — a memória do agente como arquivos de texto num repositório Git privado.
Você lê, corrige e versiona.

**SOUL.md / USER.md / AGENTS.md** — identidade do agente / quem é você / o que ele faz ao
acordar. Os três arquivos que ele lê sempre.

**memória curada vs. diário** — diário é livre e cronológico (`memory/2026-08-12.md`); curada é
deliberada e temática (`decisoes.md`, `projetos.md`). Promover do diário para a curada é
trabalho semanal e é o que mantém o custo sob controle.

**MCP** — *Model Context Protocol*. Padrão para conectar o agente a ferramentas externas
(Google, Notion, bancos de dados) sem código específico para cada uma.

**`[SILENT]`** — marcador que diz à rotina: se não há nada relevante, não mande nada.
O que separa assistente de spam.

**prompt** — o que você pede agora. Diferente de **skill** (como fazer, sempre) e de
**memória** (o que ele sabe). Escrever no lugar errado é o erro mais comum.
