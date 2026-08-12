# Fase 3 — A mente alugada (modelo e custo)

**Tempo:** ~25 min · **Portão:** o agente responde no terminal da VPS

> **Claude:** aqui a pessoa toma a decisão que define a conta do mês dela. Não escolha por
> ela. Apresente os três caminhos, pergunte o que ela **já paga hoje**, e recomende com base
> nisso. Muita gente já tem uma assinatura que resolve e não sabe.

---

## Nivelamento (60 segundos)

O Hermes é o corpo; o **modelo** é a mente — e a mente é alugada. Toda vez que o agente
pensa, alguém cobra.

A cobrança é por **token**, que é mais ou menos um pedaço de palavra (~4 caracteres). Você
paga pelo que **entra** (todo o contexto: seu histórico, a memória, as instruções) e pelo que
**sai** (a resposta). O que entra é quase sempre muito maior que o que sai — e é por isso que
um agente com memória grande custa mais que um chat curto, mesmo respondendo a mesma coisa.

Consequência prática, que vale ela guardar: **memória inchada é dinheiro queimado toda
mensagem.** A Fase 5 vai ensinar a manter o cérebro enxuto justamente por isso.

---

## Passo 1 — Escolher o caminho

Pergunte primeiro: **"você já paga alguma assinatura de IA hoje?"** A resposta muda tudo.

### Caminho A — Nous Portal *(mais simples)*

Uma assinatura cobre modelo, busca web, geração de imagem, TTS e navegador na nuvem. Evita
a coleta de cinco chaves de API diferentes, que é onde iniciante trava.

```bash
hermes setup --portal
hermes portal info
```

Faz login por OAuth, configura o provedor e liga o Tool Gateway. 300+ modelos disponíveis
via `/model <nome>`.
→ **Recomende este para quem não tem assinatura nenhuma e quer o caminho curto.**

### Caminho B — Chave de API própria *(mais controle)*

Ela cria uma conta na Anthropic, OpenAI ou OpenRouter, gera uma chave e paga pelo uso real.
Mais barato se usar pouco, e ela vê exatamente para onde vai cada centavo.

```bash
hermes model     # escolhe provedor e modelo
```

Quando ele pedir a chave, ela cola **no prompt do Hermes na VPS** — nunca no seu chat.
O Hermes guarda no `.env` dele.

**OpenRouter** é uma boa porta de entrada aqui: uma chave só dá acesso a modelos de vários
fornecedores, e dá pra trocar de modelo sem abrir conta nova.

### Caminho C — Reaproveitar uma assinatura que ela já tem

Quem tem ChatGPT Pro ou Claude Max às vezes consegue autenticar por OAuth em vez de pagar
por token. Funciona e é o que o Russ usa, mas é o caminho mais chato de configurar e o mais
sujeito a mudar sem aviso.
→ **Só ofereça se ela mencionar que já paga uma dessas.** Se travar, caia pro Caminho A ou B
sem drama.

---

## Passo 2 — Escolher o modelo dentro do caminho

Regra que vale para qualquer provedor: **um modelo bom para conversar e decidir, um modelo
barato para tarefa mecânica.** Não vale pagar modelo de raciocínio pesado pra formatar lista.

```bash
hermes model            # ver e trocar o modelo padrão
hermes fallback         # o que usar quando o principal falha
```

Configure o **fallback** agora, não depois. Provedor cai, cota estoura, chave expira — sem
fallback o agente simplesmente emudece e ela não sabe por quê.

---

## Passo 3 — Colocar teto de gasto

Faça isso **hoje**, não no primeiro susto de fatura:

- **Caminho A:** o limite é a assinatura. Nada a fazer — essa é a vantagem.
- **Caminho B:** no painel do provedor, configure **limite de gasto mensal** e **alerta de
  e-mail**. Todos oferecem. Anthropic, OpenAI e OpenRouter, todos.

Depois, ensine o comando que mostra o consumo:

```bash
hermes usage        # consumo da sessão
hermes insights --days 7    # padrão de uso na semana
```

Vale combinar com ela de olhar isso na primeira semana. É a hora em que dá pra corrigir
rota barato.

---

## PORTÃO

Na VPS:

```bash
hermes -z "Responda em uma frase: você está funcionando?"
```

Passou se veio uma resposta coerente, sem erro de autenticação.

Falhou com erro de chave/auth → [`referencia/runbook.md`](../referencia/runbook.md),
seção *"Agente não responde"*.

Atualize o `ESTADO.md`: caminho escolhido, modelo padrão, fallback, teto configurado.
**Nunca a chave.**

---

### Fundo

*Abra se ela pedir "me explica melhor".*

**Por que o custo cresce com o tempo mesmo eu usando igual?**
Porque o contexto cresce. Cada mensagem nova carrega junto o histórico e a memória. Se a
memória inchar sem curadoria, o custo por mensagem sobe sozinho, mesmo com o mesmo uso.
É o argumento prático para a disciplina de memória da Fase 5 — não é preciosismo, é a conta.

**Qual a diferença entre um modelo "de raciocínio" e um normal?**
Modelos de raciocínio pensam antes de responder, gerando tokens intermediários que você paga
e não vê. Valem muito para análise e decisão difícil; são desperdício para "resuma esse
e-mail". Daí a regra dos dois modelos.

**Dá pra rodar um modelo local e não pagar nada?**
Dá, e o Hermes suporta. Mas exige uma VPS bem maior (ou GPU), o modelo é sensivelmente mais
fraco, e o custo de servidor engole a economia de API para uso pessoal. Vale como experimento
depois que tudo estiver funcionando, não como ponto de partida.

**E se eu quiser trocar de provedor depois?**
Troca com um comando. Essa é justamente a graça de o cérebro ser texto em Git: a memória, as
skills e as rotinas não pertencem ao fornecedor do modelo. Você troca a mente e mantém a
pessoa.
