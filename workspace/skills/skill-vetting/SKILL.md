---
name: skill-vetting
description: Security and quality review workflow for agent skills before installation or use. Use when discovering, evaluating, installing, updating, or auditing any skill from ClawHub, a local folder, a repo, or a pasted SKILL.md. Triggers on requests to install a skill, review a skill, audit a skill, inspect a SKILL.md, or decide whether a skill is safe enough to trust.
---

# Skill Vetting

## Overview

Run a lightweight but explicit security review before any skill is installed or trusted. Prefer a fast metadata pass for simple skills, then escalate to deeper file and behavior review whenever provenance is weak, capabilities are powerful, or code is non-trivial.

## Fast Path

Use the fast path when the skill is local, small, clearly scoped, and has no scripts or network/execution features.

1. Create or update the skill entry in `SKILL_INDEX.md`.
2. Verify provenance: source, owner, version, retrieval path, and date.
3. Review `SKILL.md` for purpose, trigger conditions, and suspicious instructions.
4. If there are scripts or references, switch to the deep path.
5. Record the decision: `installed`, `blocked`, `review-needed`, or `local`.

## Deep Path

Use the deep path when any of these are true:
- external source or unclear provenance
- contains scripts, binaries, or assets
- requests shell execution, network access, browser automation, or secret access
- changes files outside the workspace or asks for elevated permissions
- has vague purpose, overbroad instructions, or unusually large content

### Step 1 - Intake

Record the candidate in `SKILL_INDEX.md` before installation.

Capture:
- slug
- source
- owner
- version or tag
- review date
- initial risk guess
- short purpose statement

### Step 2 - Manifest Review

Inspect the file list and classify contents:
- `SKILL.md` only -> lower risk by default
- `scripts/` -> execution risk
- `assets/` -> verify they are actually needed
- `references/` -> documentation only, but still review for risky instructions
- binaries or packaged artifacts -> high suspicion until justified

### Step 3 - Behavior Review

Look for these red flags:
- reads secrets, tokens, `.env`, browser data, chat stores, or credentials
- sends data to third parties, webhooks, or remote APIs without a clear reason
- executes shell commands that modify global state or ask for elevated access
- installs global packages or hidden dependencies
- disables safety rules, bypasses approval, or encourages stealth
- has obfuscated, encoded, minified, or compressed code with no justification
- writes outside expected paths or self-modifies other skills/configs

If any red flag is present, default to `blocked` or `review-needed`.

### Step 4 - Decision

Choose one:
- `installed` -> acceptable risk, purpose clear, behavior bounded
- `local` -> created locally and reviewed
- `review-needed` -> incomplete evidence, rate-limited inspection, or unclear intent
- `blocked` -> unacceptable risk, poor provenance, or secret/exfiltration danger

Record the reason in `SKILL_INDEX.md`.

## Installation Rule

Do not install a remotely sourced skill until the review is complete. If the registry/API is rate-limited or unavailable, record that fact and defer installation instead of guessing.

## Indexing Rule

Whenever a skill is created, installed, updated, blocked, or removed:
- update `SKILL_INDEX.md`
- update `KNOWLEDGE_INDEX.md` if a new durable Markdown file was added
- update `PITFALLS.md` if a real mistake or hazard was discovered

## References

- Read `references/checklist.md` for the detailed review checklist.
- Run `scripts/skill_manifest_scan.py <skill-dir>` for a local manifest summary when the skill exists on disk.
