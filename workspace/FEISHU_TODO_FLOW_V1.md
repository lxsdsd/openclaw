# FEISHU_TODO_FLOW_V1.md

## Purpose

Define the first shippable version of the Feishu `记录待办` flow so mobile todo capture works before any heavier UI or automation layer is added.

## Product goal

Let the user quickly dump a task into Feishu, have the assistant store it in a predictable inbox format, assign a default priority, allow a later priority override, and provide a simple way to view current todos.

## V1 scope

Ship only the lowest-risk path first:

1. user triggers `记录待办`
2. user sends one freeform message
3. assistant converts it into a normalized todo entry
4. assistant assigns a default priority if none is given
5. user can override priority with a follow-up command
6. user can request current todos at any time

Out of scope for v1:
- rich cards or complex form UI
- multi-step wizard flows
- automatic due-date parsing beyond simple obvious phrases
- multi-project routing
- batch editing
- external database requirements

## Entry points

### Capture

Primary trigger:
- Feishu shortcut/menu item: `记录待办`

Fallback trigger:
- plain message starting with `记录待办`

Examples:
- `记录待办 明天下午确认徒步装备`
- `记录待办 P1 把 GitHub skill auth 跑通`
- `记录待办 研究一下多项目文件夹规范`

## Normalized capture format

Every captured item should be transformed into one structured record with these fields:

- `id`: short unique id
- `created_at`: UTC timestamp
- `source`: `feishu-shortcut` or `feishu-message`
- `raw_text`: original user message minus the command prefix
- `title`: concise task summary
- `priority`: `P1` default unless user specifies `P0` to `P3`
- `status`: `inbox` on capture
- `track`: `short` by default unless the assistant later promotes it into a durable track
- `notes`: optional clarification or parsed detail

## Storage model

V1 should stay file-based inside the workspace.

### Inbox file

Create a dedicated file-backed inbox:
- `TODO_INBOX.md`

This file holds newly captured items in arrival order with minimal normalization.

### Promotion rules

- one-off actionable work moves into `TODO_SHORT.md`
- durable recurring or capability work moves into `TODO_LONG.md`
- completed one-off work is removed from `TODO_SHORT.md`
- inbox entries should either be promoted, clarified, or closed; they should not sit forever

## Proposed inbox entry format

```md
- [ ] `td-20260312-001` `P1` `inbox` `feishu-shortcut` Confirm hiking gear list for tomorrow
  - created: 2026-03-12 21:00 UTC
  - raw: 明天下午确认徒步装备
```

## Assistant behavior

### On capture

Assistant reply should be short and confirm:
- task captured
- assigned priority
- whether it went to inbox first or directly into a todo file
- how to change the priority

Example reply:
- `记下了：Confirm hiking gear list for tomorrow，先按 P1 收进待办。要改优先级的话，直接回 “改成 P0 + 编号” 就行。`

### Default priority rules

- explicit `P0` to `P3` from the user wins
- otherwise default to `P1`
- if wording implies urgency today, the assistant may raise to `P0` and should say so
- if truly ambiguous, keep `P1` and let the user override

### Priority override commands

Support lightweight commands:
- `改成 P0 td-20260312-001`
- `td-20260312-001 改成 P2`
- `把“确认徒步装备”改成 P0`

If the match is ambiguous, ask for the id.

### View commands

Support these reads:
- `看待办`
- `待办列表`
- `看长期待办`
- `看收件箱`

Suggested mapping:
- `看待办` -> summarize `TODO_SHORT.md` first, then `TODO_LONG.md`
- `看收件箱` -> show `TODO_INBOX.md`
- `看长期待办` -> show `TODO_LONG.md`

## Triage policy

Use this lightweight triage path:

1. capture into `TODO_INBOX.md`
2. if clearly one-off and actionable, mirror into `TODO_SHORT.md`
3. if clearly a durable track, mirror into `TODO_LONG.md`
4. if unclear, leave in inbox until the next heartbeat or direct user clarification

## First implementation plan

### Phase 1

- define `TODO_INBOX.md`
- document the command grammar and reply behavior
- keep triage manual but consistent

### Phase 2

- add a small parser/dispatcher for Feishu message patterns
- auto-generate stable ids
- auto-append to inbox file

### Phase 3

- add editable status transitions and cleaner list rendering
- consider simple due-date tags if they prove useful

## Risks and guardrails

- do not treat every Feishu message as a todo; require the explicit shortcut or command trigger
- do not hide priority changes; confirm them back to the user
- do not over-parse vague natural language into fake deadlines
- keep the storage plain text first so the workflow stays debuggable

## Recommended next concrete step

Create `TODO_INBOX.md` with the entry schema above and wire the first command handler around explicit `记录待办` messages only.