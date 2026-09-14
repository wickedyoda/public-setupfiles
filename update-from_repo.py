#!/usr/bin/env python3
"""
Update or clone the public-setupfiles repository.
If already inside the repo, pulls latest changes.
Otherwise clones from GitHub to ./public-setupfiles.
"""
import subprocess
import os
import shutil

remote_repo = "https://github.com/wickedyoda/public-setupfiles.git"
local_dir = "public-setupfiles"


def run(cmd, **kwargs):
    """Run a command and return the result."""
    print(f"  Running: {' '.join(cmd)}")
    return subprocess.run(cmd, **kwargs)


def install_git():
    """Install git if not present."""
    # Already installed?
    if shutil.which("git"):
        return True

    if shutil.which("apt-get"):
        subprocess.run(["apt-get", "update", "-y"], check=True)
        subprocess.run(["apt-get", "install", "-y", "git"], check=True)
    elif shutil.which("opkg"):
        subprocess.run(["opkg", "update"], check=True)
        subprocess.run(["opkg", "install", "git", "git-http"], check=True)
    else:
        print("Error: Neither apt-get nor opkg found to install git.")
        return False

    # Verify git is actually available after install
    return shutil.which("git") is not None


def is_in_repo():
    """Check if we're inside the public-setupfiles git repo."""
    if not os.path.isdir(".git"):
        return False
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True, text=True
        )
        return "wickedyoda/public-setupfiles" in result.stdout
    except Exception:
        return False


def main():
    if os.geteuid() != 0:
        print("Warning: Not running as root. Some operations may fail.")

    if not install_git():
        print("Failed to install or find git. Exiting.")
        return 1

    # If we're already inside the cloned repo, pull latest
    if is_in_repo():
        print("Already in public-setupfiles repo. Pulling latest changes...")
        result = run(["git", "pull", "origin", "main"])
        if result.returncode == 0:
            print("Update complete!")
            return 0
        else:
            print(f"Update failed with exit code {result.returncode}")
            return result.returncode

    # Check if directory already exists
    if os.path.isdir(local_dir) and os.listdir(local_dir):
        print(f"Directory '{local_dir}' exists. Pulling latest changes...")
        os.chdir(local_dir)
        result = run(["git", "pull", "origin", "main"])
        if result.returncode != 0:
            print("Git pull failed, re-cloning...")
            os.chdir("..")
            shutil.rmtree(local_dir)
            run(["git", "clone", remote_repo, local_dir])
        else:
            os.chdir(local_dir)
    else:
        print("Cloning repository...")
        run(["git", "clone", remote_repo, local_dir])
        os.chdir(local_dir)

    subprocess.run(["chmod", "-R", "755", "."], check=True)
    print("Done!")
    return 0


if __name__ == "__main__":
    exit(main())
