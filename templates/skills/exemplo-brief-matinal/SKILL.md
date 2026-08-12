---
name: brief-matinal
description: Resume o dia da pessoa — compromissos, pendências e o que importa hoje.
  Use quando ela perguntar "como está meu dia", "o que eu tenho hoje", "me dá o
  panorama", "resumo da manhã", ou quando a rotina das 7h disparar.
version: 1.0.0
metadata:
  hermes:
    tags: [rotina, agenda, manha]
    category: productivity
---

# Brief matinal

<!--
CLAUDE: use isto como MOLDE, não como resposta pronta. Adapte às fontes que ela
realmente tem (pode não ter agenda conectada ainda) e às palavras que ELA usa.

O campo `description` acima é o gatilho: se não contiver as palavras que ela usa
de verdade, a skill nunca dispara. É o campo mais importante do arquivo.
-->

## Quando usar

- Ela pergunta como está o dia / o que tem hoje / pede o panorama
- A rotina `brief-matinal` dispara de manhã

## Como fazer

1. Leia `memory/AAAA-MM-DD.md` de **hoje** e de **ontem**
2. Liste os compromissos de hoje em ordem de horário
3. Levante as pendências que ficaram abertas ontem
4. Destaque o que tem prazo hoje ou está atrasado
5. Termine com **uma** pergunta sobre a prioridade do dia

## Formato da resposta

```
☀️ {{dia da semana}}, {{data}}

📅 Agenda
· HH:MM — compromisso

⚠️ Precisa de atenção
· pendência (por que hoje)

❓ Qual sua prioridade hoje?
```

- **Máximo 8 linhas** no total
- Sem saudação longa. Sem "espero que esteja tendo um ótimo dia"
- Emoji só para separar seção, nunca no meio da frase

## Nunca

<!-- CLAUDE: esta é a seção mais valiosa. Toda vez que o agente errar, a correção
     vira uma linha aqui. É assim que ela evolui o agente sozinha, para sempre. -->

- Nunca invente compromisso que não está na fonte
- Se não houver nada, **diga que não há nada** — não encha linguiça
- Não repita o que já foi dito no brief de ontem, a menos que ainda esteja pendente
- Não dê conselho motivacional. Ela não pediu
- Se a rotina automática rodar e não houver **nada** relevante, responda apenas `[SILENT]`
