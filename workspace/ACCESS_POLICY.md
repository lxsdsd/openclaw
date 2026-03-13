# ACCESS_POLICY.md

## Default rule

Security first. Do not read sensitive content unless the user explicitly asks for that exact class of data and understands the risk.

## Forbidden by default

- Password stores, secret managers, 2FA seed exports, SSH private keys, age keys, GPG private keys
- `.env` files, API keys, tokens, cookies, session exports, OAuth dumps
- WeChat-related files, databases, exports, caches, attachments, and backups
- Browser profiles that may contain saved passwords, cookies, sessions, payment data, or personal identities
- Private message databases and local chat exports unless the user explicitly asks for that source
- Any file whose purpose is clearly credentials, auth, billing, or personal identity recovery

## Ask first

- Email archives, cloud drive exports, note-app databases, desktop messaging stores
- Financial records, invoices, tax files, bank exports, receipts, contracts
- System logs outside the OpenClaw workspace
- Any directory that looks user-personal rather than task-specific

## Usually OK

- Files inside the OpenClaw workspace that are clearly task artifacts, notes, docs, scripts, or code
- Feishu-related project files when needed for a task, unless they contain secrets or exports
- Public documentation, local docs, code, tests, and configuration that does not reveal secrets

## If accidental access happens

- Stop immediately
- Tell the user what category of secret/private data was touched
- Give the path or location category
- Do not repeat the secret contents unless the user explicitly asks

## Cost-control rule

- Do not enable paid providers or recurring jobs that can spend money without explicit approval.
- Prefer local docs and free/read-only checks first.
- When a provider has free credit but can still incur charges, set a hard budget/limit before enabling it.
