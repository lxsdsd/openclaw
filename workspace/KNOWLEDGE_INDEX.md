# KNOWLEDGE_INDEX.md

## Purpose

Top-level index for operational Markdown and policy files in this workspace. Add every important `.md` file here so nothing becomes tribal knowledge.

## Core files

| file | category | purpose | update_trigger |
| --- | --- | --- | --- |
| `ACCESS_POLICY.md` | security | What may be read, what is forbidden, what requires approval | Any new privacy or secret-handling rule |
| `COST_GUARDRAILS.md` | security/cost | Prevent accidental paid-provider usage | Any new provider, routing, or billing lesson |
| `FOLDER_LOCKDOWN_GUIDE.md` | security/os | OS-level folder and permission hardening guide | Any new sensitive path class |
| `OPENCLAW_SECURITY_REPORT_2026-03-12.md` | audit | Point-in-time OpenClaw security findings and actions | Any major security review or hardening change |
| `ROLE.md` | operating-model | Assistant role and behavior definition | Any role or workflow change |
| `SECURITY_TODO.md` | todo | Security backlog and hardening checklist | Any security task added/completed |
| `SKILL_INDEX.md` | index | Registry of local/external skills and review state | Any skill lifecycle change |
| `PITFALLS.md` | lessons | Mistakes, gotchas, and repeat-avoidance notes | Any time a mistake, false start, or hazard is found |
| `BEST_PRACTICES.md` | research | Distilled external and local best practices worth reusing | Any solid new practice discovered |
| `HEARTBEAT.md` | automation | Background checklist for proactive safe follow-through | Any proactive behavior or monitoring change |
| `STATUS_BOARD.md` | operations | Live board of current work, blockers, and decisions | Any meaningful status or priority change |
| `CODE_AGENT_POLICY.md` | engineering-policy | Cross-project rules for code-focused agents and rollback discipline | Any major coding workflow or quality-bar change |
| `BACKLOG_CONVENTION.md` | operating-model | Rules for separating short tasks, durable tracks, and reusable backlog conventions | Any backlog structure or promotion/cleanup rule change |
| `MULTI_PROJECT_CONVENTION.md` | operating-model | Standard folder and tracking pattern for keeping multiple active projects separated cleanly | Any folder model, project-local tracking, or agent-routing rule change |
| `FEISHU_TODO_FLOW_V1.md` | product-flow | First shippable design for Feishu `记录待办`: capture, inbox, triage, priority override, and todo views | Any change to the Feishu todo capture contract or storage model |
| `FEISHU_TODO_HANDLER_SPEC.md` | product-flow | Concrete parser, command order, file-mutation rules, and reply templates for wiring the `记录待办` v1 flow into a future Feishu message router | Any command grammar, dedupe rule, or handler-side implementation contract change |
| `TODO_INBOX.md` | todo | File-backed inbox for explicit `记录待办` captures before triage into short or long queues | Any inbox schema, capture rule, or active inbox-item change |
| `VOICE_PROFILE.md` | persona-style | Lightweight adjustable tone profile for daily conversation style | Any change to vibe, emotional color, or persona flavor |
| `NAME_PREFERENCE.md` | persona-style | Preferred assistant display name and naming rules | Any naming preference change |
| `AVATAR_PROMPT.md` | persona-style | Reusable avatar-generation prompt and style notes | Any avatar direction or art-style change |
| `IDENTITY.md` | identity | Current assistant identity basics such as name, vibe, emoji, and avatar | Any identity or persona-default update |

## Index rules

- Every durable Markdown file with operational value should be listed here.
- Create new files only if they add a distinct purpose; otherwise extend an existing indexed file.
- When a file becomes obsolete, mark it deprecated here before removing it.
