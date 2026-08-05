# Watchtower Export Bundle

This folder is a portable package with two Docker deployment modes:

- Standalone bot + separate watchtower container
- Embedded bot inside a custom watchtower image

## Included Files

- Dockerfile
- docker-compose.watchtower-uptime-sync.yml
- docker-compose.watchtower-embedded.yml
- uptime-bot.py
- requirements.txt
- config.yml
- container-monitor-map.yaml
- watchtower-embedded/Dockerfile.watchtower-with-uptime-bot
- watchtower-embedded/start-watchtower-with-uptime-bot.sh

## Create Export Tarball

From uptime-updates directory:

```bash
bash export-watchtower-bundle.sh
```

This creates a timestamped tar.gz in this folder.

## Run Standalone Mode (Recommended)

In this folder:

```bash
docker compose -f docker-compose.watchtower-uptime-sync.yml up -d --build
```

## Run Embedded Watchtower Mode

In this folder:

```bash
docker compose -f docker-compose.watchtower-embedded.yml up -d --build
```

## Notes

- The bot uses Docker host API endpoints listed in container-monitor-map.yaml.
- Keep config.yml and container-monitor-map.yaml updated with your real values.
- These Docker deployments do not require systemd.
