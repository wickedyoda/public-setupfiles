#!/usr/bin/env python3
"""
Update domain lists by merging new scraped domains with existing file contents.
Never deletes existing domains - only appends.

Usage:
    python3 update_domains.py [--streaming] [--social] [--all]
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
BAMBOO_FILE = os.path.join(PARENT_DIR, "bamboo_domains.txt")
BYPASS_FILE = os.path.join(PARENT_DIR, "bypass_sites.txt")
PORN_FILE = os.path.join(PARENT_DIR, "known_porn_domains.txt")

STREAMING_SOURCES = {
    "Peacock": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
    "Crunchyroll": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
    "Ozankiratli Streaming": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
}

SOCIAL_SOURCES = {
    "Ozankiratli Social": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
}

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

def load_existing(path):
    """Load existing domains from file (skip IPs, comments, blanks)"""
    if not os.path.exists(path):
        return set()
    domains = set()
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "/" in line:
                continue
            domains.add(line.lower())
    return domains

def extract_domains(text):
    domains = set()
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        clean = line.replace("||", "").replace("^", "").replace("|", "").replace("$", "").replace("/", "")
        if " " in clean:
            clean = clean.split()[0]
        if "." in clean and not clean[0].isdigit:
            domains.add(clean.lstrip("*").lower())
    return domains

def save_domains(path, domains, include_ips=None):
    domains_only = sorted(d for d in domains if "/" not in d and not any(c.isdigit() for c in d[:d.find(".") if "." in d else 0]))
    ips = [d for d in domains if "/" in d or any(c.isdigit() for c in d[:15])]
    unique_ips = sorted(set(ips + (include_ips or [])))
    
    with open(path, "w") as f:
        for d in domains_only:
            if d and not d.startswith("0"):  # filter out IP-like prefixes
                f.write(d + "\n")
        f.write("\n# IP Ranges / CIDRs\n")
        for ip in unique_ips:
            f.write(ip + "\n")

def update_streaming():
    existing = load_existing(STREAMING_FILE)
    new_domains = set(existing)
    
    for name, url in STREAMING_SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped = extract_domains(text)
            new_domains.update(scraped)
    
    backup_file(STREAMING_FILE, "streaming_domains_whitelist.txt")
    save_domains(STREAMING_FILE, new_domains)
    print(f"Streaming domains: {len(new_domains)} total")

def update_social():
    existing = load_existing(SOCIAL_FILE)
    new_domains = set(existing)
    
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
                    new_domains.add(d)
    
    backup_file(SOCIAL_FILE, "social_media.txt")
    save_domains(SOCIAL_FILE, new_domains)
    print(f"Social media domains: {len(new_domains)} total")

def update_bypass():
    existing = load_existing(BYPASS_FILE)
    new_domains = set(existing)
    
    # Merge streaming + social into bypass_sites.txt
    streaming = load_existing(STREAMING_FILE)
    social = load_existing(SOCIAL_FILE)
    new_domains.update(streaming)
    new_domains.update(social)
    
    backup_file(BYPASS_FILE, "bypass_sites.txt")
    save_domains(BYPASS_FILE, new_domains)
    print(f"Bypass sites: {len(new_domains)} total")

def update_porn():
    existing = load_existing(PORN_FILE)
    # This would require dedicated porn domain sources
    # For now, just ensure file exists
    if not os.path.exists(PORN_FILE):
        print("PORN_FILE does not exist - skipping (would need dedicated sources)")
        return
    backup_file(PORN_FILE, "known_porn_domains.txt")
    print(f"Porn domains preserved: {len(existing)} total")

def update_bamboo():
    existing = load_existing(BAMBOO_FILE)
    print(f"Bamboo domains preserved: {len(existing)} total")

def main():
    parser = argparse.ArgumentParser(description="Update domain lists - never delete!")
    parser.add_argument("--streaming", action="store_true", help="Update streaming only")
    parser.add_argument("--social", action="store_true", help="Update social media only")
    parser.add_argument("--bypass", action="store_true", help="Update bypass_sites (combines streaming+social)")
    parser.add_argument("--porn", action="store_true", help="Update porn domains")
    parser.add_argument("--bamboo", action="store_true", help="Update bamboo domains")
    parser.add_argument("--all", action="store_true", help="Update all lists")
    args = parser.parse_args()

    if args.all or not any([args.streaming, args.social, args.bypass, args.porn, args.bamboo]):
        update_streaming()
        update_social()
        update_bypass()
        update_porn()
        update_bamboo()
    else:
        if args.streaming: update_streaming()
        if args.social: update_social()
        if args.bypass: update_bypass()
        if args.porn: update_porn()
        if args.bamboo: update_bamboo()

if __name__ == "__main__":
    main()