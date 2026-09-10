#!/usr/bin/env python3
"""
Update domain lists by merging new scraped domains with existing file contents.
Never deletes existing domains - only appends.

Usage:
    python3 update_domains.py [--streaming] [--social] [--bypass] [--porn] [--all]
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
BYPASS_FILE = os.path.join(PARENT_DIR, "bypass_sites.txt")
PORN_FILE = os.path.join(PARENT_DIR, "known_porn_domains.txt")

SOURCES_BY_TYPE = {
    "streaming": {
        "Peacock Filterlist": "https://raw.githubusercontent.com/lit-bg/Peacock/refs/heads/main/filterlist.txt",
        "Crunchyroll Endpoints": "https://gist.githubusercontent.com/NicmeisteR/cdc4867cf256c568b6a7f1844ce229f2/raw",
    },
    "social": {
        "PiHole Social List": "https://raw.githubusercontent.com/ozankiratli/801ba17705e7f2a904d2e443af5a64f8/raw/436fa9f0c151afc15a601edf77c796b2a6de9be4/PiHoleStreamingLists.md",
    },
    "bypass": {
        "OnlyFans": "https://raw.githubusercontent.com/onlyfans/onlyfans.com/master/public_data.json",
        "Fansly": "https://raw.githubusercontent.com/fansly/fansly-data/main/domains.txt",
    },
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


DOMAIN_RE = re.compile(
    r'^(?=.{1,253}$)'
    r'([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+'
    r'[a-zA-Z]{2,63}$'
)


def is_valid_domain(line):
    """Validate a line is a proper domain (not code, IPs, or junk).
    Used ONLY for extracting from scraped text - never to delete existing entries."""
    if not line or len(line) < 4 or len(line) > 253:
        return False
    if line.startswith("#"):
        return False
    if re.match(r'^(\d{1,3}\.){3}\d{1,3}', line):
        return False
    if "/" in line and re.search(r'\d+\.\d+\.\d+\.\d+/\d+', line):
        return False
    if not DOMAIN_RE.match(line):
        return False
    junk_keywords = ["const", "var ", "let ", "function", "return", "if(", "else",
                     ".catch", ".then", ".map(", ".filter(", ".reduce(", "import", "export",
                     "class", "extends", "=>"]
    if any(kw in line for kw in junk_keywords):
        return False
    return True


def is_ip_or_cidr(line):
    ip_cidr_re = re.compile(r'^(\d{1,3}\.){3}\d{1,3}(/\d+)?$')
    return bool(ip_cidr_re.match(line))


def load_all_lines(path):
    """Load ALL lines from a file, preserving order, comments, IPs, junk - EVERYTHING."""
    lines = []
    if not os.path.exists(path):
        return lines
    with open(path, "r") as f:
        for line in f:
            lines.append(line.rstrip("\n"))
    return lines


def load_domains_and_ips(path):
    """Extract domains and IPs from existing file for dedup comparison.
    Returns two sets: domains (all non-IP non-comment lines) and ips."""
    domains = set()
    ips = set()
    if not os.path.exists(path):
        return domains, ips
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):
                continue
            if is_ip_or_cidr(line):
                ips.add(line.lower())
            else:
                domains.add(line.lower())
    return domains, ips


def extract_domains(text):
    """Extract valid domains and IPs from scraped text only.
    Used for APPENDING new entries - never to filter existing."""
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


def save_domains(path, all_lines, new_domains, new_ips):
    """Save domains preserving ALL original content plus new entries.
    NEVER removes anything - just appends new domains/ips at the end."""
    # Write all original lines first (preserving comments, order, IPs)
    out_lines = list(all_lines)
    
    # Add new domains and IPs
    existing_lower = {l.strip().lower() for l in out_lines if l.strip() and not l.strip().startswith("#")}
    
    for d in sorted(new_domains):
        if d.lower() not in existing_lower:
            out_lines.append(d)
            existing_lower.add(d.lower())
    
    for ip in sorted(new_ips):
        ip_lower = ip.lower()
        if ip_lower not in existing_lower:
            # Find IP section or add after last domain
            ip_section_found = False
            for i, line in enumerate(out_lines):
                if line.strip().startswith("# IP Ranges / CIDRs") or line.strip().startswith("# IP"):
                    ip_section_found = True
                    # Add after the header
                    if i + 1 < len(out_lines) and not out_lines[i+1].strip().startswith("#"):
                        out_lines.insert(i + 1, ip)
                    else:
                        out_lines.append(ip)
                    break
            if not ip_section_found:
                # Add IP section at end
                out_lines.append("")
                out_lines.append("# IP Ranges / CIDRs")
                out_lines.append(ip)
            existing_lower.add(ip_lower)
    
    with open(path, "w") as f:
        for line in out_lines:
            f.write(line + "\n")
    
    return len(out_lines)


def update_streaming():
    existing_lines = load_all_lines(STREAMING_FILE)
    existing_domains, existing_ips = load_domains_and_ips(STREAMING_FILE)
    all_domains = set(existing_domains)
    all_ips = set(existing_ips)

    for name, url in SOURCES_BY_TYPE["streaming"].items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped_domains, scraped_ips = extract_domains(text)
            added = len(scraped_domains)
            all_domains.update(scraped_domains)
            all_ips.update(scraped_ips)
            print(f"  Scraped {added} new domains from {name}")

    backup_file(STREAMING_FILE, "streaming_domains_whitelist")
    new_count = save_domains(STREAMING_FILE, existing_lines, all_domains - existing_domains, all_ips - existing_ips)
    print(f"Streaming: {len(all_domains)} domains + {len(all_ips)} IPs total")


def update_social():
    existing_lines = load_all_lines(SOCIAL_FILE)
    existing_domains, existing_ips = load_domains_and_ips(SOCIAL_FILE)
    all_domains = set(existing_domains)
    all_ips = set(existing_ips)

    for name, url in SOURCES_BY_TYPE["social"].items():
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

    backup_file(SOCIAL_FILE, "social_media")
    new_count = save_domains(SOCIAL_FILE, existing_lines, all_domains - existing_domains, all_ips - existing_ips)
    print(f"Social media: {len(all_domains)} domains + {len(all_ips)} IPs total")


def update_bypass():
    """Update bypass_sites.txt from social lists plus ONLYFANS/FANSLY"""
    social_domains, social_ips = load_domains_and_ips(SOCIAL_FILE)
    existing_lines = load_all_lines(BYPASS_FILE)
    existing_domains_set = {l.strip().lower() for l in existing_lines if l.strip() and not l.strip().startswith("#")}
    
    all_domains = social_domains.copy()
    all_ips = social_ips.copy()
    
    # Add OnlyFans/Fansly from their own sources
    for name, url in SOURCES_BY_TYPE["bypass"].items():
        print(f"Fetching {name}...")
        text = fetch_text(url)
        if text:
            scraped_domains, scraped_ips = extract_domains(text)
            added_d = len(scraped_domains)
            added_i = len(scraped_ips)
            all_domains.update(scraped_domains)
            all_ips.update(scraped_ips)
            print(f"  Scraped {added_d} domains + {added_i} IPs from {name}")

    new_domains = all_domains - existing_domains_set
    new_ips = all_ips - {ip.lower() for ip in existing_domains_set if is_ip_or_cidr(ip.lower())}

    backup_file(BYPASS_FILE, "bypass_sites")
    new_count = save_domains(BYPASS_FILE, existing_lines, new_domains, new_ips)
    print(f"Bypass sites: {len(existing_domains_set) + len(new_domains)} domains + {len(new_ips)} new IPs total")


def update_porn():
    existing_lines = load_all_lines(PORN_FILE)
    existing_domains, existing_ips = load_domains_and_ips(PORN_FILE)
    backup_file(PORN_FILE, "known_porn_domains")
    save_domains(PORN_FILE, existing_lines, set(), set())
    print(f"Porn domains preserved: {len(existing_domains)} domains + {len(existing_ips)} IPs")


def main():
    parser = argparse.ArgumentParser(description="Update domain lists - never delete!")
    parser.add_argument("--streaming", action="store_true", help="Update streaming only")
    parser.add_argument("--social", action="store_true", help="Update social media only")
    parser.add_argument("--bypass", action="store_true", help="Update bypass_sites (combines social+porn+OnlyFans/Fansly)")
    parser.add_argument("--porn", action="store_true", help="Update porn domains")
    parser.add_argument("--all", action="store_true", help="Update all lists")
    args = parser.parse_args()

    if args.all or not any([args.streaming, args.social, args.bypass, args.porn]):
        update_streaming()
        update_social()
        update_bypass()
        update_porn()
    else:
        if args.streaming: update_streaming()
        if args.social: update_social()
        if args.bypass: update_bypass()
        if args.porn: update_porn()

if __name__ == "__main__":
    main()