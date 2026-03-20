# CONTEXT_COMPACTION_STATUS.md

Last updated: 2026-03-19 14:10 UTC

## Purpose

This file is the handoff note for context-overflow prevention on this machine.
Use it before changing compaction, pruning, memory flush, or restart behavior.

## Current environment snapshot

- Primary runtime model: `rightcode/gpt-5.4`
- Provider API mode: `openai-responses`
- Model context window: `128000`
- Current live session sample at check time: `73k / 128k` context, `0` compactions
- Current agent default compaction config is still minimal:

```json
{
  "compaction": {
    "mode": "safeguard"
  }
}
```

- QMD memory is enabled and working
- `session-memory` hook is ready
- Workspace root bootstrap docs are not tiny; approximate current sizes:
  - `AGENTS.md` ≈ 15 KB
  - `SOUL.md` ≈ 3.2 KB
  - `MEMORY.md` ≈ 4.7 KB
  - `HEARTBEAT.md` ≈ 1.6 KB

## Important environment-specific constraint

Do **not** blindly copy Anthropic-oriented pruning advice into this setup.

OpenClaw docs say `agents.defaults.contextPruning` currently applies to **Anthropic API calls** (and OpenRouter Anthropic models). The current runtime is `rightcode/gpt-5.4` over `openai-responses`, so `contextPruning` is **not the main lever** for this machine right now.

That means the best automatic compression path here is:

1. tune OpenClaw's own auto-compaction earlier
2. keep pre-compaction memory flush enabled and more deliberate
3. optionally test provider-side Responses compaction if the RightCode endpoint supports it
4. keep always-loaded workspace docs short and move dense state into handoff files

## What outside best practices converge on

Based on current 2025–2026 agent context-management writeups and docs, the consistent pattern is:

- multi-tier compression beats one giant emergency summary
- preserve exact identifiers, file paths, ports, IDs, and error strings during compaction
- compress earlier than the hard limit; do not wait for overflow
- write durable memory before compaction so important facts survive the shrink
- tool/search output bloat is usually the first thing to control
- anchored summaries outperform repeated full rewrites because they drift less
- long always-loaded instructions should stay minimal; detailed runbooks should move to on-demand files

## Best-fit plan for this machine

### Stage 1 — recommended now

Tune local OpenClaw compaction earlier and make the pre-compaction memory flush explicit.

Recommended config shape:

```json5
{
  agents: {
    defaults: {
      compaction: {
        mode: "safeguard",
        reserveTokensFloor: 32000,
        identifierPolicy: "strict",
        postCompactionSections: ["Session Startup", "Red Lines"],
        memoryFlush: {
          enabled: true,
          softThresholdTokens: 12000,
          systemPrompt: "Session nearing compaction. Preserve durable facts, decisions, IDs, and open tasks before history is compacted.",
          prompt: "Write lasting notes to memory/YYYY-MM-DD.md or MEMORY.md when appropriate. Preserve exact file paths, ports, IDs, unresolved blockers, and user preferences. Reply with NO_REPLY if nothing should be stored."
        }
      }
    }
  }
}
```

Why this fits this machine:

- `128k` context is large, but current sessions can still bloat quickly when tool output and operational notes accumulate
- `reserveTokensFloor: 32000` starts protecting headroom earlier than the default baseline
- `softThresholdTokens: 12000` makes memory flush happen before the final compaction boundary, not at the last second
- `identifierPolicy: strict` matters here because this workspace carries many file paths, model ids, ports, agent ids, hook names, and config keys

### Stage 2 — optional but promising

Test provider-side Responses compaction for `rightcode/gpt-5.4`.

Docs show OpenClaw can inject OpenAI-Responses-style `context_management` on compatible providers via model params.
For this machine, the test shape would be:

```json5
{
  agents: {
    defaults: {
      models: {
        "rightcode/gpt-5.4": {
          params: {
            responsesServerCompaction: true,
            responsesCompactThreshold: 90000
          }
        }
      }
    }
  }
}
```

Important caution:

- This is worth testing because the provider uses `openai-responses`
- But it should be treated as **compatibility-dependent**, not assumed safe just because the local docs mention Azure/OpenAI examples
- Validate with real sessions before depending on it

### Stage 3 — ongoing hygiene

Keep startup context lean.

For this environment, the easiest non-code win is:

- keep `AGENTS.md`, `MEMORY.md`, and `SOUL.md` concise
- move detailed incident state into dedicated handoff files like:
  - `SKILL_RUNTIME_STATUS.md`
  - `OPENCLAW_RUNTIME_STATUS.md`
  - `CONFIG_CHANGELOG.md`
  - this file

This reduces the amount of high-churn operational detail reintroduced into fresh sessions.

## What I do NOT recommend as the main fix here

### `contextPruning` as the first move

Not the main lever for the current setup, because docs say it applies to Anthropic-style calls.
It may become relevant later if the main model changes to Anthropic or OpenRouter Anthropic.

### Only telling agents to "/compact more often"

Manual compaction is useful, but it is not a durable solution to repeated overflow in a live environment.
The fix should live in config and startup discipline, not depend on the operator remembering slash commands.

### Letting memory substitute for written handoff docs

QMD memory helps retrieval, but repair-critical runtime facts still need explicit Markdown handoff files.
Do not trust semantic recall alone for infra or compaction state.

## Recommended validation after config changes

Use these checks:

```bash
openclaw memory status --agent main --json
openclaw sessions cleanup --dry-run
```

Then validate behavior with real sessions:

- watch whether `/status` starts showing compactions before hard overflow
- confirm durable facts are still written before compaction
- verify exact identifiers survive compaction summaries
- if server-side Responses compaction is enabled, confirm the provider accepts the payload without regressions

## Plain-language answer

For this machine, the best automatic anti-overflow setup is **not** generic "summarize more".
It is:

- earlier OpenClaw auto-compaction
- a stronger pre-compaction memory flush
- optional provider-side Responses compaction testing
- keeping always-loaded startup docs short

## Source notes

Local docs consulted:

- `app/docs/concepts/memory.md`
- `app/docs/concepts/compaction.md`
- `app/docs/concepts/session-pruning.md`
- `app/docs/reference/session-management-compaction.md`
- `app/docs/gateway/configuration-reference.md`
- `app/docs/providers/openai.md`

External best-practice references consulted:

- Zylos Research, "AI Agent Context Compression: Strategies for Long-Running Sessions"
- Morph, "Compaction vs Summarization: How AI Agents Should Manage Context"
- Autohand docs, "Context Compaction"
