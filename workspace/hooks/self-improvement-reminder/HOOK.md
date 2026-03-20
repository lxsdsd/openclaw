---
name: self-improvement-reminder
description: "Inject a self-improvement reminder during agent bootstrap so `.learnings/` stays in active use."
homepage: https://docs.openclaw.ai/automation/hooks
metadata:
  { "openclaw": { "emoji": "🧠", "events": ["agent:bootstrap"] } }
---

# Self-Improvement Reminder

Injects a short bootstrap reminder so the agent remembers to capture:

- corrections in `.learnings/LEARNINGS.md`
- command or tool failures in `.learnings/ERRORS.md`
- missing capabilities in `.learnings/FEATURE_REQUESTS.md`

## Notes

- This hook is intentionally lightweight and only adds a virtual bootstrap file.
- It skips sub-agent sessions to avoid extra bootstrap noise there.
