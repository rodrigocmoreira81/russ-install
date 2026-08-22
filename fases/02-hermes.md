# Fase 2 — O corpo (Hermes)

**Tempo:** ~30 min · **Portão:** serviço volta sozinho depois de um `reboot`

> **Claude:** boa notícia pra dar a ela: a instalação em si é um comando. A parte que
> importa nesta fase não é instalar — é garantir que o agente **sobreviva a um reboot**.
> Essa distinção é o conteúdo real da fase. Não a trate como detalhe técnico.

---

## Nivelamento (60 segundos)

O **Hermes Agent** é o programa que transforma um modelo de IA em um agente: ele guarda as
conversas, executa ferramentas, fala com Telegram e roda tarefas agendadas. É open source,
da NousResearch, e é o mesmo motor que roda o Russ.

O conceito novo aqui é **serviço** (ou *daemon*). Quando você roda um programa no terminal,
ele morre quando você fecha o terminal. Um serviço é diferente: o sistema operacional toma
conta dele, liga sozinho quando a máquina liga e reinicia se cair. É a diferença entre um
funcionário que só trabalha enquanto você olha e um que tem a chave da loja.

---

## Passo 1 — Instalar

Na VPS (`ssh meu-agente`), **primeiro uma dependência que falta na imagem do Ubuntu 24.04**:

```bash
apt-get install -y libatomic1
```

> Sem isso o instalador morre no meio com `node: error while loading shared libraries:
> libatomic.so.1`, trava em *"Extracting to ~/.hermes/node/…"* e a conexão SSH cai junto —
> parece que a VPS travou. Trinta segundos aqui poupam uma hora de susto.

Agora o instalador:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc
hermes --version
```

> **Se o `hermes --version` disser "command not found"**, o instalador provavelmente foi
> interrompido no fim (ele baixa um Chromium de ~167 MB e a queda ali é comum). Está tudo
> instalado, só falta o atalho:
> ```bash
> ln -sf /usr/local/lib/hermes-agent/venv/bin/hermes /usr/local/bin/hermes
> ```
> Repare: a pasta é `venv`, não `.venv`.
>
> **Você (Claude) pode não conseguir executar o `curl | bash`** — o classificador de
> segurança do Claude Code costuma barrar. Não insista: peça para **ela** colar o comando
> no terminal. É o comportamento correto do classificador, e vale explicar por quê.

O instalador traz tudo junto — Python 3.11, `uv`, Node.js, `ripgrep`, `ffmpeg`. Leva alguns
minutos. Se ela perguntar por que demora: são umas centenas de megas de dependências, é normal.

> Esta é a **única** vez que este material manda executar um script vindo da internet, e é a
> fonte oficial do projeto. Vale dizer isso a ela em voz alta — é uma boa hora pra ensinar
> que `curl | bash` só se faz com fonte que se confia, e que ela deveria desconfiar de
> qualquer tutorial que peça isso de um link aleatório.

---

## Passo 2 — Wizard de configuração

```bash
hermes setup
```

O wizard pergunta modelo, ferramentas e workspace. **A escolha do modelo é a Fase 3** — se
ele pedir agora e ela ainda não decidiu, pode aceitar o padrão e trocar depois com
`hermes model`. Não trave aqui.

Workspace: aceite o padrão (`~/.hermes/workspace`). É onde o cérebro vai morar na Fase 5.

**Depois do wizard, fixe o diretório de trabalho — isto não é opcional:**

```bash
hermes config set terminal.cwd /root/.hermes/workspace
hermes config get terminal.cwd     # tem que devolver o caminho, não "."
```

> **Por que isso importa tanto.** Se ficar em `"."`, o agente roda fora do workspace e
> acaba carregando o `AGENTS.md` do **código-fonte do Hermes** em vez do cérebro dela.
> O sintoma aparece só lá na Fase 5, disfarçado: perguntada "quem é você?", a criatura
> responde *"sou o Claude Code rodando como agente Hermes"*, ignora o `SOUL.md` e jura
> que não tem regra nenhuma. Parece problema de memória; é problema de diretório.
>
> A chave é **`terminal.cwd`**. Existe uma `terminal.working_dir` que o Hermes aceita,
> salva — e ignora. Se você usar essa, tudo parece certo e nada funciona.

---

## Passo 3 — Instalar o serviço do gateway

```bash
hermes gateway install
hermes gateway status
```

Isso registra o Hermes como serviço do systemd. **Ainda não vai ter canal nenhum conectado** —
o Telegram é a Fase 4. Aqui só garantimos que a estrutura de serviço existe.

---

## Passo 4 — O lingering (não pule isto)

Aqui está a pegadinha que derruba instalações inteiras, e ela não está na documentação oficial.

O Hermes instala o serviço no **escopo do usuário** (`systemd --user`), não no escopo do
sistema. Serviços de usuário, por padrão, **morrem quando o usuário faz logout** — e um
reboot é um logout. Resultado: a pessoa instala tudo, testa, funciona, reinicia a máquina
uma semana depois e o agente simplesmente não volta. Sem erro, sem aviso.

A solução é uma linha:

```bash
loginctl enable-linger root
loginctl show-user root | grep Linger
```

Tem que responder `Linger=yes`. Isso diz ao sistema: *mantenha os serviços deste usuário
rodando mesmo sem sessão aberta.*

> **Explique o porquê, não só o comando.** Este é o tipo de coisa que, quando quebrar daqui
> a três meses, ela só vai resolver sozinha se tiver entendido agora.

Consequência prática, que vale mencionar: para operar esses serviços, os comandos precisam
da flag `--user` e da variável `XDG_RUNTIME_DIR`. `systemctl status hermes-gateway` sem
`--user` responde *"could not be found"* e faz a pessoa achar que nada foi instalado:

```bash
export XDG_RUNTIME_DIR=/run/user/0
systemctl --user status hermes-gateway.service
```

Sugira colocar o `export` no `~/.bashrc` dela pra não esquecer nunca mais:

```bash
echo 'export XDG_RUNTIME_DIR=/run/user/0' >> ~/.bashrc
```

---

## Passo 5 — Diagnóstico

```bash
hermes doctor
```

Ele varre a instalação e aponta problemas. Leia a saída **com** ela e explique cada aviso —
avisos amarelos costumam ser normais nesta altura (canal não configurado, modelo não
escolhido). Vermelho, não: resolva antes de seguir.

---

## PORTÃO

O teste de verdade é o reboot. Avise que a VPS vai sumir por ~40 segundos:

```bash
ssh meu-agente 'reboot'
# espere ~40s
ssh meu-agente 'export XDG_RUNTIME_DIR=/run/user/0; systemctl --user is-active hermes-gateway.service; hermes --version'
```

Passou se, **depois do reboot**, o serviço responde `active` sem ninguém ter ligado nada.

Se responder `inactive` ou `failed` → o lingering não pegou. Volte ao Passo 4.
Outros sintomas → [`referencia/runbook.md`](../referencia/runbook.md).

Atualize o `ESTADO.md`: versão do Hermes instalada, data, lingering confirmado.

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Por que serviço de usuário e não do sistema?**
Serviços de usuário rodam com as permissões e o ambiente da pessoa — o que importa aqui,
porque o agente lê arquivos de configuração e chaves que vivem na home. A alternativa
(serviço de sistema) exigiria configurar ambiente e permissões na mão. O preço dessa
escolha é exatamente o lingering.

**O que é o systemd, afinal?**
É o gerente de processos do Linux moderno: decide o que sobe no boot, reinicia o que cai,
guarda os logs. Quando você diz "instalar como serviço", é com ele que está falando.
Para ver os logs do agente: `journalctl --user -u hermes-gateway -n 50 -f`
(o `-f` deixa a saída rolando ao vivo, útil pra ver o que acontece quando você manda uma
mensagem no Telegram).

**Por que o Hermes e não outro framework?**
Porque ele já traz junto o que um agente pessoal precisa e que dá muito trabalho montar
sozinho: gateway de mensagens (Telegram, Discord, Slack, WhatsApp), agendamento, sistema de
skills, memória, MCP e sub-agentes. É open source, então nada aqui é uma caixa-preta.
O método deste material — segundo cérebro em Git, fases, portões — funcionaria sobre outro
motor; o Hermes é o que dá menos trabalho hoje.

**Como atualizar depois?**
`hermes update`. Mas leia a Fase 9 antes de criar o hábito: atualização automática sem teste
de verificação já derrubou agente em produção. O jeito certo é atualizar, rodar `hermes doctor`,
e ter um caminho de volta.
