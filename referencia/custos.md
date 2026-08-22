# Custos — a conta honesta

> **Claude:** valores de referência de **agosto de 2026**, em reais. Preço de VPS e de modelo
> muda o tempo todo — **sempre confirme no site do provedor** antes de afirmar número para ela.
> Use isto para calibrar expectativa, não como tabela oficial.

---

## Resumo

| Item | Faixa mensal | Observação |
|---|---|---|
| VPS | **R$ 40 – 90** | Fixo e previsível. O piso do projeto. |
| Modelo de IA | **R$ 0 – 150** | Varia com uso. Onde mora a surpresa. |
| GitHub | **R$ 0** | Repositório privado é gratuito. |
| Telegram | **R$ 0** | Bots são gratuitos. |
| **Total realista** | **R$ 40 – 240** | Uso pessoal, um agente. |

Maioria das pessoas, uso pessoal moderado: **R$ 60 – 120/mês**.

---

## VPS

| Configuração | Faixa | Serve para |
|---|---|---|
| 1 vCPU / 4 GB | R$ 30 – 50 | Um agente, sem enfeite. O mínimo real. |
| **2 vCPU / 8 GB** | **R$ 50 – 90** | **Recomendado.** Um agente com folga. |
| 4 vCPU / 16 GB | R$ 100 – 180 | Vários sub-agentes, dashboard. |

Três coisas que enganam na hora de comprar:

1. **O preço anunciado costuma ser o do plano anual, à vista.** Mensal é bem mais caro.
2. **Promoção de primeiro ano some na renovação.** Peça para ela olhar o preço de renovação
   antes de decidir — é onde vem a surpresa no ano seguinte.
3. **Anual só compensa com convicção.** No primeiro mês, ninguém tem.

Referência concreta: o Russ roda **6 gateways** simultâneos num 4 vCPU / 16 GB usando ~9 GB.
Um agente sozinho vive folgado em 8 GB.

---

## Modelo de IA

É aqui que a conta varia — e onde a atenção rende.

### Caminho A — assinatura (Nous Portal e similares)
**~R$ 100 – 150/mês, previsível.** Cobre modelo, busca web, imagem, TTS. Sem susto no fim do
mês e sem coletar cinco chaves. É o caminho recomendado para quem está começando: **custo fixo
vale mais que custo ótimo** quando a pessoa ainda não sabe quanto vai usar.

### Caminho B — API por uso
**R$ 0 – 200/mês, imprevisível.** Você paga pelo que consome. Mais barato se usar pouco;
pode surpreender se as rotinas dispararem muito.

Referência grosseira para calibrar (varia muito por modelo):

| Uso | Estimativa |
|---|---|
| ~20 mensagens/dia, contexto pequeno | R$ 20 – 50/mês |
| ~50 mensagens/dia + 3 rotinas | R$ 60 – 150/mês |
| Uso pesado, memória grande, modelo caro | R$ 200+/mês |

### Caminho C — assinatura que ela já tem
**R$ 0 adicional**, se ChatGPT Pro ou Claude Max autenticar por OAuth. Melhor custo, pior
estabilidade — pode mudar sem aviso.

---

## Por que a conta sobe sozinha

Três causas, em ordem de frequência:

**1. Memória inchada.** Cada mensagem carrega o contexto inteiro. Cérebro que cresce sem
curadoria aumenta o custo de **toda** interação, mesmo com o mesmo uso.
→ Revisão semanal (Fase 7). É a intervenção de maior retorno.

**2. Modelo caro para tarefa boba.** Modelo de raciocínio para formatar lista é desperdício.
→ Modelo bom para decidir, modelo barato para tarefa mecânica.

**3. Rotina frequente demais.** De hora em hora = 720 execuções/mês. Diário = 30.
→ Quase nada precisa de hora em hora.

---

## Como acompanhar

```bash
hermes status                # modelo e provedor ativos agora
hermes insights --days 30    # padrão do mês
```

E **configure teto de gasto no painel do provedor no primeiro dia** — Anthropic, OpenAI e
OpenRouter oferecem limite mensal e alerta por e-mail. Não deixe para depois do primeiro susto.

Checagem mensal de cinco minutos: quanto gastei, mudou o padrão, alguma rotina disparando à toa.

---

## Vale a pena?

Colocando em perspectiva, sem vender nada: R$ 60–120/mês é aproximadamente uma assinatura de
streaming e meia, ou um almoço fora por semana.

A pergunta certa não é "é caro?", é **"o que isso me devolve?"**. Se o agente economiza duas
horas por mês de trabalho chato, já pagou. Se ele fica lá, bonito, sem ser usado, qualquer
valor é caro.

Sugira a ela a pergunta mensal da Fase 9: *"se eu desligasse isso hoje, do que eu sentiria
falta?"* — resposta honesta, decisão fácil, nos dois sentidos.
