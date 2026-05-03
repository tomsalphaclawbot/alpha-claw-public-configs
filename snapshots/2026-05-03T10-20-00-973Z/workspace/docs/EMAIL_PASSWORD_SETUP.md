# Email + Password Setup (Alpha)

## What is already done

- Installed `rbw` (Bitwarden CLI): `rbw 1.15.0`
- Installed `gog` (Gmail API CLI helper): `gog 0.11.0`
- Researched ClawHub skills:
  - `bitwarden` (uses `rbw`)
  - `gmail-oauth` (OAuth helper with `gog`)

## Next steps requiring Tom

### 1) Bitwarden account bootstrap

Run interactively on the Mac:

```bash
rbw config set email YOUR_BITWARDEN_EMAIL
# optional for vaultwarden self-hosted:
# rbw config set baseurl https://vault.example.com
rbw login
rbw unlock
```

Then store Gmail credential:

```bash
rbw add
```

Suggested item name: `gmail/tomsalphaclawbot`

### 2) Gmail API OAuth setup

You need a Google Cloud OAuth Desktop app credential JSON.

Then run:

```bash
gog auth credentials /path/to/client_secret.json
gog auth keyring file
export GOG_KEYRING_PASSWORD='[REDACTED_SECRET]'
```

Generate auth URL:

```bash
gog auth oauth --account [REDACTED_EMAIL] --scopes gmail.modify --redirect-uri http://localhost --print-auth-url
```

Open URL, approve, copy `code=...` from localhost redirect URL, then exchange token:

[REDACTED_SECRET]
gog auth exchange --account [REDACTED_EMAIL] --code 'PASTE_CODE' --redirect-uri http://localhost
```

Verify Gmail access:

```bash
gog gmail search 'is:unread' --max 5 --account [REDACTED_EMAIL]
```

## Security notes

- Prefer OAuth tokens + Bitwarden vault items over raw plaintext passwords in chat.
- If sharing a password with Alpha, do it once, then immediately rotate/confirm and store in Bitwarden.
- Keep Google OAuth app in Published mode to avoid 7-day token expiry.
