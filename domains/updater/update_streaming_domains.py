#!/usr/bin/env python3
"""
Update streaming_domains_whitelist.txt with domains scraped from known sources.
Always backs up the previous file before overwriting.
"""
import os
import shutil
import urllib.request
import urllib.error
from datetime import datetime

DOMAINS_FILE = os.path.join(os.path.dirname(__file__), "..", "streaming_domains_whitelist.txt")
BACKUP_DIR = os.path.join(os.environ.get("HOME", "/tmp"), ".hermes", "backups", "domains_backup")
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(BASE_DIR)
DOMAINS_FILE = os.path.join(PARENT_DIR, "streaming_domains_whitelist.txt")

SOURCES = {
    "Netflix": "https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/domains/streaming_domains_whitelist.txt",
    "Crunchyroll": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
    "Peacock": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
    "PiHole Streaming List": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
}

def fetch_text(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except (urllib.error.URLError, Exception) as e:
        print(f"WARN: fetch failed for {url}: {e}")
        return ""

def backup_file(path):
    os.makedirs(BACKUP_DIR, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(BACKUP_DIR, f"streaming_domains_whitelist.txt.{timestamp}")
    shutil.copy2(path, backup_path)
    print(f"Backup saved to {backup_path}")

def main():
    domains = set()
    comments = []

    for name, url in SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if not text:
            continue

        for line in text.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            # Extract domain-like tokens
            parts = line.replace("^", "").replace("|", "").replace("/", "").split()
            for part in parts:
                if "." in part and "/" not in part and " " not in part:
                    clean = part.lstrip("*")
                    if clean and not clean[0].isdigit:
                        domains.add(clean)

    # Hardcoded core domains to always keep
    core_domains = [
        "netflix.com", "nflxext.com", "nflximg.com", "nflxso.net", "nflxvideo.net",
        "netflix.net", "hbomax.com", "hbo.com", "warnermediacdn.com", "wbdstreaming.com",
        "max.com", "wmcdp.io", "wmcdp.com", "hulu.com", "hulustream.com", "huluim.com",
        "huluad.com", "vortex.hulu.com", "doppler.hulu.com", "conviva.com",
        "disneyplus.com", "disney.com", "bamgrid.com", "disneystreaming.com", "dssott.com",
        "paramountplus.com", "cbsivideo.com", "cbsaavideo.com", "cbs.com", "viacomcbs.com",
        "peacocktv.com", "nbc.com", "nbcuni.com", "nbcucdn.com",
        "tubitv.com", "fox.com", "foxsports.com", "fubo.tv", "pluto.tv",
        "roku.com", "rokutime.com", "therokuchannel.roku.com",
        "crunchyroll.com", "vrv.co", "funimation.com",
        "aiv-cdn.net", "primevideo.com", "amazon.com", "amazonaws.com",
        "cloudfront.net", "s3.amazonaws.com", "atv-ext.amazon.com",
        "imdb.com", "imdbtv.com", "freevee.com",
        "apple.com", "apple-dns.net", "mzstatic.com",
        "apple-tv-plus.com", "tv.apple.com",
        "vudu.com", "moviefone.com", "mubi.com", "shudder.com",
        "britbox.com", "acorn.tv", "sling.com", "philo.com", "xumo.com",
        "discoveryplus.com", "dplay.com",
        "espn.com", "espncdn.com", "espn.net",
        "mlb.com", "mlbstatic.com", "nba.com", "nfl.com", "nhl.com", "nhlstatic.com",
        "spotify.com", "scdn.co", "pandora.com", "soundcloud.com",
        "deezer.com", "tidal.com",
    ]
    domains.update(core_domains)

    # Always back up before writing
    if os.path.exists(DOMAINS_FILE):
        backup_file(DOMAINS_FILE)

    sorted_domains = sorted(d for d in domains if not d.startswith("1") and not d.startswith("2") and not d.startswith("3") and not d.startswith("4") and not d.startswith("5") and not d.startswith("6") and not d.startswith("7") and not d.startswith("8") and not d.startswith("9"))
    ip_cidrs = sorted(d for d in domains if any(c.isdigit() for c in d))

    with open(DOMAINS_FILE, "w") as f:
        for domain in sorted_domains:
            f.write(domain + "\n")
        f.write("\n# IP Ranges / CIDRs\n")
        for ip in ip_cidrs:
            f.write(ip + "\n")

    print(f"Domains updated: {len(sorted_domains)} domains + {len(ip_cidrs)} IPs")

if __name__ == "__main__":
    main()
