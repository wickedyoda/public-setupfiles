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
    "Peacock": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
    "Crunchyroll": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
}

SOCIAL_SOURCES = {
    "PiHole Social": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
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

def is_ip_or_cidr(line):
    """Check if a line is an IP address or CIDR range"""
    ip_cidr_re = re.compile(r'^(\d{1,3}\.){3}\d{1,3}(/\d+)?$')
    return bool(ip_cidr_re.match(line))

def is_domain(line):
    """Check if a line is a valid domain (not an IP, not empty, not a comment)"""
    if not line or line.startswith("#"):
        return False
    if is_ip_or_cidr(line):
        return False
    return "." in line

def load_existing(path):
    """Load existing domains and IPs from file"""
    domains = set()
    ips = set()
    if not os.path.exists(path):
        return domains, ips
    with open(path, "r") as f:
        for line in f:
            line = line.strip().lower()
            if not line or line.startswith("#"):
                continue
            if is_ip_or_cidr(line):
                ips.add(line)
            else:
                domains.add(line)
    return domains, ips

def extract_domains(text):
    domains = set()
    ips = set()
    ip_re = re.compile(r'^(\d{1,3}\.){3}\d{1,3}(/\d+)?$')
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        clean = line.replace("||", "").replace("^", "").replace("|", "").replace("$", "").replace("/", "")
        if " " in clean:
            clean = clean.split()[0]
        clean = clean.lstrip("*").lower()
        if not clean:
            continue
        if ip_re.match(clean):
            ips.add(clean)
        elif "." in clean:
            domains.add(clean)
    return domains, ips

def save_domains(path, domains, ips):
    """Save domains and IPs separately, preserving all entries"""
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
            all_domains.update(scraped_domains)
            all_ips.update(scraped_ips)
    
    backup_file(STREAMING_FILE, "streaming_domains_whitelist.txt")
    save_domains(STREAMING_FILE, all_domains, all_ips)
    print(f"Streaming: {len(all_domains)} domains + {len(all_ips)} IPs")

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
                             "imgur", "vimeo", "tiktok"]
            for d in scraped_domains:
                if any(kw in d for kw in social_keywords):
                    all_domains.add(d)
    
    backup_file(SOCIAL_FILE, "social_media.txt")
    save_domains(SOCIAL_FILE, all_domains, all_ips)
    print(f"Social media: {len(all_domains)} domains + {len(all_ips)} IPs")

def update_bypass():
    streaming_domains, streaming_ips = load_existing(STREAMING_FILE)
    social_domains, social_ips = load_existing(SOCIAL_FILE)
    
    all_domains = streaming_domains | social_domains
    all_ips = streaming_ips | social_ips
    
    backup_file(BYPASS_FILE, "bypass_sites.txt")
    save_domains(BYPASS_FILE, all_domains, all_ips)
    print(f"Bypass sites: {len(all_domains)} domains + {len(all_ips)} IPs")

def update_porn():
    domains, ips = load_existing(PORN_FILE)
    backup_file(PORN_FILE, "known_porn_domains.txt")
    # Just preserve existing - no scraping source configured
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