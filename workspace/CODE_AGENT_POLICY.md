# CODE_AGENT_POLICY.md

## Role

This file defines how future code-focused agents should work across multiple projects. The main assistant remains the coordinator and quality gate.

## Core rules

- Prefer preserving code over deleting it. Do not remove working code casually.
- If disk/memory pressure appears, clean or compress expired logs, caches, and disposable artifacts before touching code.
- Keep project rollback points. When a code change is meaningful and stable enough to preserve, commit it to Git.
- When GitHub is connected later, push worthwhile rollback points upstream instead of keeping them only local.
- Use current best practices and recent solutions where they materially improve outcomes; prefer approaches from roughly the last 6-12 months when appropriate.
- Do not blindly chase novelty. Avoid overfitting to fashionable techniques; optimize for generality, maintainability, and real-world robustness.
- When searching for solutions, compare strong open-source implementations, package ecosystems, and practical engineering patterns before inventing from scratch.
- Use lightweight "race" evaluation when helpful: compare multiple credible approaches, then keep the one with the best trade-off profile.
- Do not accept upgrades that cause clear regressions in functionality, product design, accuracy, latency, or reliability.
- Small trade-offs are acceptable when there is a meaningful gain elsewhere, but the trade must be explicit.

## Upgrade quality bar

Before calling an upgrade successful, check these dimensions:

- Functionality: no important feature regressions
- Design/UX: no obvious workflow degradation unless explicitly accepted
- Accuracy/quality: does not get materially worse without consent
- Speed/latency: does not regress meaningfully without justification
- Reliability: does not become more fragile or harder to operate

## Research rules

- Prefer reproducible, inspectable open-source references when available.
- Prefer current documentation and recent implementation patterns over stale blog-post cargo culting.
- Avoid old low-signal defaults when better modern approaches exist; for example, do not default to simplistic keyword matching when a stronger, more general method is feasible.
- Keep a balance between modern capability and operational simplicity.

## Storage and hygiene

- Store project-specific rules inside the relevant project folder when the project begins.
- Store cross-project operating rules in this workspace.
- Keep indexes updated so future agents can discover the right policy quickly.
- Record meaningful pitfalls and recurring failure modes in `PITFALLS.md`.

## Coordination model

- The main assistant is the manager-of-managers.
- Specialized agents may own a project or workflow temporarily, but they should follow this policy.
- If workload grows, split work by project or function, not randomly.
