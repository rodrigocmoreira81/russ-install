# Fase 4 — A voz (Telegram)

**Tempo:** ~30 min · **Portão:** ela manda "oi" do celular e o agente responde

> **Claude:** esta é a fase mais gratificante do curso. Até agora o agente vivia num terminal
> preto; agora ele aparece no celular dela como um contato. Trate como o momento que é —
> muita gente só "entende" o projeto quando isso acontece.

---

## Nivelamento (60 segundos)

O **gateway** é a parte do Hermes que conecta o agente a plataformas de mensagem. Ele fica
escutando o Telegram e, quando chega mensagem, entrega ao agente e devolve a resposta.

Um **bot** do Telegram é uma conta especial controlada por programa em vez de pessoa. Quem
cria bots é o próprio Telegram, através de um bot chamado **@BotFather** — sim, um bot que
cria bots. Ele devolve um **token**, que é a senha do bot. Quem tem o token controla o bot;
por isso ele nunca é colado em chat, nem em commit.

O Hermes também fala Discord, Slack, WhatsApp, Signal e e-mail. Começamos por Telegram porque
é o mais simples e o mais confiável — sem aprovação de app, sem número de telefone, sem risco
de banimento.

---

## Passo 1 — Criar o bot

**No celular dela**, no Telegram:

1. Buscar por **@BotFather** e abrir a conversa
2. Enviar `/newbot`
3. Escolher um **nome de exibição** — sugira o nome da Fase 0
4. Escolher um **username**, que precisa terminar em `bot` (ex.: `helena_assist_bot`).
   Muitos já estão tomados; ela vai precisar de duas ou três tentativas. Avise antes pra não
   parecer erro.
5. O BotFather devolve um **token** parecido com `8123456789:AAH...`

> **Como copiar esse token sem quebrá-lo.** Peça para ela **tocar no bloco de código** da
> mensagem do BotFather (no celular, isso copia só o token). Duas armadilhas reais:
> - **Nunca copie de um print/foto.** O reconhecimento de texto do celular troca caracteres
>   parecidos — já vimos `0` virar `ø`. O gateway morre com erro de configuração e o log fala
>   em *"lookalike Unicode glyphs"*, que ninguém entende na hora.
> - **Nunca selecione a mensagem inteira** — vem junto o texto todo do BotFather, centenas
>   de caracteres.
>
> Valide **na VPS** (Linux), nunca no terminal do Mac — o `grep` do macOS não barra
> caracteres não-ASCII com `[A-Za-z0-9]` e aprova um token corrompido:
> ```bash
> ssh meu-agente "grep -m1 '^TELEGRAM' ~/.hermes/.env | cut -d= -f2- | tr -d '[:space:]' \
>   | grep -qE '^[0-9]{8,12}:[A-Za-z0-9_-]{30,40}$' && echo 'token OK' || echo 'TOKEN CORROMPIDO'"
> ```

> **Pare aqui e diga:** esse token é a senha do bot. **Não cola no nosso chat.** Ela vai
> digitá-lo direto no prompt do Hermes na VPS, no próximo passo. Se ela já tiver colado no
> chat sem querer, mande revogar com `/revoke` no BotFather e gerar outro — leva 10 segundos
> e é a atitude certa.

Aproveite e sugira dois toques opcionais no BotFather, que fazem o bot parecer coisa séria:
`/setdescription` e `/setuserpic`.

---

## Passo 2 — Descobrir o ID dela no Telegram

O agente precisa saber **quem** é a dona, para não responder a estranho. Ela precisa do
próprio ID numérico: busque **@userinfobot** no Telegram, mande qualquer mensagem, e ele
devolve o `Id`. Anote — vai ser usado no próximo passo e de novo na Fase 7.

---

## Passo 3 — Configurar o gateway

Na VPS:

```bash
hermes gateway setup
```

O wizard pergunta a plataforma (**Telegram**), o token (**ela cola aqui**) e quem tem
permissão de falar com o bot. **Preencha a lista de usuários permitidos com o ID dela.**

> Isto não é opcional. Um bot do Telegram é encontrável por qualquer pessoa que saiba o
> username. Sem lista de permissão, qualquer estranho conversa com um agente que tem acesso
> à vida dela e gasta o dinheiro dela. Explique isso — é a lição de segurança mais importante
> desta fase.

Depois:

```bash
hermes gateway restart
hermes gateway status
```

---

## Passo 4 — Primeira conversa

Ela abre o Telegram, busca o username do bot, e manda **"oi"**.

Se demorar, acompanhe os logs ao vivo enquanto ela manda — dá pra ver a mensagem chegando:

```bash
export XDG_RUNTIME_DIR=/run/user/0
journalctl --user -u hermes-gateway -n 30 -f
```

Mostre alguns comandos úteis que funcionam dentro do Telegram:

| Comando | O que faz |
|---|---|
| `/new` | Começa conversa do zero (limpa o contexto) |
| `/model` | Troca o modelo na hora |
| `/usage` | Quanto já gastou |
| `/skills` | Lista as habilidades dele |
| `/stop` | Interrompe o que ele está fazendo |

### Áudio: ajuste o idioma agora

O Telegram é onde chega o primeiro áudio, e a transcrição do Hermes **nasce configurada em
inglês**. Sem isso, um áudio em português vira salada — nomes próprios viram palavras
inglesas e ela acha que o agente é burro.

```bash
hermes config set stt.language pt
hermes config set stt.local.model small     # o "base" erra demais; 2 vCPU aguenta o "small"
```

O primeiro áudio depois disso baixa ~460 MB de modelo, então demora. Avise, senão parece
travamento. Palavra em inglês no meio do português ainda escapa — isso se resolve depois,
com um glossário na skill (Fase 6).

---

## PORTÃO

1. Ela manda "oi" pelo celular e recebe resposta coerente. ✅
2. **Teste de segurança:** peça pra ela pedir a alguém de confiança que busque o bot e mande
   uma mensagem. O bot deve **ignorar** ou recusar. Se responder, a lista de permissão está
   errada — volte ao Passo 3 e conserte antes de seguir.

Falhou? → [`referencia/runbook.md`](../referencia/runbook.md), seção *"Telegram não responde"*.

Atualize o `ESTADO.md`: username do bot, ID dela, lista de permissão confirmada.
**Nunca o token.**

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Por que Telegram e não WhatsApp?**
WhatsApp não tem bot oficial gratuito. As opções são a API oficial do Business (burocracia,
aprovação, custo por mensagem) ou bibliotecas não oficiais que sobem uma sessão do WhatsApp
Web — que funcionam, mas violam os termos e podem gerar banimento do número. O Hermes suporta
WhatsApp, e o Russ usa — mas como **fonte de dados**, não como canal principal. Se ela quiser
seguir esse caminho depois, [`referencia/seguranca.md`](../referencia/seguranca.md) trata dos
riscos com honestidade.

**Alguém consegue ler minhas conversas com o agente?**
O Telegram vê as mensagens (não são criptografadas ponta a ponta em chats normais com bot),
e o provedor do modelo vê o que é enviado a ele. Não é diferente de usar o ChatGPT — mas é
bom ela saber, principalmente antes de conectar e-mail e agenda na Fase 6.

**Posso ter o mesmo agente em vários canais?**
Sim — o mesmo agente, o mesmo cérebro, várias portas de entrada. Mas resista à tentação de
ligar tudo agora. Cada canal é mais uma coisa que pode quebrar, e o valor real está nas
Fases 5 a 7.
