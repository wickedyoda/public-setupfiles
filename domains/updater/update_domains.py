#!/usr/bin/env python3
"""
Update streaming_domains_whitelist.txt and social_media.txt with domains
scraped from known sources. Always backs up the previous file before overwriting.

Usage:
    python3 update_domains.py                    # Update all lists
    python3 update_domains.py --streaming        # Update streaming only
    python3 update_domains.py --social            # Update social media only
    python3 update_domains.py --all               # Update all lists
"""
import os
import shutil
import argparse
import urllib.request
import urllib.error
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(BASE_DIR)
BACKUP_DIR = os.path.join(os.environ.get("BACKUP_DIR", os.path.expanduser("~/.hermes/backups/domains_backup")))

STREAMING_FILE = os.path.join(PARENT_DIR, "streaming_domains_whitelist.txt")
SOCIAL_FILE = os.path.join(PARENT_DIR, "social_media.txt")

STREAMING_SOURCES = {
    "Netflix": "https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/domains/streaming_domains_whitelist.txt",
    "Crunchyroll": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
    "Peacock": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
    "PiHole Streaming List": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
}

SOCIAL_SOURCES = {
    "PiHole Social": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
}

# Known social media domains (core baseline)
CORE_SOCIAL_DOMAINS = [
    "facebook.com", "fb.com", "fbcdn.net",
    "instagram.com", "cdninstagram.com",
    "twitter.com", "x.com", "twimg.com",
    "tiktok.com", "tiktokcdn.com", "tiktokv.com", "bytedance.com", "bytedancecdn.com",
    "linkedin.com", "licdn.com",
    "snapchat.com", "snap.com", "sc-cdn.net",
    "threads.net",
    "mastodon.social", "mastodon.online",
    "reddit.com", "redd.it", "redditmedia.com",
    "discord.com", "discordapp.com",
    "pinterest.com", "pinimg.com",
    "youtube.com", "youtu.be",
    "twitch.tv", "ttvnw.net",
    "vk.com", "vkuser.net",
    "tumblr.com",
    "medium.com", "cdn-medium.com",
    "clubhouse.com",
    "messenger.com", "whatsapp.com", "telegram.org",
    "quora.com", "quoracdn.net",
    "imgur.com", "imgur.io",
    "vimeo.com", "vimeocdn.com",
]

# Core streaming domains
CORE_STREAMING_DOMAINS = [
    "netflix.com", "nflxext.com", "nflximg.com", "nflxso.net", "nflxvideo.net",
    "hbomax.com", "hbo.com", "max.com", "wbdstreaming.com",
    "disneyplus.com", "disney.com", "bamgrid.com", "dssott.com",
    "hulu.com", "hulustream.com", "conviva.com",
    "paramountplus.com", "cbs.com", "peacocktv.com",
    "primevideo.com", "amazon.com", "aiv-cdn.net",
    "crunchyroll.com", "vrv.co", "funimation.com",
    "roku.com", "roku.com", "rokutime.com",
    "spotify.com", "pandora.com", "soundcloud.com",
    "tubitv.com", "pluto.tv", "crunchyroll.com",
    "apple.com", "tv.apple.com",
    "espn.com", "mlb.com", "nba.com", "nfl.com",
]

CORE_STREAMING_IPS = [
    "31.13.64.0/18", "45.57.0.0/17", "66.220.144.0/20",
    "34.192.0.0/10", "52.0.0.0/11",
    "17.0.0.0/8", "224.0.0.0/4",
]


def fetch_text(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except Exception as e:
        print(f"WARN: fetch failed for {url}: {e}")
        return ""


def backup_file(path, label):
    if not os.path.exists(path):
        return
    os.makedirs(BACKUP_DIR, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(BACKUP_DIR, f"{label}.{timestamp}")
    shutil.copy2(path, backup_path)
    print(f"Backup saved to {backup_path}")


def extract_domains(text):
    domains = set()
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        clean = line.replace("||", "").replace("^", "").replace("|", "").replace("$", "").replace("/", "")
        if " " in clean:
            clean = clean.split()[0]
        if "." in clean and "/" not in clean and not clean[0].isdigit:
            domains.add(clean.lstrip("*"))
    return domains


def update_streaming():
    domains = set()
    for name, url in STREAMING_SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            domains.update(extract_domains(text))
    domains.update(CORE_STREAMING_DOMAINS)

    backup_file(STREAMING_FILE, "streaming_domains_whitelist.txt")

    domains_only = sorted(d for d in domains if "/" not in d)
    ip_cidrs = sorted(set(d for d in domains if "/" in d) | set(CORE_STREAMING_IPS))

    with open(STREAMING_FILE, "w") as f:
        for domain in domains_only:
            f.write(domain + "\n")
        f.write("\n# IP Ranges / CIDRs\n")
        for ip in ip_cidrs:
            f.write(ip + "\n")

    print(f"Streaming domains updated: {len(domains_only)} domains + {len(ip_cidrs)} IPs")


def update_social():
    domains = set(CORE_SOCIAL_DOMAINS)
    for name, url in SOCIAL_SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped = extract_domains(text)
            social_keywords = ["facebook", "instagram", "twitter", "tiktok", "linkedin",
                             "snapchat", "threads", "mastodon", "reddit", "discord",
                             "pinterest", "youtube", "twitch", "vk", "tumblr",
                             "medium", "clubhouse", "messenger", "telegram", "quora",
                             "imgur", "vimeo", "tiktok"]
            for d in scraped:
                if any(kw in d for kw in social_keywords):
                    domains.add(d)

    backup_file(SOCIAL_FILE, "social_media.txt")

    sorted_domains = sorted(domains)
    with open(SOCIAL_FILE, "w") as f:
        for domain in sorted_domains:
            f.write(domain + "\n")

    print(f"Social media domains updated: {len(sorted_domains)} domains")


def main():
    parser = argparse.ArgumentParser(description="Update domain lists")
    parser.add_argument("--streaming", action="store_true", help="Update streaming only")
    parser.add_argument("--social", action="store_true", help="Update social media only")
    parser.add_argument("--all", action="store_true", help="Update all lists")
    args = parser.parse_args()

    if args.all or not (args.streaming or args.social):
        update_streaming()
        update_social()
    else:
        if args.streaming:
            update_streaming()
        if args.social:
            update_social()


if __name__ == "__main__":
    main()