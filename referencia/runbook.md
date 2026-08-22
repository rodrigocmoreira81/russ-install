# Runbook — quando quebra

> **Claude:** vá direto ao sintoma. Não leia o arquivo inteiro.
> Ordem sempre: **ler o log antes de mexer.** Metade dos problemas se resolve lendo a
> mensagem de erro de verdade em vez de adivinhar.

**Os três comandos de primeiro diagnóstico:**

```bash
export XDG_RUNTIME_DIR=/run/user/0
systemctl --user status hermes-gateway.service    # está no ar?
journalctl --user -u hermes-gateway -n 50         # o que disse antes de morrer?
hermes doctor                                      # o que está torto?
```

---

## SSH não conecta

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `Permission denied (publickey)` | Chave errada ou não instalada | `ssh -v meu-agente` e veja qual chave ele tenta. Confira o `IdentityFile` no `~/.ssh/config`. |
| `Connection refused` | VPS desligada ou ainda bootando | Painel do provedor: a máquina está ligada? Espere 60s após boot. |
| `Connection timed out` | IP errado ou firewall | Confirme o IP no painel. Teste `ping`. |
| `Host key verification failed` | VPS reinstalada, identidade mudou | `ssh-keygen -R <IP>` e conecte de novo, aceitando a nova. |
| Pede senha depois de ter desligado senha | Chave não chegou ao servidor | Use o **console web do provedor** para entrar e conferir `~/.ssh/authorized_keys`. |

> Se travar de vez: todo provedor tem console de emergência no painel, que funciona sem SSH.
> **Ninguém fica trancado para fora da própria VPS.** Diga isso — tira o pânico.

---

## Gateway não sobe / morre sozinho

**Comando não encontrado:**
```bash
systemctl status hermes-gateway          # "could not be found"
```
→ Faltou o escopo de usuário. É `systemctl --user`, com `XDG_RUNTIME_DIR=/run/user/0`.
Não é que não esteja instalado.

**Não volta depois de reboot:**
```bash
loginctl show-user root | grep Linger     # tem que dizer Linger=yes
loginctl enable-linger root
```
→ Causa nº 1 de "funcionava e parou". Ver Fase 2, Passo 4.

**Fica em `failed` depois de um `stop`:**
```bash
systemctl --user reset-failed hermes-gateway.service
systemctl --user start hermes-gateway.service
```
→ Normal: a política de restart marca como falha um SIGTERM. Precisa do `reset-failed`
**antes** do `start`, senão o start é ignorado.

**`hermes gateway restart` fica pendurado:**
Com o serviço em estado `failed`, ele tenta um encerramento gentil por **até 30 minutos**
antes de forçar. Não espere — use o systemd direto:
```bash
export XDG_RUNTIME_DIR=/run/user/0
systemctl --user reset-failed hermes-gateway.service
systemctl --user restart hermes-gateway.service
```

**Sobe e morre alguns segundos depois:**
Não confie em amostrar uma vez — observe por ~90 segundos:
```bash
journalctl --user -u hermes-gateway -f
```
→ Quase sempre é config quebrada ou credencial expirada. O log diz. Leia até o fim.

---

## Agente não responde (mas o serviço está no ar)

| Sintoma | Causa | Solução |
|---|---|---|
| Erro de autenticação nos logs | Chave expirada/revogada | `hermes auth status`; gere nova chave no painel do provedor |
| `rate limit` / `quota exceeded` | Estourou cota | Espere, ou troque de modelo; configure `hermes fallback` |
| `NoneType is not iterable` | Bug conhecido de SDK do provedor | Anote a versão, veja issues do Hermes; `hermes update` costuma resolver |
| Responde vazio ou trava | Contexto estourado | `/new` no Telegram; se resolver, a memória está inchada (ver abaixo) |
| Sem erro, sem resposta | Modelo não configurado | `hermes model` e confirme |

Teste isolando o canal — se responder aqui, o problema é o Telegram, não o agente:
```bash
hermes -z "responda apenas OK"
```

---

## Telegram não responde

1. **Gateway no ar?** `hermes gateway status`
2. **Token certo?** `hermes gateway setup` e reconfigure. Se suspeitar de vazamento:
   `/revoke` no BotFather e gere outro.
3. **Ela está na lista de permitidos?** Causa mais comum. O log mostra a mensagem chegando
   e sendo recusada — repare que o silêncio é proposital.
4. **Bot certo?** Fácil ter criado dois no BotFather e estar falando com o errado.
5. Logs ao vivo enquanto ela manda a mensagem:
   ```bash
   journalctl --user -u hermes-gateway -f
   ```
   Se **nada** aparece no log, a mensagem não chega ao servidor: token ou bot errado.
   Se aparece e não responde: é modelo ou permissão.

---

## `hermes: command not found` (logo após instalar)

O instalador foi interrompido perto do fim (ele baixa um Chromium de ~167 MB). Está tudo
instalado, só falta o atalho:
```bash
ln -sf /usr/local/lib/hermes-agent/venv/bin/hermes /usr/local/bin/hermes
```
A pasta é `venv`, não `.venv`. Se nem a pasta existir, rode o instalador de novo — e antes
disso `apt-get install -y libatomic1`, que falta na imagem do Ubuntu 24.04 e mata o
instalador com `libatomic.so.1`.

---

## `invalid choice: 'usage'`

`hermes usage` não existe mais. Use `hermes insights --days 7` (consumo) e `hermes status`
(modelo e provedor ativos).

---

## Erro 401 / "token is invalid" logo depois de colar a chave

Antes de culpar a credencial, **meça o que ficou salvo**. Colar chave longa num prompt
através de SSH trunca em silêncio:
```bash
grep -m1 '^ANTHROPIC\|^OPENAI' ~/.hermes/.env | cut -d= -f2- | tr -d '[:space:]' | wc -c
```
Se vier bem menor que o original, é truncamento — grave direto no `.env`, sem o prompt.

Token do Telegram tem armadilha parecida: copiado de print/foto, o reconhecimento de texto
troca caracteres parecidos (`0` → `ø`) e o log fala em *"lookalike Unicode glyphs"*.
Valide **no Linux** (o `grep` do macOS aprova não-ASCII):
```bash
grep -m1 '^TELEGRAM' ~/.hermes/.env | cut -d= -f2- | tr -d '[:space:]' \
  | grep -qE '^[0-9]{8,12}:[A-Za-z0-9_-]{30,40}$' && echo OK || echo CORROMPIDO
```

---

## "Quem é você?" → ele responde que é o Claude Code

Ele não está lendo o cérebro. **Não é o `AGENTS.md`** — é o diretório de trabalho:
```bash
hermes config get terminal.cwd      # se devolver ".", é isto
hermes config set terminal.cwd /root/.hermes/workspace
```
A chave é `terminal.cwd`. `terminal.working_dir` é aceita, salva e ignorada.

---

## Diz "anotado!" mas não aparece arquivo nem commit

A memória nativa grava em `~/.hermes/memories/`, fora do repositório do cérebro. Ligue os
dois com symlinks — ver Fase 5, Passo 7. Confira:
```bash
ls -l ~/.hermes/memories/*.md    # têm que ser atalhos (->), não arquivos
```

---

## Agente não lembra

| Sintoma | Causa | Solução |
|---|---|---|
| Esquece tudo em sessão nova | **Primeiro suspeito:** `terminal.cwd` em `"."` — ele nem está no cérebro | Ver *"Quem é você?"* acima. Só depois revise o `AGENTS.md` (Fase 5, Passo 4) |
| Confirma "anotado" e nada aparece | Memória nativa fora do repo | Ver *"Diz 'anotado!'"* acima — symlinks da Fase 5, Passo 7 |
| "Anota isso" vira lembrete agendado | Ele não carregou o `AGENTS.md` certo | Mesma causa do `terminal.cwd`; resolve junto |
| Lembra na conversa, esquece depois | Não está **escrevendo** | Combine o gatilho explícito ("anota isso") e registre no `AGENTS.md` |
| Lembra coisa errada/velha | Memória desatualizada | Abra o arquivo e edite. É texto — essa é a graça |
| Memória não chega ao GitHub | `brain-sync.sh` parado | `crontab -l`; rode o script à mão e leia o erro |

```bash
cd ~/.hermes/workspace && git log --oneline -5 && git status --short
```
Commit mais recente com dias de atraso = sync morto.

---

## Cron não roda

```bash
hermes cron list --all      # está pausado?
hermes cron runs            # rodou e falhou, ou nem tentou?
hermes cron status          # o agendador está vivo?
```

| Sintoma | Causa |
|---|---|
| Chega no horário errado | Fuso do servidor ≠ fuso dela. `timedatectl` (Fase 7, Passo 1) |
| Nunca chega | Job pausado, ou `--deliver` com ID errado |
| Rodou mas não entregou | Prompt retornou `[SILENT]` — pode ser o comportamento correto! |
| Falha com erro de modelo | Mesmo diagnóstico de *"Agente não responde"* |

> Antes de declarar defeito: **confirme que não é `[SILENT]` funcionando.**
> Rotina silenciosa que quebrou parece rotina silenciosa sem novidade.

---

## Git / cérebro

**Push rejeitado:**
```bash
cd ~/.hermes/workspace && git pull --rebase origin main && git push
```

**`Permission denied` no push:** a deploy key não tem escrita. GitHub → repo → Settings →
Deploy keys → **Allow write access**. Precisa recriar a chave marcando a opção.

**Conflito de rebase:** abra o arquivo, procure `<<<<<<<`, resolva, `git add`,
`git rebase --continue`. O próprio Claude resolve em dois minutos — é para isso que ele existe.

**Vazou um segredo no commit:** trate a chave como comprometida — **regenere primeiro**,
limpe o histórico depois. A ordem importa: histórico limpo com chave viva ainda é vazamento.

---

## Disco ou memória cheios

```bash
df -h /            # disco
free -h            # RAM
du -sh ~/.hermes/* | sort -rh | head -10
journalctl --user --vacuum-time=7d      # logs costumam ser o vilão
```

Se a RAM vive no talo, é sinal de VPS pequena demais para o número de gateways. Ver Fase 1
(plano) ou Fase 8 (menos sub-agentes).

---

## Nada disso resolveu

Peça ao Claude Code, com contexto de verdade:

> *"Meu agente Hermes parou de responder. Conecta em `ssh meu-agente`, roda
> `hermes doctor` e `journalctl --user -u hermes-gateway -n 100`, e me diz o que
> está acontecendo. O runbook está em `referencia/runbook.md`."*

E, se for bug de verdade: [issues do Hermes](https://github.com/NousResearch/hermes-agent/issues) —
com a saída de `hermes dump`, que reúne o diagnóstico para suporte.
