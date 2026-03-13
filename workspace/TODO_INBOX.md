# TODO_INBOX.md

## Purpose

Landing zone for explicitly captured todos before they are promoted into `TODO_SHORT.md` or `TODO_LONG.md`.
Use this file for `记录待办` entries and other inbox-first captures only.

## Entry rules

- Keep items in arrival order.
- Require an explicit capture trigger such as `记录待办` before adding a new item.
- Normalize every entry with id, priority, status, source, title, created time, and raw text.
- Promote, clarify, or close inbox items quickly so this file does not become a graveyard.

## Capture contract

Expected normalized fields:

- `id`: short stable id such as `td-20260312-001`
- `priority`: `P0` to `P3`; default `P1`
- `status`: start at `inbox`
- `source`: `feishu-shortcut` or `feishu-message`
- `title`: concise task summary
- `created`: UTC timestamp
- `raw`: original user text without the command prefix
- `track`: `short` by default unless clearly durable
- `notes`: optional parsed detail or clarification

## Commands this supports

- `记录待办 ...` -> capture into inbox, then optionally mirror to a todo file
- `看收件箱` -> show current inbox items
- `改成 P0 <id>` -> update priority after capture

## Active inbox

- [ ] `td-20260313-001` `P0` `inbox` `feishu-message` 把 TODO 收件箱接入第一版 parser/router
  - created: 2026-03-13 07:56 UTC
  - raw: 把 TODO 收件箱接入第一版 parser/router
  - track: short
  - message_id: om_demo_capture_001

## Entry template

```md
- [ ] `td-YYYYMMDD-001` `P1` `inbox` `feishu-message` Example task title
  - created: YYYY-MM-DD HH:MM UTC
  - raw: original text after the trigger
  - track: short
  - notes: optional clarification
```
