# English Study

This repository is a trimmed working fork for English-learning annotation and review workflows.
It keeps the backend, project settings, task and review flows, ML backend hooks, and core frontend packages that are still used in this fork.

It does not claim to ship the full upstream Label Studio product surface, and this local README stays focused on what can be supported honestly from the checked-in snapshot.

## What is in this repo

- `label_studio/` - Django app, CLI and server entrypoints, project and task logic, and ML backend integration.
- `web/` - frontend packages for the editor, data manager, and app shell.
- `docs/source/guide/` - local project-settings references kept self-contained for this fork.
- `用户指南.md` - Chinese operator notes.
- `roadmap.md` - inherited upstream roadmap notes kept as historical context, not as the delivery contract for this fork.

## Current scope

This fork currently documents and preserves the parts of the product that still matter for the English-study delivery lane:

- project creation and labeling configuration
- annotation and review settings
- task overlap, members, and reviewer controls
- ML backend connections, live predictions, and imported predictions
- cloud storage and webhook configuration that remains wired in the codebase
- local development and debugging around the reduced repo layout

This repository is **not** a full mirror of upstream Label Studio. If you need a guide page that is missing from `docs/source/guide/`, treat the upstream docs as background material instead of assuming that page is shipped locally in this fork.

## Working with this snapshot

- Package metadata and the console script still use the upstream-compatible `label-studio` name for compatibility.
- The local entrypoints live in `pyproject.toml`, `label_studio/server.py`, and `label_studio/manage.py`.
- This checkout is intended to be run from source instead of from a claimed public English-study package or image.

### Local development

```bash
pip install poetry
poetry install
python label_studio/manage.py migrate
python label_studio/manage.py collectstatic
python label_studio/manage.py runserver
```

### Key local docs

- [Project settings reference](docs/source/guide/project_settings.md)
- [Enterprise settings reference](docs/source/guide/project_settings_lse.md)
- [Chinese user guide (`用户指南.md`)](用户指南.md)

## Notes for maintainers

- Keep docs honest about the reduced repository shape.
- Prefer self-contained docs over links to local pages that are not shipped in this fork.
- Preserve ML and model-integration references unless the corresponding backend code is actually removed.
