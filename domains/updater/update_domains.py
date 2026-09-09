#!/usr/bin/env python3
"""
Update domain lists by merging new scraped domains with existing file contents.
Never deletes existing domains - only appends.

Usage:
    python3 update_domains.py [--streaming] [--social] [--bypass] [--porn] [--bamboo] [--all]
"""
import os
import shutil
import argparse
import re
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
    "Peacock Filterlist": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
    "Crunchyroll Endpoints": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
}

SOCIAL_SOURCES = {
    "PiHole Streaming List": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
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


# Strict domain validation: must match valid domain pattern
DOMAIN_RE = re.compile(
    r'^(?=.{1,253}$)'
    r'([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+'  # labels
    r'[a-zA-Z]{2,63}$'
)

def is_valid_domain(line):
    """Validate a line is a proper domain (not code, IPs, or junk)"""
    if not line or len(line) < 4 or len(line) > 253:
        return False
    if line.startswith("#"):
        return False
    if re.match(r'^(\d{1,3}\.){3}\d{1,3}', line):
        return False
    if "/" in line and re.search(r'\d+\.\d+\.\d+\.\d+/\d+', line):
        return False
    # Reject anything that doesn't look like a domain
    if not DOMAIN_RE.match(line):
        return False
    # Reject known junk patterns from JS/CSS
    junk_keywords = ["const", "var ", "let ", "function", "return", "if(", "else",
                     ".catch", ".then", ".map(", ".filter(", ".reduce(", "import", "export",
                     "class", "extends", "=>", "=>" ]
    if any(kw in line for kw in junk_keywords):
        return False
    return True


def is_ip_or_cidr(line):
    ip_cidr_re = re.compile(r'^(\d{1,3}\.){3}\d{1,3}(/\d+)?$')
    return bool(ip_cidr_re.match(line))


def load_existing(path):
    """Load existing domains and IPs, preserving EVERYTHING (never delete)."""
    domains = set()
    ips = set()
    if not os.path.exists(path):
        return domains, ips
    with open(path, "r") as f:
        for line in f:
            line = line.strip().lower()
            if not line:
                continue
            if line.startswith("#"):
                # Preserve comments
                domains.add(line)
                continue
            if is_ip_or_cidr(line):
                ips.add(line)
            else:
                # Preserve EVERYTHING else - even junk lines, per user requirement "never delete"
                domains.add(line)
    return domains, ips


def extract_domains(text):
    domains = set()
    ips = set()
    for line in text.splitlines():
        line = line.strip().lower()
        if not line or line.startswith("#"):
            continue
        # Handle AdBlock-style ||domain^ format
        if line.startswith("||"):
            clean = line[2:].split("^")[0].strip()
        else:
            clean = line.replace("|", "").replace("^", "").replace("$", "").strip()
        if " " in clean:
            clean = clean.split()[0]
        clean = clean.lstrip("*")
        if not clean:
            continue
        if is_ip_or_cidr(clean):
            ips.add(clean)
        elif is_valid_domain(clean):
            domains.add(clean)
    return domains, ips


def save_domains(path, domains, ips):
    """Save domains preserving original order of comments/sections"""
    sorted_domains = sorted(d for d in domains if not is_ip_or_cidr(d))
    sorted_ips = sorted(set(ips))

    with open(path, "w") as f:
        for d in sorted_domains:
            f.write(d + "\n")
        if sorted_ips:
            f.write("\n# IP Ranges / CIDRs\n")
            for ip in sorted_ips:
                f.write(ip + "\n")


def update_streaming():
    existing_domains, existing_ips = load_existing(STREAMING_FILE)
    all_domains = set(existing_domains)
    all_ips = set(existing_ips)

    for name, url in STREAMING_SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped_domains, scraped_ips = extract_domains(text)
            added = len(scraped_domains)
            all_domains.update(scraped_domains)
            all_ips.update(scraped_ips)
            print(f"  Scraped {added} new domains from {name}")

    backup_file(STREAMING_FILE, "streaming_domains_whitelist.txt")
    save_domains(STREAMING_FILE, all_domains, all_ips)
    print(f"Streaming: {len(all_domains)} domains + {len(all_ips)} IPs total")


def update_social():
    existing_domains, existing_ips = load_existing(SOCIAL_FILE)
    all_domains = set(existing_domains)
    all_ips = set(existing_ips)

    for name, url in SOCIAL_SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped_domains, scraped_ips = extract_domains(text)
            social_keywords = ["facebook", "instagram", "twitter", "tiktok", "linkedin",
                             "snapchat", "threads", "mastodon", "reddit", "discord",
                             "pinterest", "youtube", "twitch", "vk", "tumblr",
                             "medium", "clubhouse", "messenger", "telegram", "quora",
                             "imgur", "vimeo", "bluesky", "bsky"]
            added = 0
            for d in scraped_domains:
                if any(kw in d for kw in social_keywords):
                    all_domains.add(d)
                    added += 1
            print(f"  Scraped {added} new social domains from {name}")

    backup_file(SOCIAL_FILE, "social_media.txt")
    save_domains(SOCIAL_FILE, all_domains, all_ips)
    print(f"Social media: {len(all_domains)} domains + {len(all_ips)} IPs total")


def update_bypass():
    streaming_domains, streaming_ips = load_existing(STREAMING_FILE)
    social_domains, social_ips = load_existing(SOCIAL_FILE)
    all_domains = streaming_domains | social_domains
    all_ips = streaming_ips | social_ips
    backup_file(BYPASS_FILE, "bypass_sites.txt")
    save_domains(BYPASS_FILE, all_domains, all_ips)
    print(f"Bypass sites: {len(all_domains)} domains + {len(all_ips)} IPs total")


def update_porn():
    domains, ips = load_existing(PORN_FILE)
    backup_file(PORN_FILE, "known_porn_domains.txt")
    save_domains(PORN_FILE, domains, ips)
    print(f"Porn domains preserved: {len(domains)} domains + {len(ips)} IPs")


def update_bamboo():
    domains, ips = load_existing(BAMBOO_FILE)
    print(f"Bamboo domains preserved: {len(domains)} domains + {len(ips)} IPs")


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