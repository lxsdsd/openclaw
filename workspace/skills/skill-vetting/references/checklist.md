# Skill Vetting Checklist

## Purpose

Detailed checklist for reviewing local or external skills before installation or use.

## 1. Provenance

- Where did the skill come from?
- Who owns it?
- What version or tag is being reviewed?
- Is the source stable and attributable?
- Was the skill fetched directly, mirrored, pasted, or manually reconstructed?

## 2. Scope

- What exact problem does the skill solve?
- Is the skill narrowly scoped, or does it claim broad power?
- Are trigger conditions clear and specific?
- Does the skill ask to read data classes that are sensitive in this workspace?

## 3. Capability risk

Mark any that apply:
- shell execution
- network access
- browser automation
- file writes outside workspace
- secret access
- credential handling
- global package installation
- binary execution
- scheduled/cron behavior

## 4. Content review

- Read `SKILL.md`
- Read any scripts
- Sample references if they could alter behavior
- Check for encoded/obfuscated payloads
- Check for hidden install steps or external downloads

## 5. Decision heuristics

### Accept faster when
- local skill
- no scripts
- no secret access
- no network or browser automation
- narrow purpose and small footprint

### Escalate review when
- unclear provenance
- hidden downloads
- shell or browser automation
- asks for secrets or auth state
- broad filesystem claims
- touches messaging credentials or chat databases

### Reject when
- stealth/exfiltration behavior appears intentional
- approval bypass is suggested
- secrets are requested without a sharp need
- code is obfuscated without a strong reason
- provenance is too weak to trust

## 6. After decision

- Update `SKILL_INDEX.md`
- Record any gotcha in `PITFALLS.md`
- If installed, note future watchpoints like updates, scripts, or network calls
