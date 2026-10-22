# IDO Prime — product purpose

## North star

**IDO** is a premium **celebration & event lifestyle** app: plan events, discover vendors, gather inspiration, share moments with a social feed, and use an **AI co-pilot** (and voice mic) to help users decide faster.

It is **not** a generic productivity SaaS, CRM, or ChatGPT wrapper. AI exists to help with **events** (themes, vendors, timelines, budgets, guest vibes) — not open-ended chat for its own sake.

## Primary jobs (in priority)

1. **Plan an event** — create/manage celebrations (weddings, birthdays, parties…).
2. **Find vendors** — browse/search with AI-matched suggestions tied to an event context.
3. **Get inspired** — visual inspiration for themes, décor, looks.
4. **Share & engage** — posts feed (image/video), likes, comments, saves.
5. **Ask AI / speak** — AI co-pilot + gold microphone FAB for hands-free help.
6. **Manage self** — profile, theme (Light / Dark), settings, membership.

## Navigation mental model

Bottom tabs (shell):

| Tab | Purpose |
|-----|---------|
| Posts | Social feed of celebration moments |
| Events | User’s events & planning |
| Vendors | Vendor discovery (+ AI matches) |
| Inspiration | Ideas & mood boards |

Profile opens from the shell avatar (not a tab).

Global: **gold circular + FAB on Posts** — create a post (Planner space).

## Product voice

- Elegant, calm, warm-premium (gold on deep purple / soft lavender).
- Copy is short and human: help with *this* wedding / birthday, not enterprise jargon.
- Empty states invite one next action (“Plan your first event”, “Ask AI for vendor ideas”).

## Design implications

- Screens should feel **curated**, not dense dashboards.
- AI surfaces (banners, chat, mode chips) use **sparkles + gold**, never neon gradients.
- Social media patterns (feed, engagement row, comment composer) stay familiar but themed.
- Vendor/event lists use searchable cards, category chips, clear primary actions (Contact / View).

/// Dual persona (Organisateur / Prestataire)

- One Auth identity; optional `vendor_business` capability.
- Global **Active space**: Planner vs Vendor (not AI/Manual).
- **Become a vendor** hub: Step 1 identity → Step 2 services → Step 3 KYC/KYB; steps independent & resumable.
- Persistent progress banner until `approved` after IDO field verification.
- `can_offer_services` only when all steps done **and** back-office approved.

## Social graph rules

| Relation | Who | Rules |
|----------|-----|-------|
| **Follow** | Vendors only | Anyone can follow one or more prestataires. Not available on planner profiles. |
| **Friend** | Planners only | LinkedIn-style request → accept/decline. No friendship toward a vendor business. |
| **Planner chat** | After accepted friendship | Message locked until the other planner accepts. |
| **Vendor chat** | Event-scoped connection | Contact/request requires an event; chat after vendor accepts. Vendors cannot contact other vendors — switch to Planner space. |

## When proposing a new screen

Ask (and answer in the design):

1. Which primary job does this serve?
2. What is the single primary action?
3. How does AI or the event context appear (if at all)?
4. Does it work in Light **and** Dark?
