# skill-vetter recovery note

This directory preserves the recovered legacy `skill-vetter` artifact from earlier history.

Important:

- The currently active runtime skill is `skill-vetting`
- `skill-vetting` is what OpenClaw loads from `workspace/skills`
- This directory is an archive / recovery copy so the older `skill-vetter` artifact is not lost again

Reason for keeping both:

- `skill-vetter` existed as an older host-side skill artifact
- the running system currently uses a newer workspace-managed `skill-vetting`
- keeping the legacy artifact outside `workspace/skills` avoids duplicate runtime loading while preserving history
