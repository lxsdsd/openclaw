# STATUS_BOARD.md

## Doing now

- Finish the English-study closeout in `main`: the delivery pack now exports to `projects/english-study/delivery/docx/`, and the remaining step is reviewing restored upstream files plus the local browser/shared-lib workaround before the second rollback commit
- Close remaining skill activation gaps one by one: `github`
- Maintain the local `skills/skill-vetting/` gate as the default pre-install review path
- Compare and vet external skill-vetting candidates before any install
- Maintain indexes and pitfall tracking so new files and lessons stay discoverable
- Work toward a clean multi-project convention for separate code folders and task tracking

## Waiting on external conditions

- ClawHub rate limit to clear so `openclaw-skill-vetter` and similar candidates can be inspected fully

## Recently resolved

- English-study delivery packaging advanced: `projects/english-study/tools/export_delivery_docs.py` now exports the delivery pack and `projects/english-study/delivery/docx/` contains generated Word copies of the current docs
- Local control clients reconnected after token rotation
- Gateway token mismatch cleared
- Feishu DM channel successfully paired and working
- Skill visibility issue understood: runtime sees skills under `/home/node/.openclaw` and `/home/node/.openclaw/workspace`, not the earlier host-side repo path
- `agent-reach` is installed and partially usable now (`doctor` shows about 7/15 channels available)
- `tavily` is live with the newly added API key and the bundled search script returns results
- `find-skill` has no runtime-visible install in the current workspace or OpenClaw skill roots, so it should be treated as not installed

## Needs user decision

- Whether to finalize identity/bootstrap cleanup now or later
- Whether any browser-control capability should ever be re-enabled for specific tasks
- Whether to fund better external research capability later (optional, not needed for current safety baseline)
- When multiple coding projects are active, whether to split them into explicit project folders and labels up front
- When to start designing the multi-agent workbench for project-specific and function-specific helper agents

## Future work backlog

- PPT creation workflow
- Document writing workflow
- Multi-project coding workflow across separate folders
- Stock and fund monitoring workflow
- AI landscape monitoring: new tools, models, and information edge tracking
- Reading/monitoring content sources such as Xiaohongshu, Douyin, and WeChat Official Accounts
- A dedicated content-operations agent for managing the user's own accounts and posting workflow later
- A code-manager operating model with Git/GitHub rollback discipline, modern best-practice research, and anti-regression checks
- Per-agent customizable tone/persona profiles when the multi-agent setup expands
- Feishu menu-driven todo capture: clicking `记录待办` should route follow-up messages into a real todo inbox with assistant triage, editable priority, and todo viewing

## Operating cadence

- Keep running on queued/runnable work without waiting for repeated prompts
- If work runs dry, proactively tell the user that there are no active todos and ask for the next task
- If network returns after an outage, resume work automatically without asking again
- If VPN/network access is the blocker, tell the user exactly that it needs their help
- Ask the user when a choice is ambiguous, risky, or materially affects cost/security
- If workload exceeds one agent comfortably, propose parallel help via sub-agents/other "colleagues"
- Send scheduled progress updates at 08:00, 13:30, 20:00, and 22:00 UTC

## Candidate skill ranking (temporary)

1. `openclaw-skill-vetter` - best fit by current metadata; still pending full file review
2. `skill-vetter` - strong generic candidate; pending full file review
3. `skill-scanner` - likely useful, but seems more scanner-like than full install-decision workflow

## Next planned moves

1. Prompt for `gh auth` only if `github` is the next skill the user wants fully activated
2. Retry metadata/file inspection for external skill-vetter candidates when rate limits clear
