# BEST_PRACTICES.md

## Principles

- Prefer industry-backed patterns over improvised local habits when the task touches security, reliability, indexing, or supply chain risk.
- Use progressive disclosure: keep the default path fast, and load deeper instructions only for complex or high-risk tasks.
- Record decisions in stable indexes instead of leaving them in chat history.
- Treat externally sourced skills, scripts, and plugins as supply-chain inputs that require review before install.

## Practical patterns adopted here

### 1. Skill intake must be gated
- Create or update `SKILL_INDEX.md` before any install.
- Record source, owner, version, review date, and decision.
- Block install if provenance or purpose is unclear.

### 2. Review external artifacts in layers
- Layer 1: metadata and provenance
- Layer 2: file manifest and declared capabilities
- Layer 3: sensitive-behavior scan (`exec`, network, credential access, shell-outs, browser automation, self-modification)
- Layer 4: final install decision and post-install watchpoints

### 3. Keep indexes small but canonical
- One canonical skill index
- One canonical markdown/knowledge index
- One canonical pitfalls log
- One security todo file

### 4. Prefer local-first execution and documentation
- Use local docs and local scripts before paid or remote providers.
- Use workspace-local helper tools before global installs.

### 5. Security findings should become controls
- If a real risk is found, convert it into a rule, checklist item, or folder lock recommendation.
- If a process repeatedly goes wrong, turn it into a repeatable checklist or skill.

## External references distilled

### Supply-chain security
GitHub's supply-chain guidance reinforces dependency visibility, vulnerability review, version hygiene, and provenance checks as baseline practices. Applied locally, that means external skills should be treated like dependencies: indexed, reviewed, versioned, and periodically rechecked.

### OWASP-style risk thinking
OWASP's current guidance remains useful as a mental model: assume insecure defaults, overbroad access, and unsafe inputs are common failure modes. Applied locally, that means skills should be screened for secret access, code execution, network exfiltration, and excessive capability.
