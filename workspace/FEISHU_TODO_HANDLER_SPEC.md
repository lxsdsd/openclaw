# FEISHU_TODO_HANDLER_SPEC.md

## Purpose

Define the minimum handler behavior needed to turn the `记录待办` v1 design into a real message-driven workflow once a Feishu message router is available.

## Scope

This spec covers only the assistant-side decision logic for explicit todo commands:

- capture via `记录待办 ...`
- inbox read via `看收件箱`
- queue read via `看待办` and `看长期待办`
- priority override via `改成 P0 <id>` and similar variants

It does not define Feishu bot transport, menu wiring, auth, or card UI.

## Required inputs

The handler should receive a normalized message object with at least:

- `channel`: source channel such as `feishu-dm`
- `user_id`: sender identifier
- `message_id`: source message id for dedupe
- `text`: plain text content
- `received_at`: UTC timestamp
- `trigger`: `shortcut` or `message`

## Command detection order

Evaluate commands in this order so priority edits do not get misread as fresh captures:

1. priority override
2. inbox view
3. long-todo view
4. combined todo view
5. explicit capture
6. no match

## Command grammar

### Capture

Accept:

- `记录待办 <freeform text>`
- `记录待办 P0 <freeform text>`
- `记录待办 P1 <freeform text>`
- `记录待办 P2 <freeform text>`
- `记录待办 P3 <freeform text>`

Rules:

- Require non-empty text after the trigger.
- If priority is omitted, default to `P1`.
- Strip the trigger and explicit priority token from `raw` before storing.
- Use `feishu-shortcut` when `trigger=shortcut`; otherwise use `feishu-message`.

### Priority override

Accept common variants:

- `改成 P0 <id>`
- `<id> 改成 P2`
- `把"<title>"改成 P1`
- `把“<title>”改成 P1`

Rules:

- Prefer exact id match.
- If using title match and more than one item matches, ask for the id.
- Confirm the updated priority in the reply.

### Read commands

Accept:

- `看收件箱`
- `看待办`
- `待办列表`
- `看长期待办`

Rules:

- `看收件箱` reads only `TODO_INBOX.md`.
- `看待办` summarizes `TODO_SHORT.md` first, then `TODO_LONG.md`.
- `待办列表` is an alias of `看待办`.
- `看长期待办` reads only `TODO_LONG.md`.

## File mutations

### Capture path

On a valid capture:

1. generate next inbox id with format `td-YYYYMMDD-XXX`
2. append a normalized entry to `TODO_INBOX.md`
3. if task is clearly one-off, mirror it into `TODO_SHORT.md`
4. if task is clearly a durable track, mirror it into `TODO_LONG.md`
5. if unclear, leave it only in inbox

### Priority update path

On a valid priority override:

1. update the matching entry in `TODO_INBOX.md` if present
2. update the mirrored entry in `TODO_SHORT.md` or `TODO_LONG.md` if present
3. keep id and title unchanged

## Triage rules

Mirror to `TODO_SHORT.md` when the item is:

- a one-time action
- clearly actionable without becoming an ongoing track
- specific enough to execute soon

Mirror to `TODO_LONG.md` when the item is:

- a recurring workflow
- a capability build-out
- a durable project or system improvement

Keep inbox-only when the item is:

- vague
- missing a clear action
- likely to need user clarification before scheduling

## Reply templates

### Capture success

- `记下了：{title}，先按 {priority} 收进收件箱{mirror_note}。要改优先级的话，直接回“改成 P0 {id}”就行。`

Where `mirror_note` is one of:

- `，并同步到短期待办`
- `，并同步到长期待办`
- empty string

### Empty capture

- `这条我还没法记成待办，发我“记录待办 + 具体内容”就行。`

### Priority updated

- `已更新：{id} 现在是 {priority}。`

### Priority ambiguous

- `我找到不止一条同名待办，直接发编号给我更稳，比如：改成 P0 td-20260312-001`

### Inbox view empty

- `收件箱现在是空的。`

### No command match

- no todo action
- fall through to the normal assistant message pipeline

## Validation rules

- Never create a todo from a message that does not use an explicit trigger.
- Never invent a due date from vague natural language.
- Never silently change priority; always confirm it.
- Never duplicate an inbox item if the same `message_id` is already recorded for this capture event.

## Suggested implementation checkpoints

1. build a pure-text parser for the command grammar above
2. add deterministic id generation and duplicate protection
3. append and edit the file-backed records safely
4. add renderer functions for inbox and todo summaries
5. wire the parser into the eventual Feishu message router
