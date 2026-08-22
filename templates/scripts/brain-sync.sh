#!/usr/bin/env bash
# brain-sync.sh — sincroniza o segundo cérebro com o GitHub.
#
# Fluxo: pull --rebase  ->  add  ->  commit  ->  push
# O pull vem primeiro de propósito: se você editar pelo GitHub ou pelo seu
# computador, as duas pontas convergem em vez de brigar.
#
# Instalação (ver Fase 5, Passo 6):
#   cp brain-sync.sh ~/.hermes/scripts/ && chmod +x ~/.hermes/scripts/brain-sync.sh
#   ~/.hermes/scripts/brain-sync.sh          # teste manual ANTES de agendar
#   crontab -e  ->  0 * * * * /root/.hermes/scripts/brain-sync.sh
#
# Log: /var/log/brain-sync.log
# Saída: 0 = ok (inclusive "nada a fazer") | !=0 = falhou, veja o log.

set -uo pipefail

WORKSPACE="${BRAIN_WORKSPACE:-$HOME/.hermes/workspace}"
BRANCH="${BRAIN_BRANCH:-main}"
LOG="${BRAIN_LOG:-/var/log/brain-sync.log}"
LOCK="/tmp/brain-sync.lock"
GIT_TIMEOUT=120   # rede pode travar; nunca deixe o cron pendurado para sempre

log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "$LOG"; }

# --- trava: impede duas execuções simultâneas (cron sobrepondo cron) ---------
exec 9>"$LOCK"
if ! flock -n 9; then
  log "SKIP: já existe um sync rodando"
  exit 0
fi

cd "$WORKSPACE" || { log "ERRO: workspace '$WORKSPACE' não existe"; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { log "ERRO: '$WORKSPACE' não é um repo git"; exit 1; }

# --- 1. trazer o que mudou lá fora ------------------------------------------
# --autostash é OBRIGATÓRIO: entre uma execução e outra o workspace quase sempre
# tem mudança não commitada (o agente acabou de escrever no diário), e o git se
# RECUSA a rebase com a árvore suja. Sem isto o sync só funciona por sorte de
# timing — falha justamente quando há o que salvar.
if ! timeout $GIT_TIMEOUT git pull --rebase --autostash origin "$BRANCH" >>"$LOG" 2>&1; then
  log "ERRO: pull/rebase falhou — pode haver CONFLITO. Resolva à mão:"
  log "      cd $WORKSPACE && git status"
  git rebase --abort 2>/dev/null   # volta ao estado anterior; não deixa o repo travado
  exit 1
fi

# --- 2. tem algo para salvar? -----------------------------------------------
if [ -z "$(git status --porcelain)" ]; then
  log "OK: nada mudou"
  exit 0
fi

# --- 3. rede de segurança: nunca versionar segredo ---------------------------
# O .gitignore é a defesa principal (Fase 5, Passo 3). Isto é o cinto extra:
# se algo com cara de credencial entrou no staging, aborta e avisa.
git add -A
if git diff --cached --name-only | grep -qiE '(^|/)\.env|credentials.*\.json|token.*\.json|auth\.json|\.pem$|\.key$'; then
  log "ABORTADO: arquivo com cara de credencial no commit. Confira o .gitignore:"
  git diff --cached --name-only | grep -iE '(^|/)\.env|credentials|token|auth\.json|\.pem$|\.key$' >>"$LOG"
  git reset >>"$LOG" 2>&1
  exit 1
fi

# --- 4. commit e push --------------------------------------------------------
CHANGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
git commit -m "sync: $(date +'%Y-%m-%d %H:%M') (${CHANGED} arquivos)" >>"$LOG" 2>&1

if ! timeout $GIT_TIMEOUT git push origin "$BRANCH" >>"$LOG" 2>&1; then
  log "ERRO: push falhou. Causas comuns:"
  log "      - deploy key sem 'Allow write access' (GitHub -> repo -> Settings -> Deploy keys)"
  log "      - sem rede / GitHub fora do ar"
  log "      O commit está salvo localmente — o próximo sync tenta de novo."
  exit 1
fi

log "OK: ${CHANGED} arquivo(s) sincronizado(s)"
exit 0
