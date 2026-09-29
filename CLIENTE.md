# CLIENTE — quando quem instala não é o dono do agente

> **Claude: leia isto logo depois do `BOOTSTRAP.md`, e só se a pessoa falando com você for
> instalar o agente PARA OUTRA PESSOA** (um cliente, um sócio, um familiar). Se ela está
> instalando o próprio agente, ignore este arquivo.
>
> Aqui, "o consultor" é quem conversa com você; "o cliente" é o dono do agente. Tudo o que
> o BOOTSTRAP diz sobre "ela" continua valendo — só que agora são **duas pessoas com
> interesses diferentes**, e o curso muda em cinco pontos.

---

## 1. A regra-mãe: tudo no nome do cliente

O agente vai ter acesso à vida do cliente. Nada dele pode depender da conta, do cartão ou da
máquina do consultor. Antes da Fase 1, confirme esta tabela com os dois e grave no `ESTADO.md`:

| Peça | Dono | O consultor tem | No handover |
|---|---|---|---|
| Conta da VPS + cartão | **Cliente** | Nada (o cliente cria a conta com a tela compartilhada) | — |
| Acesso SSH à VPS | Cliente (chave dele) | Chave SSH **própria e separada** | Chave do consultor removida de `authorized_keys` |
| Repo GitHub do cérebro | **Cliente** (conta dele) | Colaborador temporário | Consultor removido do repo |
| Deploy key do cérebro | Gerada na VPS | — | Continua valendo (é da VPS, não de pessoa) |
| Bot do Telegram | **Cliente** (criado no BotFather *do celular dele*) | Nada | — |
| Provedor de modelo (API key / assinatura) | **Cliente** | Nada | — |
| Integrações (Google, WhatsApp, Typesafe…) | **Cliente** | Nada | Tokens criados com a sessão do cliente |

**Link de afiliado:** o link da Fase 1 dá comissão para o autor deste material. Se o consultor
tiver o próprio link, ele declara ao cliente, igual a Fase 1 faz. Comissão escondida corrói a
confiança que sustenta o resto da instalação.

**Nunca** reaproveite bot, repo ou VPS de outro cliente "pra testar". Um cliente por VPS é o
padrão; `profiles` do Hermes separam papéis de um mesmo dono, **não** donos diferentes.

---

## 2. Segredos: o cliente digita, o consultor não vê

A regra 1 do BOOTSTRAP ("nunca no chat") ganha um complemento: **o consultor também não digita
nem lê segredo do cliente.** O fluxo é sempre:

1. Você prepara o comando que abre o editor ou lê do teclado sem eco (`read -rs VAR`).
2. O **cliente** cola o valor, na máquina ou na tela compartilhada dele.
3. Você valida sem imprimir: `grep -c '^NOME_DA_CHAVE=' ~/.hermes/.env` → `1`.

Se o cliente usa gerenciador de senhas corporativo, prefira `hermes secrets bitwarden` ou
`hermes secrets onepassword` — o Hermes lê as chaves na partida e o `.env` nem precisa tê-las.

Qualquer segredo que o consultor chegou a ver (colou no chat, apareceu num print) **é rotacionado
antes do handover**. Liste-os na seção *Pendências* do `ESTADO.md` até serem trocados.

---

## 3. Dados pessoais e consentimento

Na Fase 0 e no `USER.md` você vai coletar rotina, família, trabalho e prioridades do cliente —
isso é dado pessoal, e o consultor é, na prática, um operador desses dados.

- **Pergunte antes o que NÃO entra.** Saúde, finanças pessoais, família e documentos legais
  podem ficar fora do cérebro ou marcados como `sealed` no ledger (ver
  [`modulos/A2-ledger-jev.md`](modulos/A2-ledger-jev.md)).
- **Todo fornecedor que recebe texto do cliente precisa de autorização explícita dele, por
  escrito, antes de ligar.** Isso inclui o provedor do modelo (óbvio) e qualquer classificador
  externo (Typesafe/Jev). A autorização vai no `ESTADO.md`, com data.
- **O consultor não guarda cópia** do cérebro, dos logs ou do `ESTADO.md` depois da entrega,
  a não ser que haja contrato de suporte dizendo o contrário.
- Se o cliente atende pacientes, clientes finais ou dado regulado, **pare** e releia
  [`referencia/seguranca.md`](referencia/seguranca.md): este material não basta sozinho.

---

## 4. O que muda no roteiro

| Onde | Mudança |
|---|---|
| **Fase 0** | As 3 perguntas são respondidas **pelo cliente**, com a voz dele. O consultor não responde por ele. Modo: quase sempre **Piloto** pro consultor, mas as explicações de cada portão são dadas **ao cliente**. |
| **Fase 1** | Cliente cria a conta e paga. O consultor gera a própria chave (`meu-agente-<cliente>`), e o `~/.ssh/config` usa um apelido por cliente — nunca `meu-agente` genérico se ele tem mais de um. |
| **Fase 3** | A escolha "com ou sem fallback" é do cliente, explicada com o trade-off (ver Fase 3). Se escolher sem fallback, o watchdog do módulo A3 é **obrigatório**. |
| **Fase 4** | O bot nasce no Telegram do cliente. O consultor entra na allowlist só durante a instalação, se precisar testar — e sai no handover. |
| **Fase 5** | Repo na conta GitHub do cliente. O consultor é convidado como colaborador. |
| **Fase 9** | O **cliente** faz o teste de restore, não o consultor. Esse é o portão que prova que ele não depende de você. |
| **Módulos A1–A3** | Viram parte do pacote conforme o contrato. A3 (operação blindada) é o mínimo para qualquer cliente que vá depender do agente no dia a dia. |

`ESTADO.md` fica em `~/clientes/<cliente>/ESTADO.md` na máquina do consultor **durante** a
instalação e é **entregue** ao cliente no fim (e apagado da máquina do consultor). Acrescente ao
modelo do BOOTSTRAP:

```markdown
## Cliente
- **Cliente:** (nome ou apelido — sem documento)
- **Consultor:** (nome)
- **Pacote:** núcleo (0–7) · + sub-agentes (8) · + módulos A1/A2/A3
- **Autorizações de dados (com data):** modelo: — · classificador externo: — · integrações: —
- **Acessos temporários do consultor:** ssh: sim · repo: colaborador · allowlist bot: não
- **Segredos a rotacionar antes da entrega:** (nenhum)
```

---

## 5. Handover — o portão final do modo cliente

Não termine sem **todos** os itens, verificados com comando, não com promessa:

```bash
# 1. chave do consultor fora da VPS
ssh <apelido-do-cliente> 'grep -c "<comentário-da-chave-do-consultor>" ~/.ssh/authorized_keys'   # → 0
# 2. consultor fora da allowlist do bot
ssh <apelido-do-cliente> 'grep ^TELEGRAM_ALLOWED_USERS= ~/.hermes/.env'   # só o ID do cliente
# 3. o cliente consegue entrar sozinho (ele roda, na máquina dele)
ssh <apelido-do-cliente> 'hermes gateway status'
```

4. Consultor removido como colaborador do repo (GitHub → Settings → Collaborators).
5. Segredos da lista *"a rotacionar"* trocados — pelo cliente.
6. O **cliente** fez o restore da Fase 9 e mandou o "oi" pelo Telegram.
7. `ESTADO.md` entregue ao cliente e apagado da máquina do consultor.
8. Combinado por escrito: quem o cliente chama quando quebrar (frase de socorro da Fase 9 com o
   Claude Code **dele**, e o suporte do consultor, se houver contrato), e quem recebe os alertas
   do watchdog (deve ser o cliente; o consultor só em cópia, se contratado).

> **Claude:** se o cliente quer que o consultor continue operando (suporte mensal), isso não é
> falha de handover — mas aí o acesso do consultor vira **documentado e revogável**, com a chave
> SSH identificada pelo nome dele, e fica escrito no `ESTADO.md` do cliente.
