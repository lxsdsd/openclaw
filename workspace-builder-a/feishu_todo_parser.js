#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const SHARED_WORKSPACE = '/home/node/.openclaw/workspace';
const TODO_INBOX_PATH = path.join(SHARED_WORKSPACE, 'TODO_INBOX.md');
const ACTIVE_INBOX_HEADER = '## Active inbox';
const ENTRY_TEMPLATE_HEADER = '## Entry template';

function normalizeText(text) {
  return String(text || '').trim();
}

function detectSource(trigger) {
  return trigger === 'shortcut' ? 'feishu-shortcut' : 'feishu-message';
}

function parsePriorityOverride(text) {
  const trimmed = normalizeText(text);
  let match = trimmed.match(/^改成\s+(P[0-3])\s+(td-\d{8}-\d{3})$/u);

  if (match) {
    return {
      type: 'priority-update',
      priority: match[1],
      matchMode: 'id',
      targetId: match[2],
    };
  }

  match = trimmed.match(/^(td-\d{8}-\d{3})\s+改成\s+(P[0-3])$/u);
  if (match) {
    return {
      type: 'priority-update',
      priority: match[2],
      matchMode: 'id',
      targetId: match[1],
    };
  }

  match = trimmed.match(/^把["“](.+?)["”]\s*改成\s+(P[0-3])$/u);
  if (match) {
    return {
      type: 'priority-update',
      priority: match[2],
      matchMode: 'title',
      targetTitle: normalizeText(match[1]),
    };
  }

  return null;
}

function parseInboxView(text) {
  return normalizeText(text) === '看收件箱' ? { type: 'view-inbox' } : null;
}

function parseLongTodoView(text) {
  return normalizeText(text) === '看长期待办' ? { type: 'view-long-todo' } : null;
}

function parseCombinedTodoView(text) {
  const trimmed = normalizeText(text);
  if (trimmed === '看待办' || trimmed === '待办列表') {
    return { type: 'view-todo', alias: trimmed };
  }
  return null;
}

function parseCapture(text, message) {
  const trimmed = normalizeText(text);
  const match = trimmed.match(/^记录待办(?:\s+(P[0-3]))?(?:\s+(.*))?$/u);

  if (!match) {
    return null;
  }

  const raw = normalizeText(match[2]);
  if (!raw) {
    return {
      type: 'capture-empty',
      reply: '这条我还没法记成待办，发我“记录待办 + 具体内容”就行。',
    };
  }

  const priority = match[1] || 'P1';
  const title = raw.replace(/\s+/g, ' ').trim();

  return {
    type: 'capture',
    priority,
    title,
    raw,
    source: detectSource(message.trigger),
    track: 'short',
  };
}

function parseMessage(message) {
  const text = normalizeText(message && message.text);
  if (!text) {
    return { type: 'no-match' };
  }

  return (
    parsePriorityOverride(text) ||
    parseInboxView(text) ||
    parseLongTodoView(text) ||
    parseCombinedTodoView(text) ||
    parseCapture(text, message) ||
    { type: 'no-match' }
  );
}

function formatUtcMinute(isoString) {
  const date = new Date(isoString);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid received_at timestamp: ${isoString}`);
  }

  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  const hours = String(date.getUTCHours()).padStart(2, '0');
  const minutes = String(date.getUTCMinutes()).padStart(2, '0');
  return `${year}-${month}-${day} ${hours}:${minutes} UTC`;
}

function formatIdDate(isoString) {
  const date = new Date(isoString);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid received_at timestamp: ${isoString}`);
  }

  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  return `${year}${month}${day}`;
}

function escapeInline(text) {
  return String(text || '').replace(/`/g, '\\`').trim();
}

function readInboxFile(todoInboxPath) {
  return fs.readFileSync(todoInboxPath, 'utf8');
}

function findActiveInboxBounds(content) {
  const marker = `${ACTIVE_INBOX_HEADER}\n`;
  const start = content.indexOf(marker);
  const end = content.indexOf(`\n${ENTRY_TEMPLATE_HEADER}`);

  if (start === -1 || end === -1 || end <= start) {
    throw new Error('TODO_INBOX.md does not have the expected section layout.');
  }

  return {
    start: start + marker.length,
    end,
  };
}

function activeInboxBody(content) {
  const bounds = findActiveInboxBounds(content);
  return content.slice(bounds.start, bounds.end).trim();
}

function parseMetadataLine(line, prefix) {
  const trimmed = normalizeText(line);
  return trimmed.startsWith(prefix) ? trimmed.slice(prefix.length).trim() : null;
}

function parseInboxEntryBlock(block) {
  const lines = block.split('\n').map((line) => line.replace(/\s+$/g, ''));
  const head = lines[0] && lines[0].match(/^- \[ \] `([^`]+)` `(P[0-3])` `([^`]+)` `([^`]+)` (.+)$/u);

  if (!head) {
    throw new Error(`Unrecognized inbox entry block: ${block}`);
  }

  const entry = {
    id: head[1],
    priority: head[2],
    status: head[3],
    source: head[4],
    title: head[5],
  };

  for (const line of lines.slice(1)) {
    const created = parseMetadataLine(line, '- created:');
    const raw = parseMetadataLine(line, '- raw:');
    const track = parseMetadataLine(line, '- track:');
    const messageId = parseMetadataLine(line, '- message_id:');
    const notes = parseMetadataLine(line, '- notes:');

    if (created !== null) {
      entry.created = created;
    } else if (raw !== null) {
      entry.raw = raw;
    } else if (track !== null) {
      entry.track = track;
    } else if (messageId !== null) {
      entry.messageId = messageId;
    } else if (notes !== null) {
      entry.notes = notes;
    }
  }

  return entry;
}

function parseInboxEntries(content) {
  const body = activeInboxBody(content);
  if (!body || body === '_None yet._') {
    return [];
  }

  return body
    .split(/\n\n+/)
    .map((block) => block.trim())
    .filter(Boolean)
    .map(parseInboxEntryBlock);
}

function readInboxState(todoInboxPath = TODO_INBOX_PATH) {
  const content = readInboxFile(todoInboxPath);
  return {
    content,
    entries: parseInboxEntries(content),
  };
}

function hasMessageId(content, messageId) {
  return content.includes(`- message_id: ${messageId}`);
}

function nextInboxId(content, receivedAt) {
  const datePart = formatIdDate(receivedAt);
  const pattern = new RegExp(`td-${datePart}-(\\d{3})`, 'g');
  let max = 0;
  for (const match of content.matchAll(pattern)) {
    max = Math.max(max, Number(match[1]));
  }
  return `td-${datePart}-${String(max + 1).padStart(3, '0')}`;
}

function buildEntry(entry) {
  const noteLine = entry.notes ? `\n  - notes: ${entry.notes}` : '';
  return [
    `- [ ] \`${entry.id}\` \`${entry.priority}\` \`${entry.status || 'inbox'}\` \`${entry.source}\` ${entry.title}`,
    `  - created: ${entry.created}`,
    `  - raw: ${entry.raw}`,
    `  - track: ${entry.track}`,
    `  - message_id: ${entry.messageId}` + noteLine,
  ].join('\n');
}

function replaceActiveInbox(content, entries) {
  const bounds = findActiveInboxBounds(content);
  const before = content.slice(0, bounds.start);
  const after = content.slice(bounds.end).replace(/^\n+/, '');
  const body = entries.length ? entries.map(buildEntry).join('\n\n') : '_None yet._';
  return `${before}\n${body}\n\n${after}`;
}

function buildInboxReply(entries) {
  if (!entries.length) {
    return '收件箱现在是空的。';
  }

  const lines = entries.map((entry) => `- ${entry.id} ${entry.priority} ${entry.title}`);
  return `收件箱里现在有 ${entries.length} 条：\n${lines.join('\n')}`;
}

function appendInboxEntry(message, parsed, todoInboxPath = TODO_INBOX_PATH) {
  const { content, entries } = readInboxState(todoInboxPath);
  if (hasMessageId(content, message.message_id)) {
    return {
      status: 'duplicate',
      message: `Duplicate capture ignored for ${message.message_id}.`,
    };
  }

  const entry = {
    id: nextInboxId(content, message.received_at),
    priority: parsed.priority,
    status: 'inbox',
    source: parsed.source,
    title: escapeInline(parsed.title),
    created: formatUtcMinute(message.received_at),
    raw: escapeInline(parsed.raw),
    track: parsed.track,
    messageId: message.message_id,
  };

  const updated = replaceActiveInbox(content, [...entries, entry]);
  fs.writeFileSync(todoInboxPath, updated, 'utf8');

  return {
    status: 'appended',
    entry,
    reply: `记下了：${entry.title}，先按 ${entry.priority} 收进收件箱，并同步到短期待办。要改优先级的话，直接回“改成 P0 ${entry.id}”就行。`,
  };
}

function renderInboxView(todoInboxPath = TODO_INBOX_PATH) {
  const { entries } = readInboxState(todoInboxPath);
  return {
    status: 'rendered',
    count: entries.length,
    entries,
    reply: buildInboxReply(entries),
  };
}

function routeMessage(message, todoInboxPath = TODO_INBOX_PATH) {
  const parsed = parseMessage(message);

  if (parsed.type === 'capture') {
    return { parsed, result: appendInboxEntry(message, parsed, todoInboxPath) };
  }

  if (parsed.type === 'view-inbox') {
    return { parsed, result: renderInboxView(todoInboxPath) };
  }

  return { parsed };
}

function main() {
  const input = fs.readFileSync(0, 'utf8');
  const message = JSON.parse(input);
  const routed = routeMessage(message);
  process.stdout.write(`${JSON.stringify(routed, null, 2)}\n`);
}

if (require.main === module) {
  main();
}

module.exports = {
  appendInboxEntry,
  buildInboxReply,
  parseMessage,
  readInboxState,
  renderInboxView,
  replaceActiveInbox,
  routeMessage,
};
