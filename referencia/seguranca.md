# Segurança — leia antes de conectar sua vida

> **Claude:** esta página é **parada obrigatória** antes de conectar WhatsApp, e-mail, agenda
> ou qualquer coisa privada. Leia **com** ela, não para ela. Não dramatize e não minimize:
> o objetivo é uma decisão informada, não medo nem falsa tranquilidade.

---

## O que você está fazendo, dito sem eufemismo

Você está dando a um programa acesso a partes privadas da sua vida, para que ele aja em seu
nome, às vezes sem você olhando.

Isso é legítimo e é exatamente o ponto de ter um agente. Mas merece as mesmas perguntas que
você faria antes de dar a chave de casa a alguém: **o que essa pessoa consegue ver? o que ela
consegue fazer sozinha? o que acontece se ela errar? e se alguém se passar por ela?**

---

## As quatro regras que não se quebram

**1. Chave nunca passa por chat.**
Nem no Claude, nem no WhatsApp, nem em e-mail para você mesmo. Chaves vão direto para o
arquivo `.env` na VPS. Se você colar uma chave num chat sem querer, **considere aquela chave
vazada e gere outra**. Leva dez segundos e é a atitude certa — sem constrangimento.

**2. O repositório do cérebro é privado. Sempre.**
Sem "depois eu fecho". Repositório público, mesmo que fechado minutos depois, pode já ter
sido clonado e indexado. Se acontecer: apague, crie outro, e troque toda credencial que
estava lá.

**3. `.gitignore` antes do primeiro commit.**
Arquivo que entra no histórico do Git continua lá depois de apagado. Fazer certo na primeira
vez custa um minuto; consertar depois é trabalhoso e assusta.

**4. Lista de permissão em todo canal.**
Um bot de Telegram é encontrável por qualquer um que saiba o nome. Sem lista de permissão,
qualquer estranho conversa com um agente que conhece sua vida e gasta seu dinheiro.

---

## Antes de conectar cada coisa

Para cada integração, responda as três perguntas **antes** de configurar:

| | Pergunta |
|---|---|
| **Ver** | Que dados isso deixa o agente ler? |
| **Fazer** | Ele pode escrever/enviar/apagar, ou só ler? |
| **Errar** | Qual o pior erro possível, e ele é reversível? |

### E-mail
- **Ver:** tudo. Inclusive o que você esqueceu que estava lá.
- **Fazer:** o risco real é **enviar**. Um e-mail errado não volta.
- **Recomendação:** comece **só leitura**. Se quiser envio, faça o agente criar **rascunho** e
  você aperta enviar. Vale por meses, não por semanas.

### Agenda
- **Ver:** compromissos, participantes, links de reunião.
- **Fazer:** criar e apagar eventos. Apagar é o perigoso.
- **Recomendação:** leitura + criação, sem exclusão. Baixo risco e alto valor.

### WhatsApp — leia isto inteiro antes de ligar

- **Ver:** suas conversas — incluindo as de terceiros que não escolheram isso.
- **Fazer:** enviar em seu nome. Alto risco: mensagem errada tem custo social real.
- **Riscos extras:** não existe API oficial gratuita. As bibliotecas não oficiais violam os
  termos e podem **banir seu número**. Use um número secundário se for seguir.
- **Recomendação:** trate como **fonte de dados** (ler, resumir, extrair tarefa), não como
  canal de envio. É o que o Russ faz. E pense na privacidade de quem conversa com você.

**Três coisas que já aconteceram com quem seguiu este material** — não são hipóteses:

**1. Avisos internos do sistema vazam no chat do cliente.** Quando uma sessão do agente
nasce a partir de uma conversa de WhatsApp, os avisos de runtime vão para **aquela**
conversa. Um sócio recebeu, vindas do número do dono, mensagens como *"Interrupting current
task (iteration 2/500)"* e *"Self-improvement review: Memory updated"* — em inglês, do nada.
Quem está do outro lado descobre assim que existe um agente lendo a conversa.
**Instrução em skill ou no `SOUL.md` não resolve isto** — o aviso vem do runtime, abaixo do
modelo. A única defesa que funciona hoje é a mensagem **nunca criar sessão**: deixe a
allowlist do WhatsApp **vazia**, para que mensagem de fora seja barrada antes de virar
conversa. O agente fica sem boca — e é exatamente isso que você quer no papel de secretário.

**2. "Enviado" não quer dizer "entregue".** O envio pode responder `sent` e a mensagem não
chegar a lugar nenhum — ela fica numa fila que morre no próximo restart. Nunca confie no
retorno: confirme com quem deveria ter recebido.

**3. Número brasileiro antigo não tem o 9 no endereço interno.** Contas criadas antes do
nono dígito mantêm o endereço com 12 dígitos (`553187534200`), e não o número que você
disca (`5531 9 8753-4200`). Mandar para o número discável é mandar para um endereço que não
existe — em silêncio. Isso vai atingir boa parte de uma carteira de contatos brasileira.
**Regra:** todo contato entra com endereço **verificado**, e o primeiro envio é um canário —
uma mensagem só, confirmada visualmente no celular de quem recebeu, antes de mandar o resto.

> **Conclusão honesta:** WhatsApp é a integração mais desejada e a menos madura das que este
> material toca. Se você não está disposto a conferir cada envio no começo, **não ligue o
> envio** — só a leitura. Ninguém nunca se arrependeu de um agente calado.

### Arquivos e planilhas
- **Ver/Fazer:** depende do escopo que você conceder.
- **Recomendação:** uma pasta dedicada, nunca o Drive inteiro. Escopo estreito é a defesa
  mais eficiente que existe, e a mais barata.

---

## Onde ficam os segredos

```
~/.hermes/.env                       # chaves do agente principal
~/.hermes/profiles/<nome>/.env       # chaves por sub-agente
~/.ssh/                              # chaves de acesso
```

Regras: nunca versionar (o `.gitignore` cuida), nunca colar em chat, nunca colar em skill.
Skill que precisa de segredo lê da variável de ambiente — **não** carrega o valor escrito.

Verificação rápida, que vale rodar de vez em quando:

```bash
cd ~/.hermes/workspace && git status --short
git log --all -p | grep -iE "api[_-]?key|secret|token|BEGIN.*PRIVATE" | head
```

Se aparecer segredo no histórico: **regenere a chave primeiro**, limpe o histórico depois.

---

## O agente errou. E agora?

Vai acontecer. O que separa susto de estrago:

1. **Prefira reversível.** Rascunho em vez de envio, arquivar em vez de apagar.
2. **Confirmação para o que é irreversível.** O Hermes tem aprovação de comandos — use.
3. **Rastro.** Se você não consegue saber o que ele fez, não dê essa permissão a ele.
4. **Começe estreito.** Amplie quando confiar. Nunca o contrário — permissão dada raramente
   é revista.

---

## Quando desconfiar de invasão

Sinais: mensagem que você não mandou, gasto fora do padrão em `hermes insights --days 7`, commit que você
não fez, login estranho no GitHub.

O que fazer, nesta ordem:

```bash
# 1. calar o agente
export XDG_RUNTIME_DIR=/run/user/0
systemctl --user stop hermes-gateway.service

# 2. cortar o canal
#    BotFather -> /revoke   (o token para de funcionar na hora)

# 3. cortar o dinheiro
#    revogue a chave de API no painel do provedor

# 4. só então investigar
journalctl --user -u hermes-gateway --since "24 hours ago" | less
```

Parar o sangramento vem antes de entender a causa. Sempre.

---

## O que este material deliberadamente não faz

Para você saber o que **não** está coberto:

- Não configura firewall além do padrão da VPS
- Não usa 2FA no acesso SSH
- Não criptografa o cérebro em repouso (o Russ usa `git-crypt`; é um passo além daqui)
- Roda como `root`, por simplicidade

Para uso pessoal, esse conjunto é razoável. **Para dados de clientes, dados de saúde ou
qualquer coisa regulada, não é suficiente** — e nesse caso vale conversar com alguém de
segurança antes. Dizer isso é mais honesto do que fingir que o tutorial cobre tudo.
