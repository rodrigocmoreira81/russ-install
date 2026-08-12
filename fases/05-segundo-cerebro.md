# Fase 5 — A memória (segundo cérebro em GitHub)

**Tempo:** ~60 min · **Portão:** ela conta um fato hoje, o agente lembra amanhã em sessão nova

> **Claude:** esta é a fase que separa "instalei um bot" de "tenho um agente". É a mais longa
> e a mais valiosa. Não corra. Se a sessão estiver ficando longa, é melhor parar antes desta
> fase e começá-la com energia do que atravessá-la cansado.

---

## Nivelamento (90 segundos — vale o tempo extra)

Até aqui, cada conversa nova nasce em branco. O agente é competente e amnésico.

**Segundo cérebro** é um conjunto de arquivos de texto num repositório Git privado, que o
agente lê no começo de cada conversa e escreve ao longo dela. Não é banco de dados, não é
mágica: é uma pasta de arquivos `.md` versionada.

Três motivos para ser assim, e não um sistema "inteligente" de memória:

- **Você lê.** Abre o arquivo e vê exatamente o que ele sabe sobre você.
- **Você corrige.** Entendeu errado? Edita a linha. Sem prompt, sem reza.
- **Você tem histórico.** Git guarda cada mudança com data — dá pra perguntar "quando ele
  passou a achar isso?" e ter resposta.

E um quarto, menos óbvio: **é portátil.** Se o Hermes sumir amanhã, ou se ela quiser trocar
de modelo, de provedor ou de servidor, o cérebro vai junto. O agente é substituível; a memória
não.

A memória é organizada em **camadas**, porque nem tudo precisa ser lido toda vez — e ler tudo
sempre custa dinheiro (Fase 3):

| Camada | Arquivo | Quando é lido |
|---|---|---|
| Identidade | `SOUL.md` | Sempre. Quem ele é. |
| Usuário | `USER.md` | Sempre. Quem ela é. |
| Startup | `AGENTS.md` | Sempre. O que fazer ao acordar. |
| Diário | `memory/AAAA-MM-DD.md` | Hoje e ontem. O que aconteceu. |
| Curada | `memory/decisoes.md`, `projetos.md`, `licoes.md` | Quando o assunto pede. |

O `AGENTS.md` é a peça esperta: em vez de despejar tudo no contexto, ele é um **mapa** que
diz ao agente o que ler e quando. É o que mantém o custo sob controle conforme a memória cresce.

---

## Passo 1 — Criar o repositório

No GitHub, ela cria um repositório **privado** chamado `meu-cerebro` (ou o nome do agente).

> **Privado. Sempre.** Sem exceção, sem "depois eu fecho". Vai ter contexto pessoal, nome de
> cliente, detalhe de negócio. Se ela criar público por engano, o certo é **apagar e criar
> de novo** — repositório público, mesmo que fechado depois, já pode ter sido indexado.

Não inicialize com README — a VPS vai empurrar o conteúdo.

---

## Passo 2 — Deploy key (a VPS ganha acesso de escrita)

A VPS precisa escrever no repositório sem usar a senha do GitHub dela. A forma correta é uma
**deploy key**: um par de chaves que dá acesso a **um único repositório**. Se vazar, o estrago
é limitado a esse repo — diferente de um token pessoal, que abre a conta inteira.

Na VPS:

```bash
ssh-keygen -t ed25519 -C "cerebro-vps" -f ~/.ssh/cerebro_deploy -N ""
cat ~/.ssh/cerebro_deploy.pub
```

No GitHub: **Settings do repositório → Deploy keys → Add deploy key**.
Cole a chave pública e **marque "Allow write access"** (sem isso, o sync falha na hora do push
e o erro não é óbvio).

Depois, ainda na VPS, crie um apelido para o Git usar essa chave:

```bash
cat >> ~/.ssh/config <<'EOF'

Host github-cerebro
    HostName github.com
    User git
    IdentityFile ~/.ssh/cerebro_deploy
    IdentitiesOnly yes
EOF

ssh -T git@github-cerebro   # deve dizer "successfully authenticated" e negar shell — é o esperado
```

---

## Passo 3 — O `.gitignore` vem ANTES do primeiro commit

Não é ordem arbitrária. Arquivo que entra no histórico do Git **continua lá** mesmo depois de
apagado — remover de verdade dá trabalho e assusta. Faça certo na primeira vez:

```bash
cd ~/.hermes/workspace
cat > .gitignore <<'EOF'
# Credenciais — NUNCA versionar
.env
.env.*
*credentials*.json
*token*.json
auth.json
secrets/
*.pem
*.key

# Efêmero
tmp/
*.tmp
*.log
__pycache__/
*.pyc
.cache/

# Backups locais
*.bak
*.orig
EOF
```

Confira com ela o que **não** está sendo ignorado antes do primeiro commit:

```bash
git status --short | head -40
```

Se aparecer qualquer coisa com cara de chave, token ou credencial — pare e ajuste.

---

## Passo 4 — Escrever o cérebro inicial

Use `templates/` deste repositório como base, mas **não copie cru**. Preencha com o que ela
te contou na Fase 0 — é aqui que o curso deixa de ser genérico. Volte e releia as respostas
dela no `ESTADO.md` antes de escrever.

- **`SOUL.md`** — identidade e tom. Use a resposta dela sobre formal/informal e "pode discordar".
  Um `SOUL.md` genérico produz um agente genérico. Escreva com personalidade de verdade.
- **`USER.md`** — quem ela é. Use literalmente a resposta 3 da Fase 0: trabalho, com quem fala,
  como gosta que falem com ela, fuso horário.
- **`AGENTS.md`** — o checklist de startup: o que ler ao acordar, quando escrever memória,
  o que nunca fazer.
- **`memory/MAP.md`** — o índice: o que é cada arquivo e quando carregar.

Leia o `SOUL.md` e o `USER.md` **em voz alta** com ela antes de salvar. Ela vai querer corrigir
metade — e é exatamente isso que faz o agente virar dela.

---

## Passo 5 — Primeiro commit e push

```bash
cd ~/.hermes/workspace
git init -b main 2>/dev/null
git remote add origin git@github-cerebro:USUARIA/meu-cerebro.git
git add -A
git status --short          # ÚLTIMA conferida antes de gravar na pedra
git commit -m "cérebro inicial"
git push -u origin main
```

Peça pra ela **abrir o GitHub no navegador e olhar**. Ver os arquivos lá é o momento em que a
ficha cai sobre o que "memória versionada" significa.

---

## Passo 6 — Sync automático

Sem automação, o cérebro só chega ao GitHub quando alguém lembra — ou seja, nunca. Instale o
`brain-sync.sh` (está em `templates/scripts/brain-sync.sh`):

```bash
mkdir -p ~/.hermes/scripts
# copie o template para ~/.hermes/scripts/brain-sync.sh, ajustando o caminho do workspace
chmod +x ~/.hermes/scripts/brain-sync.sh
~/.hermes/scripts/brain-sync.sh      # teste manual primeiro
```

Rodou limpo? Então agende de hora em hora:

```bash
crontab -l 2>/dev/null | { cat; echo "0 * * * * /root/.hermes/scripts/brain-sync.sh"; } | crontab -
crontab -l
```

O script faz `pull --rebase` → `add` → `commit` → `push`. O pull vem primeiro de propósito:
se ela editar pelo GitHub ou pelo computador, as duas pontas convergem em vez de brigar.

---

## Passo 7 — Ensinar o agente a usar a memória

Ter os arquivos não basta — o agente precisa saber que deve lê-los e escrevê-los. Isso mora
no `AGENTS.md` (Passo 4) e vale reforçar na configuração:

```bash
hermes memory        # veja como o Hermes já trata memória
```

Combine uma convenção simples e diga a ela em palavras claras, porque é o que ela vai usar
todo dia: **quando ela disser "anota isso", o agente escreve no diário de hoje;
quando disser "isso é importante", vai para o arquivo curado que fizer sentido.**

---

## PORTÃO

O teste tem que atravessar o tempo — é o único jeito de provar que a memória é real:

1. **Hoje:** ela conta ao agente, pelo Telegram, um fato específico e verificável.
   *("Meu sócio se chama Pedro e a gente se fala às segundas.")* E pede: *"anota isso."*
2. Confira que gerou arquivo e chegou ao GitHub:
   ```bash
   ssh meu-agente 'cd ~/.hermes/workspace && git log --oneline -3 && ls memory/ | tail -3'
   ```
3. **Sessão nova:** ela manda `/new` no Telegram (contexto zerado) e pergunta
   *"o que você sabe sobre meu sócio?"*

Passou se ele responde certo **depois do `/new`**. Aí não é o histórico da conversa
respondendo — é a memória.

Se ele não lembrar, o problema quase sempre é o `AGENTS.md` não instruindo a leitura no
startup. → [`referencia/runbook.md`](../referencia/runbook.md), seção *"Agente não lembra"*.

Atualize o `ESTADO.md`: URL do repo, deploy key criada, sync agendado, portão passado.

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Por que não deixar o agente escrever o que ele quiser na memória?**
Porque memória sem curadoria vira lixo caro. Agente solto registra trivialidade, duplica fato
e se contradiz — e você paga por tudo isso em todo prompt. A disciplina que funciona: **diário
é livre, memória curada é deliberada.** Uma vez por semana, alguém (ela ou o agente, a pedido)
promove o que virou permanente e apaga o que não era.

**E se dois lados editarem ao mesmo tempo?**
O `pull --rebase` resolve a maioria. Conflito de verdade acontece e o script vai reclamar —
por isso ele registra log. Não é catástrofe: é um arquivo de texto com marcadores de conflito,
e o próprio Claude resolve em dois minutos.

**Dá pra ler esse cérebro do computador dela também?**
Dá, e é ótimo. Ela clona o repositório na máquina dela e o Claude Code passa a ter o mesmo
contexto que o agente. É assim que o Russ funciona: a VPS é a fonte autoritativa, o computador
é espelho de leitura. Deixe para depois que as Fases 6 e 7 estiverem no ar — uma coisa de cada vez.

**Isso não fica gigante com o tempo?**
Fica, e aí você precisa de duas coisas: **compactação** (arquivar diários velhos que já viraram
memória curada) e, mais tarde, **busca** em vez de leitura integral. Mas isso é problema para
o mês seis. Começar simples e complicar quando doer é a ordem certa — complicar antes de doer
é como a maioria dos projetos morre.
