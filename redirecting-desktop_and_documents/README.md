# redirecting-desktop_and_documents

## Overview

Script to redirect Windows Desktop and Documents folders to OneDrive.

---

## Files

| File | Description |
|------|-------------|
| `redirectfiles.sh` | Redirect Desktop/Documents to OneDrive |

---

## Usage

Run as Administrator on Windows:

```batch
# Double-click or run from Command Prompt
redirectfiles.sh
```

---

## What It Does

1. Creates backup of existing folders
2. Creates symbolic links to OneDrive equivalents
3. Moves existing content to OneDrive

---

## Prerequisites

- OneDrive must be installed and configured
- Desktop/Documents must not be in cloud sync yet
- Run as Administrator

---

## Safety

- Creates backups: `~/Desktop.backup`, `~/Documents.backup`
- If symlinks already exist, skips the operation
- Test on a non-critical folder first