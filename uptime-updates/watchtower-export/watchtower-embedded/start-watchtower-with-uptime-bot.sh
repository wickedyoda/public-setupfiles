#!/bin/sh
set -eu

BOT_SCRIPT="/opt/uptime-bot/uptime-bot.py"
WATCHTOWER_BIN="/watchtower"

if [ ! -x "${WATCHTOWER_BIN}" ]; then
  echo "[ERROR] watchtower binary not found at ${WATCHTOWER_BIN}" >&2
  exit 1
fi

if [ ! -f "${BOT_SCRIPT}" ]; then
  echo "[ERROR] bot script not found at ${BOT_SCRIPT}" >&2
  exit 1
fi

python3 "${BOT_SCRIPT}" &
BOT_PID=$!

"${WATCHTOWER_BIN}" "$@" &
WT_PID=$!

shutdown() {
  kill "${BOT_PID}" 2>/dev/null || true
  kill "${WT_PID}" 2>/dev/null || true
  wait "${BOT_PID}" 2>/dev/null || true
  wait "${WT_PID}" 2>/dev/null || true
}

trap shutdown INT TERM

while :; do
  if ! kill -0 "${BOT_PID}" 2>/dev/null; then
    echo "[ERROR] uptime bot exited; stopping watchtower" >&2
    kill "${WT_PID}" 2>/dev/null || true
    wait "${WT_PID}" 2>/dev/null || true
    wait "${BOT_PID}" 2>/dev/null || true
    exit 1
  fi

  if ! kill -0 "${WT_PID}" 2>/dev/null; then
    echo "[ERROR] watchtower exited; stopping uptime bot" >&2
    kill "${BOT_PID}" 2>/dev/null || true
    wait "${BOT_PID}" 2>/dev/null || true
    wait "${WT_PID}" 2>/dev/null || true
    exit 1
  fi

  sleep 2
done
