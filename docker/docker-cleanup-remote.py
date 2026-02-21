#!/usr/bin/env python3
"""Run Docker cleanup commands on remote hosts listed in a text file."""

from __future__ import annotations

import argparse
import getpass
from datetime import datetime
from pathlib import Path
from typing import List

try:
    import paramiko
except ImportError:  # pragma: no cover - runtime environment dependent
    paramiko = None


DOCKER_COMMANDS = [
    "docker container prune -f",
    "docker image prune -a -f",
    "docker volume prune -f",
    "docker network prune -f",
]


def parse_args() -> argparse.Namespace:
    script_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description=(
            "Clean up Docker containers, images, volumes, and networks "
            "on all hosts listed in a text file."
        )
    )
    parser.add_argument(
        "machine_file",
        nargs="?",
        default=str(script_dir / "machines.txt"),
        help="Path to host list file (default: docker/machines.txt).",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=20,
        help="SSH connection timeout in seconds (default: 20).",
    )
    return parser.parse_args()


def load_hosts(machine_file: Path) -> List[str]:
    hosts: List[str] = []
    for raw_line in machine_file.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("#", 1)[0].strip()
        if line:
            hosts.append(line)
    return hosts


def run_remote_cleanup(
    host: str, username: str, password: str, timeout: int, log_handle
) -> bool:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(
            hostname=host,
            username=username,
            password=password,
            timeout=timeout,
            auth_timeout=timeout,
            banner_timeout=timeout,
            look_for_keys=False,
            allow_agent=False,
        )

        for cmd in DOCKER_COMMANDS:
            stdin, stdout, stderr = client.exec_command(cmd, timeout=300)
            _ = stdin
            out = stdout.read().decode("utf-8", errors="replace")
            err = stderr.read().decode("utf-8", errors="replace")
            code = stdout.channel.recv_exit_status()

            log_handle.write(f"$ {cmd}\n")
            if out:
                log_handle.write(out)
                if not out.endswith("\n"):
                    log_handle.write("\n")
            if err:
                log_handle.write(err)
                if not err.endswith("\n"):
                    log_handle.write("\n")

            if code != 0:
                log_handle.write(f"Command failed with exit code {code}\n")
                return False
        return True
    except Exception as exc:  # pylint: disable=broad-except
        log_handle.write(f"Connection or execution error: {exc}\n")
        return False
    finally:
        client.close()


def main() -> int:
    args = parse_args()

    if paramiko is None:
        print("Missing dependency: paramiko")
        print("Install it with: python -m pip install paramiko")
        return 1

    machine_file = Path(args.machine_file).expanduser().resolve()
    if not machine_file.exists():
        print(f"Machine list file not found: {machine_file}")
        return 1

    hosts = load_hosts(machine_file)
    if not hosts:
        print(f"No hosts found in: {machine_file}")
        print("Add one hostname or IP per line.")
        return 1

    username = input("SSH username (same account for all machines): ").strip()
    if not username:
        print("Username cannot be empty.")
        return 1

    password = getpass.getpass("SSH password: ").strip()
    if not password:
        print("Password cannot be empty.")
        return 1

    print(
        "This will remove unused Docker containers, images, volumes, and "
        "networks on all listed hosts."
    )
    confirm = input("Continue? (y/N): ").strip().lower()
    if confirm != "y":
        print("Cancelled.")
        return 0

    log_name = f"docker_cleanup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    log_path = Path(__file__).resolve().parent / log_name

    success = 0
    failed = 0

    with log_path.open("w", encoding="utf-8") as log_handle:
        log_handle.write(f"Docker cleanup run started: {datetime.now()}\n")
        log_handle.write(f"Machine file: {machine_file}\n\n")

        for host in hosts:
            print(f"Running cleanup on {host} ...")
            log_handle.write(f"========== {host} ==========\n")

            ok = run_remote_cleanup(
                host=host,
                username=username,
                password=password,
                timeout=args.timeout,
                log_handle=log_handle,
            )

            if ok:
                success += 1
                print(f"SUCCESS: {host}")
                log_handle.write(f"SUCCESS: {host}\n\n")
            else:
                failed += 1
                print(f"FAILED: {host}")
                log_handle.write(f"FAILED: {host}\n\n")

    print(f"Run complete. Successful hosts: {success}, Failed hosts: {failed}")
    print(f"Log file: {log_path}")
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
