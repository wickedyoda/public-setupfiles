#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/watchtower-export"
BUNDLE_NAME="uptime-watchtower-bundle-$(date +%Y%m%d-%H%M%S).tar.gz"

mkdir -p "${OUT_DIR}"

cp -f "${SCRIPT_DIR}/uptime-bot.py" "${OUT_DIR}/uptime-bot.py"
cp -f "${SCRIPT_DIR}/requirements.txt" "${OUT_DIR}/requirements.txt"
cp -f "${SCRIPT_DIR}/config.yml" "${OUT_DIR}/config.yml"
cp -f "${SCRIPT_DIR}/container-monitor-map.yaml" "${OUT_DIR}/container-monitor-map.yaml"

if [[ ! -f "${OUT_DIR}/Dockerfile" ]]; then
  echo "Missing ${OUT_DIR}/Dockerfile"
  exit 1
fi

if [[ ! -f "${OUT_DIR}/docker-compose.watchtower-uptime-sync.yml" ]]; then
  echo "Missing ${OUT_DIR}/docker-compose.watchtower-uptime-sync.yml"
  exit 1
fi

if [[ ! -f "${OUT_DIR}/docker-compose.watchtower-embedded.yml" ]]; then
  echo "Missing ${OUT_DIR}/docker-compose.watchtower-embedded.yml"
  exit 1
fi

if [[ ! -f "${OUT_DIR}/watchtower-embedded/Dockerfile.watchtower-with-uptime-bot" ]]; then
  echo "Missing ${OUT_DIR}/watchtower-embedded/Dockerfile.watchtower-with-uptime-bot"
  exit 1
fi

if [[ ! -f "${OUT_DIR}/watchtower-embedded/start-watchtower-with-uptime-bot.sh" ]]; then
  echo "Missing ${OUT_DIR}/watchtower-embedded/start-watchtower-with-uptime-bot.sh"
  exit 1
fi

cd "${OUT_DIR}"
tar -czf "${BUNDLE_NAME}" \
  Dockerfile \
  docker-compose.watchtower-uptime-sync.yml \
  docker-compose.watchtower-embedded.yml \
  uptime-bot.py \
  requirements.txt \
  config.yml \
  container-monitor-map.yaml \
  watchtower-embedded/Dockerfile.watchtower-with-uptime-bot \
  watchtower-embedded/start-watchtower-with-uptime-bot.sh

echo "Bundle created: ${OUT_DIR}/${BUNDLE_NAME}"
