# Email Domains Block/Allow Lists

Domain filtering policies for email servers.

## Overview

These lists are used for SMTP-level domain filtering on email servers like Postfix, Exim, or Microsoft Exchange.

## Files

| File | Description |
|------|-------------|
| `blocked_domains.md` | Domains to reject completely |
| `email_domain_allow_block_list.md` | Comprehensive allow/block rules |

## Usage

### Postfix Example

```postfix
# /etc/postfix/access
blocked-domain.com    REJECT
spam-domain.org       REJECT

# Hash and load
postmap /etc/postfix/access
postfix reload
```

### Exim Example

```exim
# /etc/exim4/conf.d/acl/acl_check_rcpt
deny
  domains = +blocked_domains
  message = Domain blocked
```

### Microsoft Exchange

Use Transport Rules in Exchange Admin Center:
- Condition: Sender domain matches blocked list
- Action: Reject message

## Maintenance

Update lists by pulling from this repository and refreshing your server's access database.

## Categories

- Spam senders
- Known malicious domains
- Disposable email providers
- Competitor/whois domains