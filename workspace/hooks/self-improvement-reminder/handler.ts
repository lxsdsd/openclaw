import type { HookHandler } from 'openclaw/hooks';

const REMINDER_CONTENT = `## Self-Improvement Reminder

After completing tasks, evaluate if any learnings should be captured:

- User corrects you -> .learnings/LEARNINGS.md
- Command or operation fails -> .learnings/ERRORS.md
- User wants a missing capability -> .learnings/FEATURE_REQUESTS.md
- You discover a better repeatable approach -> .learnings/LEARNINGS.md

Promote stable patterns into SOUL.md, AGENTS.md, or TOOLS.md when they prove durable.`;

const handler: HookHandler = async (event) => {
  if (!event || typeof event !== 'object') return;
  if (event.type !== 'agent' || event.action !== 'bootstrap') return;
  if (!event.context || typeof event.context !== 'object') return;

  const sessionKey = event.sessionKey || '';
  if (sessionKey.includes(':subagent:')) return;

  if (Array.isArray(event.context.bootstrapFiles)) {
    event.context.bootstrapFiles.push({
      path: 'SELF_IMPROVEMENT_REMINDER.md',
      content: REMINDER_CONTENT,
      virtual: true,
    });
  }
};

export default handler;
