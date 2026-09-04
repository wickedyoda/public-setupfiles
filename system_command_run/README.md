# system_command_run

## Overview

Run commands across multiple machines via SSH using a machine list file.

---

## Files

| File | Description |
|------|-------------|
| `Run_command_on_machines.sh` | Bash script for SSH command execution |
| `run_command_on_machines.py'` | Python script (alternate, may have bugs) |
| `run_command_on_machines_Keys.py'` | SSH key-based version |
| `machines.txt` | Machine list (host, user, password) |

---

## Usage

### Bash Script

```bash
# Edit machines.txt with target hosts
# Format: HOST USER PASSWORD (password can be empty for key auth)
./system_command_run/Run_command_on_machines.sh
```

**Prompt:**
```
Enter command to execute:
```

**Example:**
```
sudo apt update
```

---

## Configuration

### machines.txt

Format: `HOST USER PASSWORD`

```
docker1 root 
docker2 root YOURPASSWORD
192.168.1.100 admin PASSWORD
```

Leave password empty to use SSH keys.

---

## Security Notes

- **Never commit machines.txt with real passwords**
- Use SSH keys for better security
- Restrict machine list to trusted hosts
- Keys version (`run_command_on_machines_Keys.py'`) uses key-based auth

---

## Alternative: Python Keys Version

```bash
python3 system_command_run/run_command_on_machines_Keys.py'
```

Uses paramiko with key-based SSH authentication.

---

## Related

- Check disk usage across machines
- Restart services on multiple hosts
- Run maintenance scripts remotely