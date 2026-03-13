# COST_GUARDRAILS.md

## Default rule

Do not enable or use paid providers unless the user explicitly asks and understands the likely cost path.

## Current stance

- Keep `web_search` disabled until a key is intentionally configured
- Prefer local docs, local files, and free/read-only checks first
- Do not start recurring jobs that might call paid APIs without approval
- Do not switch models/providers behind the user's back

## Known OpenClaw cost footguns to watch

### 1. Adaptive routing can cost more, not less

Public OpenClaw PR discussion shows adaptive routing may call a cheap/local model first and then re-run with a cloud model if validation fails. That is useful, but if both legs are paid, the same user task can incur two model runs.

Control:
- Leave adaptive routing off unless you intentionally set a local-first + cloud-escalation plan
- If enabled, cap escalations and make sure the first leg is truly cheap/free

### 2. TTS provider selection can become paid automatically if keys exist

Local docs show TTS prefers `openai` when a key is available, then `elevenlabs`, otherwise `edge`.

Control:
- If cost matters, force TTS provider to `edge`
- Do not enable summary features that depend on a paid provider unless asked

### 3. Media understanding and audio transcription can hit provider APIs

Local docs show media understanding can use provider APIs such as OpenAI, Google, Deepgram, or Mistral when configured.

Control:
- Keep provider-based media understanding off unless explicitly needed
- Prefer CLI/local fallbacks when available

### 4. Search and external research can become paid once API keys are present

Even tools that seem small can spend money if a paid search/model provider is configured.

Control:
- Keep external search keys absent or disabled by default
- Use free public endpoints and local docs first

## Operator habit

Before enabling a provider, answer these four questions:

1. Is this provider paid or quota-limited?
2. What exact feature will call it?
3. Is there a free/local fallback?
4. Can the same task accidentally trigger it twice?
