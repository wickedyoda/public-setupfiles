#!/usr/bin/env python3
"""Continuously sync Docker container IDs into Uptime Kuma docker monitors.

This bot reads:
- config.yml
- container-monitor-map.yaml

From the same directory as this script.
"""

from __future__ import annotations

import json
import logging
import os
import signal
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional

import yaml
from uptime_kuma_api import UptimeKumaApi


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.getenv("UPTIME_BOT_CONFIG", os.path.join(BASE_DIR, "config.yml"))
MAP_PATH = os.getenv("UPTIME_BOT_MAP", os.path.join(BASE_DIR, "container-monitor-map.yaml"))

STOP = False


def _signal_handler(signum: int, _frame: Any) -> None:
    global STOP
    STOP = True
    logging.info("Received signal %s, shutting down...", signum)


def _load_yaml(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}
    if not isinstance(data, dict):
        raise ValueError(f"YAML root in {path} must be a mapping")
    return data


def _normalize_docker_host_url(raw_url: str) -> str:
    if raw_url.startswith("tcp://"):
        return "http://" + raw_url[len("tcp://") :]
    if raw_url.startswith("http://") or raw_url.startswith("https://"):
        return raw_url
    raise ValueError(f"Unsupported host_api scheme: {raw_url}")


def _docker_get_container_id(host_api: str, container_name: str, timeout_seconds: int) -> Optional[str]:
    """Resolve a container name on a Docker host to its full container ID.

    Uses Docker remote API endpoint: /containers/{name}/json
    """
    base_url = _normalize_docker_host_url(host_api).rstrip("/")
    encoded_name = urllib.parse.quote(container_name, safe="")
    url = f"{base_url}/containers/{encoded_name}/json"

    request = urllib.request.Request(url=url, method="GET", headers={"Accept": "application/json"})

    try:
        with urllib.request.urlopen(request, timeout=timeout_seconds) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            logging.warning("Container not found on host %s: %s", host_api, container_name)
            return None
        raise

    container_id = payload.get("Id")
    if not container_id:
        raise RuntimeError(f"Docker API response missing Id for {container_name} on {host_api}")
    return str(container_id)


def _api_login(url: str, api_key: str) -> UptimeKumaApi:
    api = UptimeKumaApi(url)
    # Uptime Kuma API key auth in wrapper is login_by_token.
    api.login_by_token(api_key)
    return api


def _update_monitor_container_id(
    api: UptimeKumaApi,
    monitor_id: int,
    new_container_id: str,
    dry_run: bool,
) -> bool:
    """Attempt to update docker_container for a monitor.

    Returns True if monitor was updated, False if unchanged or dry-run.
    """
    monitor = api.get_monitor(monitor_id)
    if not isinstance(monitor, dict):
        raise RuntimeError(f"Unexpected monitor payload for id {monitor_id}: {type(monitor)}")

    current_id = str(monitor.get("docker_container") or "")
    if current_id == new_container_id:
        return False

    if dry_run:
        logging.info(
            "Dry-run: would update monitor %s docker_container from %s to %s",
            monitor_id,
            current_id,
            new_container_id,
        )
        return False

    last_error: Optional[Exception] = None

    # Try minimal edit call patterns first.
    for call in (
        lambda: api.edit_monitor(monitor_id, docker_container=new_container_id),
        lambda: api.edit_monitor(id=monitor_id, docker_container=new_container_id),
    ):
        try:
            call()
            logging.info(
                "Updated monitor %s docker_container from %s to %s",
                monitor_id,
                current_id,
                new_container_id,
            )
            return True
        except Exception as exc:  # noqa: BLE001
            last_error = exc

    if last_error is None:
        raise RuntimeError(f"Failed to update monitor {monitor_id} for unknown reason")
    raise RuntimeError(f"Failed to update monitor {monitor_id}: {last_error}")


def _run_once(config: Dict[str, Any], mapping: Dict[str, Any]) -> None:
    uptime_cfg = config.get("uptime_kuma") or {}
    bot_cfg = config.get("bot") or {}

    uptime_url = str(uptime_cfg.get("url") or "").strip()
    api_key = str(uptime_cfg.get("api_key") or "").strip()
    dry_run = bool(bot_cfg.get("dry_run", False))
    timeout_seconds = int(bot_cfg.get("request_timeout_seconds", 10))

    if not uptime_url:
        raise ValueError("config.yml missing uptime_kuma.url")
    if not api_key or api_key == "PUT_YOUR_API_KEY_HERE":
        raise ValueError("config.yml missing real uptime_kuma.api_key")

    mappings = mapping.get("mappings") or []
    if not isinstance(mappings, list):
        raise ValueError("container-monitor-map.yaml: mappings must be a list")

    if not mappings:
        logging.info("No mappings configured. Nothing to do.")
        return

    api = _api_login(uptime_url, api_key)
    updated = 0

    try:
        for item in mappings:
            if not isinstance(item, dict):
                logging.warning("Skipping invalid mapping item (not a mapping): %r", item)
                continue

            if item.get("enabled", True) is False:
                continue

            name = str(item.get("name") or "unnamed")
            host_api = str(item.get("host_api") or "").strip()
            container_name = str(item.get("container_name") or "").strip()
            expected_type = str(item.get("expected_uptime_type") or "").strip().lower()

            monitor_id_raw = item.get("uptime_monitor_id")
            try:
                monitor_id = int(monitor_id_raw)
            except Exception as exc:  # noqa: BLE001
                logging.error("[%s] Invalid uptime_monitor_id: %r (%s)", name, monitor_id_raw, exc)
                continue

            if not host_api or not container_name:
                logging.error("[%s] Missing host_api or container_name", name)
                continue

            try:
                container_id = _docker_get_container_id(host_api, container_name, timeout_seconds)
                if not container_id:
                    continue

                monitor = api.get_monitor(monitor_id)
                monitor_type = str((monitor or {}).get("type") or "").lower()
                if expected_type and monitor_type and monitor_type != expected_type:
                    logging.error(
                        "[%s] Monitor %s type mismatch. expected=%s actual=%s",
                        name,
                        monitor_id,
                        expected_type,
                        monitor_type,
                    )
                    continue

                changed = _update_monitor_container_id(api, monitor_id, container_id, dry_run)
                if changed:
                    updated += 1
            except Exception as exc:  # noqa: BLE001
                logging.exception("[%s] Failed to process mapping: %s", name, exc)
    finally:
        try:
            api.disconnect()
        except Exception:  # noqa: BLE001
            pass

    logging.info("Cycle complete. monitors_updated=%s", updated)


def main() -> int:
    signal.signal(signal.SIGINT, _signal_handler)
    signal.signal(signal.SIGTERM, _signal_handler)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    if not os.path.exists(CONFIG_PATH):
        logging.error("Missing config file: %s", CONFIG_PATH)
        return 1
    if not os.path.exists(MAP_PATH):
        logging.error("Missing mapping file: %s", MAP_PATH)
        return 1

    config = _load_yaml(CONFIG_PATH)
    mapping = _load_yaml(MAP_PATH)
    bot_cfg = config.get("bot") or {}
    interval_seconds = int(bot_cfg.get("poll_interval_seconds", 60))
    if interval_seconds < 5:
        logging.warning("poll_interval_seconds too low (%s), forcing to 5", interval_seconds)
        interval_seconds = 5

    logging.info("Starting uptime bot. interval=%ss", interval_seconds)

    while not STOP:
        try:
            _run_once(config, mapping)
        except Exception as exc:  # noqa: BLE001
            logging.exception("Cycle failed: %s", exc)

        if STOP:
            break

        slept = 0
        while slept < interval_seconds and not STOP:
            time.sleep(1)
            slept += 1

        # Reload config/map each cycle so file changes apply without restart.
        try:
            config = _load_yaml(CONFIG_PATH)
            mapping = _load_yaml(MAP_PATH)
            bot_cfg = config.get("bot") or {}
            new_interval = int(bot_cfg.get("poll_interval_seconds", interval_seconds))
            interval_seconds = max(5, new_interval)
        except Exception as exc:  # noqa: BLE001
            logging.warning("Failed to reload config/map, using previous values: %s", exc)

    logging.info("Uptime bot stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
