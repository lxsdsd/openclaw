# OpenClaw Integration Notes

This skill works in two separate layers:

1. Skill loading
   - `openclaw skills list` should show `self-improvement` as `ready`.
   - This means the skill can be selected and its `SKILL.md` can guide behavior.

2. Bootstrap reminder hook
   - This is separate from skill loading.
   - `openclaw hooks list` must show a dedicated hook such as `self-improvement-reminder`.
   - The hook must also be enabled with `openclaw hooks enable <name>`.

## Important pitfalls

- Skill files existing on disk do not guarantee a hook is active.
- OpenClaw only auto-discovers hooks from `workspace/hooks/`, `~/.openclaw/hooks/`, or bundled hook directories.
- A bare `handler.ts` inside a skill folder is not enough; a real hook directory also needs `HOOK.md`.
- After enabling or disabling hooks, restart the gateway so new hook registrations are loaded.
- On this machine, prefer workspace-local handoff docs like `INFRA_BASELINE.md` and `OPENCLAW_RUNTIME_STATUS.md`; stale non-workspace paths have caused false troubleshooting leads before.

## Verification checklist

```bash
openclaw skills list
openclaw hooks list
openclaw hooks info self-improvement-reminder
```

Expected shape:

- `self-improvement` appears in the skills list as `ready`
- `self-improvement-reminder` appears in the hooks list
- after enablement, the hook shows as ready and enabled in config
