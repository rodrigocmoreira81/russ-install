#!/bin/bash
# agent-watchdog.sh — avisa no Telegram quando o agente Hermes cai (Módulo A3).
#
# Roda no CRONTAB DO LINUX, não no cron do Hermes: se o gateway morrer, o cron do Hermes
# morre junto. Só fala na mudança de estado (caiu / voltou) e repete no máximo a cada 6h.
#
#   */15 * * * * WATCHDOG_CHAT=<seu ID do Telegram> ~/.hermes/scripts/agent-watchdog.sh
#
# Teste a seco: WATCHDOG_CHAT=123 WATCHDOG_DRYRUN=1 ~/.hermes/scripts/agent-watchdog.sh
set -uo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
CHAT="${WATCHDOG_CHAT:?defina WATCHDOG_CHAT com o ID do Telegram}"
NAME="${WATCHDOG_NAME:-agente}"
STATE="$HERMES_HOME/watchdog/agent.state"
LOG="$HERMES_HOME/logs/agent-watchdog.log"
REALERT_SECONDS=21600
now=$(date +%s)
mkdir -p "$(dirname "$STATE")" "$(dirname "$LOG")"
log(){ echo "$(date -Iseconds) $*" >> "$LOG"; }

level=OK; summary=""
add(){ [ "$1" = CRIT ] && level=CRIT; [ "$1" = WARN ] && [ "$level" = OK ] && level=WARN; summary="${summary:+$summary; }$2"; }

# 1. gateways fora do ar (todos os hermes-gateway* instalados)
units=$(systemctl --user list-unit-files 'hermes-gateway*.service' --no-legend 2>/dev/null | awk '{print $1}')
[ -z "$units" ] && add CRIT "nenhum servico hermes-gateway instalado"
for u in $units; do
  systemctl --user is-active --quiet "$u" || add CRIT "$u fora do ar"
done

# 2. 401 recentes, ignorando os do processo velho morrendo num restart
jr=$(journalctl --user --since "20 minutes ago" --no-pager 2>/dev/null)
n401=$(grep -c "HTTP 401" <<<"$jr" || true)
if [ "${n401:-0}" -gt 0 ] && ! grep -q "Stopping hermes-gateway" <<<"$jr"; then
  add CRIT "$n401 erro(s) HTTP 401 nos ultimos 20min"
fi

# 3. validade do token OAuth do Codex (só se existir)
tok=$(python3 - "$HERMES_HOME/auth.json" <<'PY'
import json,sys,base64,datetime
try: d=json.load(open(sys.argv[1]))
except Exception: raise SystemExit
p=(d.get("providers") or {}).get("openai-codex")
if not p: raise SystemExit
if (p.get("last_auth_error") or {}).get("relogin_required"):
    print("CRIT|login do Codex pede relogin"); raise SystemExit
at=(p.get("tokens") or {}).get("access_token","")
if not at: print("CRIT|access_token do Codex ausente"); raise SystemExit
try:
    q=at.split(".")[1]; q+="="*(-len(q)%4)
    exp=datetime.datetime.fromtimestamp(json.loads(base64.urlsafe_b64decode(q))["exp"],datetime.timezone.utc)
except Exception: raise SystemExit
h=(exp-datetime.datetime.now(datetime.timezone.utc)).total_seconds()/3600
if h<0: print(f"CRIT|token do Codex expirado ha {-h:.1f}h")
elif h<24: print(f"WARN|token do Codex expira em {h:.1f}h ({exp:%d/%m %H:%M} UTC)")
PY
)
[ -n "$tok" ] && add "${tok%%|*}" "${tok#*|}"

prev_level=OK; prev_alert=0
[ -f "$STATE" ] && { prev_level=$(sed -n 1p "$STATE"); prev_alert=$(sed -n 2p "$STATE"); }
prev_level=${prev_level:-OK}; prev_alert=${prev_alert:-0}

notify(){
  if [ -n "${WATCHDOG_DRYRUN:-}" ]; then echo "[DRY-RUN] $1"; return; fi
  hermes send -t "telegram:$CHAT" "$1" >/dev/null 2>&1 && { log "alerta via hermes send"; return; }
  # plano B: API do Telegram direto — não depende do que está sendo vigiado
  local t; t=$(grep -m1 '^TELEGRAM_BOT_TOKEN=' "$HERMES_HOME/.env" 2>/dev/null | cut -d= -f2- | tr -d "\"'")
  if [ -n "$t" ] && curl -s -m 20 -o /dev/null -d "chat_id=$CHAT" --data-urlencode "text=$1" \
       "https://api.telegram.org/bot$t/sendMessage"; then log "alerta via API direta"
  else log "FALHA: nao consegui alertar"; fi
}

if [ "$level" = OK ]; then
  [ "$prev_level" != OK ] && { notify "✅ $NAME recuperado."; log "recuperado"; }
  printf 'OK\n0\n' > "$STATE"; [ -n "${WATCHDOG_DRYRUN:-}" ] && echo "OK"; exit 0
fi

if [ "$prev_level" = OK ] || [ $((now - prev_alert)) -ge $REALERT_SECONDS ] || [ -n "${WATCHDOG_DRYRUN:-}" ]; then
  icon="🚨"; [ "$level" = WARN ] && icon="⚠️"
  notify "$icon $NAME: $summary
Diagnóstico: journalctl --user -u hermes-gateway -n 50"
  printf '%s\n%s\n' "$level" "$now" > "$STATE"; log "ALERTA [$level] $summary"
else
  printf '%s\n%s\n' "$level" "$prev_alert" > "$STATE"; log "silenciado [$level] $summary"
fi
