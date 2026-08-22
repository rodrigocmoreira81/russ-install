# Fase 1 — O terreno (VPS)

**Tempo:** ~45 min · **Custo:** aqui começa a cobrança · **Portão:** `ssh meu-agente 'uptime'`

> **Claude:** esta é a fase que mais assusta e onde mais gente desiste. Motivo: a pessoa
> nunca comprou um servidor e tem medo de errar e gastar errado. Vá com calma, confirme
> o valor **antes** dela clicar em comprar, e celebre o primeiro login — é um momento real.

---

## Nivelamento (60 segundos)

**VPS** significa *Virtual Private Server*. Você aluga uma fatia de um computador grande num
data center, e essa fatia se comporta como um computador inteiro, só seu, ligado o tempo todo.
Você não recebe monitor nem mouse — você entra nele **pelo terminal**, digitando comandos.

**SSH** é o jeito de entrar. Pense num cadeado com duas peças: uma **chave privada**, que fica
só no computador dela e nunca sai de lá, e uma **chave pública**, que ela entrega ao servidor.
O servidor tranca a porta com a pública e só a privada abre. É por isso que isso é mais seguro
que senha: senha pode ser adivinhada por um robô tentando um milhão de vezes; chave, não.

> Diga isso explicitamente: **servidores na internet são varridos por robôs em minutos.**
> Não é paranoia, é rotina. Por isso a gente desliga login por senha logo de cara.

---

## Passo 1 — Escolher o provedor

<!-- LINK-AFILIADO: link de afiliado do Rodrigo. Não altere a URL (mexer nela quebra
     a atribuição). Único lugar no material — `grep -rn LINK-AFILIADO .` acha aqui. -->
**Recomendação: [Hostinger VPS](https://www.hostinger.com/br?REFERRALCODE=EB0RODRIGQDN)** — interface em português,
suporte em português, cobra em real e o preço é dos melhores da categoria. Para quem está
comprando o primeiro servidor da vida, isso importa mais do que qualquer benchmark.

Alternativas legítimas, se ela preferir: **DigitalOcean** e **Hetzner** (mais baratos, tudo
em inglês, cobrança em dólar/euro) ou **Contabo** (barato, suporte irregular). Qualquer VPS
com Ubuntu serve — nada aqui é específico da Hostinger.

> **Diga isto a ela, com todas as letras:** aquele link da Hostinger é de afiliado — se ela
> assinar por ele, o autor do material recebe uma comissão, sem custo a mais pra ela. A
> recomendação seria a mesma sem isso, e as alternativas acima estão aqui de verdade. Ela
> escolhe com a informação na mesa.

### Qual plano

| Plano | Serve? | Para quem |
|---|---|---|
| 1 vCPU / 4 GB | Funciona | Um agente, uso pessoal, sem enfeite. O mínimo real. |
| **2 vCPU / 8 GB** | **Recomendado** | Um agente + sobra pra crescer. É o ponto certo. |
| 4 vCPU / 16 GB | Só se já souber | Vários sub-agentes, dashboard, modelos locais. |

Referência concreta: o Russ roda **6 gateways simultâneos** (agente principal + 5
especializados) num 4 vCPU / 16 GB, usando ~9 GB. Um agente sozinho vive folgado em 8 GB.

**Sistema operacional: Ubuntu 24.04 LTS.** Sem painel de controle, sem CyberPanel, sem nada
extra — só o Ubuntu limpo. Se a Hostinger oferecer templates com painel, recuse.

> **Confirme o preço com ela antes de comprar.** Os valores mudam e promoção de primeiro ano
> costuma esconder renovação bem mais cara. Peça pra ela olhar **o preço da renovação**,
> não só o do primeiro pagamento. Planos anuais são bem mais baratos que mensais, mas só
> valem a pena se ela tiver certeza de que vai usar.

---

## Passo 2 — Criar a chave SSH

**Na máquina dela**, não na VPS. Rode:

```bash
ssh-keygen -t ed25519 -C "meu-agente" -f ~/.ssh/meu_agente
```

Quando pedir *passphrase*: explique que é uma senha que protege a própria chave, caso o
computador dela seja roubado. Recomende usar uma (o macOS e o Linux guardam no chaveiro e
não pedem toda hora). Se ela preferir vazio, tudo bem — registre a decisão.

Isso cria dois arquivos:
- `~/.ssh/meu_agente` — **a chave privada. Nunca sai daqui. Nunca é colada em lugar nenhum.**
- `~/.ssh/meu_agente.pub` — a pública, essa sim vai pro servidor.

Mostre o conteúdo da pública para ela colar no painel:

```bash
cat ~/.ssh/meu_agente.pub
```

---

## Passo 3 — Provisionar

No painel da Hostinger (ou equivalente):

1. Escolher o plano e a localização — **São Paulo/Brasil** se existir; senão, Leste dos EUA.
   Menor latência e menos dor de cabeça com fuso.
2. Sistema: **Ubuntu 24.04 LTS**, limpo.
3. **Colar a chave pública** no campo de SSH Key durante a criação. A Hostinger oferece isso
   no fluxo — use. Se ela já criou com senha, dá pra adicionar a chave depois com `ssh-copy-id`.
4. Anotar o **IP** que aparecer no fim.

---

## Passo 4 — Apelido SSH

Digitar `ssh root@148.230.x.x` toda vez é convite a erro. Crie um apelido em `~/.ssh/config`
**na máquina dela**:

```
Host meu-agente
    HostName SEU.IP.AQUI
    User root
    IdentityFile ~/.ssh/meu_agente
    ServerAliveInterval 60
```

A partir de agora, `ssh meu-agente` basta. (`ServerAliveInterval` evita que a conexão caia
sozinha quando ela ficar um tempo sem digitar.)

Se ela escolheu outro nome para o agente na Fase 0, use esse nome aqui — fica mais bonito e
ela lembra melhor.

---

## Passo 5 — Primeiro login e blindagem básica

```bash
ssh meu-agente
```

Na primeira vez vai perguntar sobre a autenticidade do host — explique que é o servidor se
apresentando pela primeira vez, e que responder `yes` grava a identidade dele. **Este é o
momento da virada:** ela está dentro de um computador que é dela, na nuvem. Marque isso.

Agora, três coisas de higiene, ainda na VPS:

```bash
# 1. Atualizar o sistema
apt update && apt upgrade -y

# 2. Fuso horário (troque se ela não estiver em SP)
timedatectl set-timezone America/Sao_Paulo

# 3. Desligar login por senha — só chave a partir de agora
cat > /etc/ssh/sshd_config.d/00-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF
sshd -t && systemctl restart ssh
```

> **Por que um arquivo novo e não editar o `sshd_config`?** Porque editar o principal
> **não funciona** nessas imagens de nuvem — e falha em silêncio, que é pior. O
> `sshd_config` faz `Include /etc/ssh/sshd_config.d/*.conf` lá em cima, e no sshd
> **o primeiro valor lido vence**. A imagem da Hostinger traz um
> `50-cloud-init.conf` com `PasswordAuthentication yes`, que é lido antes e ganha.
> Por isso o arquivo se chama `00-` — para ser lido antes de todos.

**Agora prove que funcionou**, em vez de acreditar:

```bash
# 1. o que o sshd REALMENTE está usando (não o que está escrito nos arquivos)
sshd -T | grep -iE '^passwordauthentication|^kbdinteractive'
# esperado: passwordauthentication no  /  kbdinteractiveauthentication no
```

E o teste de verdade, **da máquina dela**, forçando senha:

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no root@SEU.IP
# esperado: Permission denied (publickey).  Se PEDIR SENHA, não está blindado.
```

> **Cuidado:** confirme que o login por chave funciona **antes** de desligar a senha.
> Ela já entrou por chave nesta sessão, então está seguro — mas não feche a sessão atual
> até testar uma nova em outra aba. Se algo der errado, o painel da Hostinger tem console
> de emergência que funciona sem SSH. Diga isso a ela — tira o medo.

**Sobre o fuso:** muita gente deixa a VPS em UTC. Vale mencionar que isso volta a morder na
Fase 7, quando ela for agendar rotinas — deixar em horário de Brasília agora evita conta de
cabeça depois.

---

## PORTÃO

Rode **da máquina dela**, com a sessão SSH anterior fechada:

```bash
ssh meu-agente 'uptime && lsb_release -d && timedatectl | grep "Time zone"'
```

Passou se: responde sem pedir senha, mostra Ubuntu 24.04 e o fuso correto.

Falhou? → [`referencia/runbook.md`](../referencia/runbook.md), seção *"SSH não conecta"*.

Atualize o `ESTADO.md`: provedor, plano, IP, apelido SSH, data. **Nunca a chave privada.**

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Por que `root` e não um usuário normal?**
Boa pergunta e a resposta honesta é: em produção séria, você criaria um usuário sem privilégio
e usaria `sudo`. Aqui a gente usa root porque é uma máquina de uso único, pessoal, e a
complexidade extra atrapalha mais do que protege neste contexto. O Hermes vai instalar
serviços no escopo do usuário de qualquer forma. Se ela quiser fazer do jeito rigoroso,
o material funciona igual — só trocar o `User` no `~/.ssh/config` e prefixar `sudo`.

**Por que não Docker / Kubernetes / serverless?**
Porque um agente pessoal é um processo de longa duração que precisa de estado no disco e de
estar sempre no ar. VPS é o encaixe mais simples e mais barato para isso. Serverless cobraria
mais e complicaria a memória; Kubernetes seria usar um caminhão pra levar uma sacola.

**O que é `ed25519`?**
O tipo de criptografia da chave. É o padrão moderno: chaves menores, mais rápidas e mais
seguras que o RSA antigo. Se ela vir tutoriais mandando usar `-t rsa -b 4096`, são tutoriais
velhos — funciona, mas não é mais o recomendado.

**E se ela quiser cancelar depois?**
VPS se cancela pelo painel e a cobrança para. Antes de cancelar, ela precisa do backup do
cérebro — que é justamente o que a Fase 9 ensina. Vale dizer isso agora: **o valor mora no
cérebro, não no servidor.** Servidor é descartável e substituível em uma hora.
