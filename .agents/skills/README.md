# Design skills (ido_prime)

| Skill | Location | Role |
|-------|----------|------|
| **ido-design-system** | `.agents/skills/ido-design-system/` | **Source of truth** — product purpose + brand + Flutter recipes |
| ui-ux-pro-max | `.cursor/skills/ui-ux-pro-max/` (+ related design skills) | UX craft / searchable guidelines |
| ui-design-brain | `.agents/skills/ui-design-brain/` | Component anatomy |
| frontend-design | `.agents/skills/frontend-design/` | Anti-generic craft within IDO |

Always-on rule: `.cursor/rules/ido-design-system.mdc`

## Usage

- Automatic: Agent should pick up `ido-design-system` for UI work.
- Explicit: `/ido-design-system` or `@ido-design-system` in chat.
- Example: *Implement the AI screen so users chat about their events.*

After adding new UI patterns, update `ido-design-system/references/screen-recipes.md`.
