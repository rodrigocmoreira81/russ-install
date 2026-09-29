# Módulo A3 — Operação blindada

**Quando:** logo depois da Fase 9, para quem vai depender do agente no dia a dia (e sempre no
[modo cliente](../CLIENTE.md)) · **Tempo:** ~60 min · **Portão:** você derruba o agente de
propósito e o alerta chega no Telegram em até 15 minutos, sem o agente estar vivo

> **Claude:** a Fase 9 ensina a consertar quando ela *percebe* que quebrou. Este módulo é sobre
> ela **não precisar perceber**. Tudo aqui saiu de quedas reais de um agente em produção. Conte
> as histórias: elas convencem mais que a regra.

---

## Nivelamento (60 segundos)

O modo de falha de um agente pessoal é o **silêncio**. Ele não dá erro na tela de ninguém, só
para de mandar o brief da manhã, e rotina silenciosa que quebrou parece rotina que não tinha
nada a dizer. Na queda real que originou este módulo, o agente ficou **3h20 mudo**, e quem
percebeu foi o dono, não o sistema. Numa segunda queda, **tudo parecia verde**: serviço
`active`, `auth status` dizendo *logged in*, nenhum erro gravado. O token tinha simplesmente
vencido.

Três camadas resolvem: **detectar**, **renovar antes de vencer** e **atualizar com caminho de volta**.

---

## Passo 1 — Watchdog fora do agente

Um vigia que roda no **crontab do Linux**, não no cron do Hermes. Se o gateway morrer, o cron do
Hermes morre junto; o crontab, não.

```bash
scp templates/scripts/agent-watchdog.sh meu-agente:~/.hermes/scripts/
ssh meu-agente 'chmod +x ~/.hermes/scripts/agent-watchdog.sh'
# teste a seco, sem enviar nada:
ssh meu-agente 'WATCHDOG_CHAT=ID_DELA WATCHDOG_DRYRUN=1 ~/.hermes/scripts/agent-watchdog.sh'
# crontab -e na VPS:
#   */15 * * * * WATCHDOG_CHAT=ID_DELA ~/.hermes/scripts/agent-watchdog.sh
```

O que ele olha:
- serviços `hermes-gateway*` fora do ar;
- `HTTP 401` no log dos últimos 20 minutos (ignorando o restart, quando o processo velho morre
  com 401 por SIGTERM);
- validade do token OAuth do Codex, se ela usar assinatura ChatGPT (avisa com 24 h de antecedência).

Anti-ruído embutido: só fala **na mudança** de estado (caiu / voltou), repete no máximo a cada
6 h e manda "recuperado" quando volta. Se o `hermes send` falhar, cai para a API do Telegram
direto, porque um watchdog que depende do que ele vigia não vigia nada.

---

## Passo 2 — "Logged in" não é saúde

Ensine isto com todas as letras: `hermes auth status` só confere se **existe** uma entrada no
arquivo. Os sinais de verdade são:

1. `journalctl --user -u hermes-gateway --since "30 min ago" | grep 'HTTP 401'`
2. `last_auth_error` dentro de `~/.hermes/auth.json`
3. uma chamada real: `hermes -z "responda só OK"`

E três armadilhas que já derrubaram agente em produção:

- **Assinatura via OAuth (ChatGPT/Codex):** o token de acesso dura ~10 dias, e em algumas versões
  o Hermes **não renovou sozinho**. Confirme na versão dela: anote a data de validade no
  `ESTADO.md` e veja se ela muda sozinha na semana seguinte. Se não mudar, agende a renovação
  (refresh token) no crontab **antes** do vencimento. Numa queda, a ordem é **renovar primeiro**
  e só refazer o login (device code: `hermes auth add openai-codex`) se a renovação falhar.
- **Nunca** "limpe" o pool com `hermes auth remove`: ele pode apagar o bloco inteiro do provedor
  e marcar a origem como suprimida, recriando exatamente o estado de queda. Edite o JSON com
  backup, ou refaça o login.
- **Crons de profiles diferentes no mesmo minuto** disputam a renovação do mesmo token, e o
  provedor pode revogar a família inteira (`refresh_token_reused`). Espalhe os minutos desde o
  primeiro dia (`:07`, `:13`, `:22`…), nunca tudo em `:00`.

---

## Passo 3 — Fallback: decisão consciente, não padrão

A Fase 3 oferece configurar um modelo reserva. Aqui entra o outro lado: **fallback transforma
queda em degradação silenciosa.** O agente continua respondendo com outro modelo, talvez pior
e mais caro, e ninguém descobre que o principal caiu.

As duas escolhas são defensáveis. O que não é defensável é **nenhuma das duas**:

| Escolha | Obrigatório junto |
|---|---|
| Com fallback | Um alerta quando o fallback for usado (olhe `hermes insights` semanalmente) |
| Sem fallback (`fallback_providers: []`) | O watchdog do Passo 1 |

---

## Passo 4 — Atualizar com caminho de volta

`hermes update` funciona, mas não é o caminho de volta que a Fase 9 cobra. Os hábitos:

```bash
hermes update --check     # tem versão nova?
hermes update --plan      # o que vai reiniciar, sem mudar nada
hermes backup -q -l pre-update    # snapshot rápido de config, estado, .env, auth e cron
hermes update
```

E a regra que custou 15 horas de agente fora do ar: **verificar com janela de estabilidade, não
com uma amostra.** Depois do update, confira o serviço de novo 90 segundos depois, não 8 s. Um
gateway que sobe e morre em 10 s passa numa checagem única.

Mais duas lições de upgrade:
- No rollback, use `restart`, **não** `start`. Com `start` num serviço que já estava de pé, o
  processo velho continua rodando o código antigo enquanto o disco tem o novo, e as rotinas
  quebram de formas estranhas.
- Sinal clássico desse desencontro: traceback apontando para uma linha que, no disco, é
  comentário.

Quem quiser automatizar: um script que fixa a versão em **tag** (não `main`), cria uma tag de
rollback antes, verifica com a janela acima e volta sozinho se falhar. Mudança de versão
**minor/major** pede aprovação humana; **patch** pode ir sozinho.

---

## Passo 5 — Pequenas proteções que se pagam

- **`cron succeeded` não quer dizer entregue.** Confira no canal de destino pelo menos uma vez
  por rotina nova. Já houve rotina "com sucesso" por semanas sem uma mensagem chegar.
- **Rotina mecânica é `--no-agent --script`.** Sem modelo: não custa, não renova token e não
  improvisa.
- **Auditoria de skills das rotinas.** "A skill existe" não quer dizer "a skill carrega". Uma
  rotina diária `--no-agent` que confere se toda skill citada por um cron ativo resolve, e só
  fala quando o conjunto de falhas muda, pega isso cedo. `hermes cron doctor` ajuda no
  diagnóstico manual.
- **Versione `~/.hermes/scripts/`** num repo privado ou dentro do cérebro (sem segredos). Em
  produção, os `.bak` soltos eram a única forma de desfazer uma mudança.
- **Conteúdo grande vai por stdin, nunca por argumento.** Argumento gigante estoura o limite
  do sistema (`E2BIG`, exit 126), e o script morre sem mensagem clara.
- **Slack com vários agentes: um app por agente**, desde o primeiro dia. Compartilhar um app
  obriga a gambiarras de token, e `platforms.slack.enabled: false` num profile fez a rotina
  reportar sucesso **sem entregar nada**.

---

## PORTÃO

1. `systemctl --user stop hermes-gateway.service` de propósito → o alerta chega no Telegram em
   até 15 min → `reset-failed` + `start` → chega o "recuperado" ✅
2. A validade do token (se OAuth) e o plano de renovação estão no `ESTADO.md` ✅
3. A escolha de fallback está registrada, com o motivo ✅
4. Um `hermes backup -q` existe e ela sabe onde está ✅

Avise antes do passo 1: o agente fica fora do ar por alguns minutos.
