# Screen recipes

Use these as defaults when implementing or prototyping. Extend this file when new patterns ship.

## Splash & first-run onboarding

- `/splash`: brand moment — soft orbs, gold glow, IDO mark fade/scale, **Fraunces** tagline “Celebrate beautifully” (splash-only; app body stays DM Sans). Timed (~2.3s) then routes by state.
- Flow: Splash → `/onboarding` (first launch) → Login · or Splash → Login (tour done) · or Splash → Posts (signed in).
- `/onboarding`: 4 full-bleed lifestyle slides (Plan · Discover · Inspire · Share & ask). Gold eyebrow chips, sliding page dots, Skip / Continue / **Start celebrating**. Soft fade+slide page and route transitions. Completion stored in SharedPreferences (`ido_onboarding_completed_v1`).

## Shell chrome

- Main tabs share `MainShellAppBar`: avatar (→ Profile) | contextual search | notifications bell with **gold unread badge** (`unreadNotificationsCountProvider`) when count > 0.
- Bottom nav: floating **stadium** pill (blur + soft shadow), sliding gold selection indicator, outline→filled icons with light scale/fade. Tabs: Feed · Events · Vendors · Inspiration (no Profile).
- Create-post FAB on Posts; create-event FAB on Events (calendar-plus). Both gated to Planner via `runInActiveSpace`.
- Persona gates: Contact vendor requires Planner; use `runInActiveSpace` / `ensureActiveSpace`.

## Profile / settings

- Pushed full-screen from shell avatar (`/profile`), frosted app bar with back — **own** settings.
- **Public planner profile** `/planners/:id`: opened from feed/post/comment/suggestion/reel avatars. Gold-ring avatar, bio, stats (Events · Posts · Friends; own profile also shows vendors Following). **Add friend** / Accept·Decline / Friends + **Message** (Message locked until friendship accepted). Route `/planners/:id/chat` for planner chat.
- Header card (settings): avatar (gold ring) + name/email + Pro pill + stats row.
- **Edit profile** `/profile/edit` from Account → Edit Profile: photo, display name, role, location, bio, email, phone. Persisted via `userAccountProvider` (mock).
- **Privacy & Security** `/profile/privacy`: change password sheet, 2FA / app lock toggles, private profile, activity, tagging, who can message (**Everyone / Friends / Nobody** — planner chat); vendor chats still need event connection. Persisted via `privacySecurityProvider` (mock).
- **App Settings** `/profile/settings` from Preferences → App Settings: autoplay videos, reduce data usage, haptic feedback (SharedPreferences via `appSettingsProvider`); clear image cache; replay product tour (`onboardingController.reset`); version row.
- **Help Center** `/profile/help`: search + topic chips, expandable FAQs (events/vendors/inspiration/account), contact support mailto.
- Section cards: title (`onSurfaceVariant`) + control + footer caption.
- Settings groups: external section label + grouped list tiles + chevrons.
- Theme picker: Light / Dark (purple) segmented control under Preferences.
- Active space: Planner | Vendor chips (gates Vendor until approved).

## Social feed

- Top **Reels** row: horizontal avatars with Instagram-style gradient ring (gold + muted purple) for unseen; “Your story” + gold plus.
- Mixed timeline via `buildMixedFeed()` + `feedPostsProvider`: posts, interleaved **event cards**, and a **Suggested for you** rail (**Follow** vendors · **Add friend** planners).
- **Create post** `/post/create` from Posts FAB (Planner gate): caption + multi-photo (or text-only); author from `userAccountProvider`; new posts prepend to the feed.
- Image posts: author row (no Follow — planners use friendship), rounded media, engagement row (like/comment/share/bookmark) that **does not** navigate; media/caption opens detail.
- Overflow menu: Add friend / Message (gated on accepted friendship) + share/save/mute/report.
- Video posts: full-bleed media, bottom gradient → scaffold color, overlay author/caption, frosted play.
- Engagement: InkWell/IconButton with real handlers (toggle like, comment sheet, bookmark).

## Inspiration

- Prototype: `prototypes/inspiration.html`. Flutter: `lib/src/features/inspiration/`.
- Tab `/inspiration`: visual discovery (not a second social feed).
- Shell app bar + bottom nav; **no** create-post FAB.
- Optional event context chip (“For {event}”) when an event is active.
- **Your boards** horizontal row (new board + collage covers).
- Category chips: All / Décor / Tenues / Tables / Lieux / Fleurs / Menus…
- **Masonry/grid** of look tiles (image-first, light category tag + bookmark).
- Secondary **Near you** rail — public celebration looks by city.
- Look detail: full-bleed hero, tags, short copy, vendor tease → Vendors.
- Primary actions: **Use for {event}**, **Same vibe vendors**, **Ask AI**, **Save to board**.
- Save sheet: create board + existing boards list (toast on save).
- **Board detail**: collage hero, title + look count, linked event chip, short blurb, “Vendors in this vibe” chips, masonry of saved looks.
- Board dock CTAs: **Use for {event}** / Link to event, **Find vendors**, **Ask AI** (about the whole board).
- Look opened from a board returns to that board on back.
- **Create board** (3 steps): name + optional note → link event / skip → cover + vibe tags → lands on empty (or seeded) board detail.
- Entry: “New board” pill, or “Create new board” from save sheet (seeds the look being saved).
- Boards bridge to Events / Vendors / AI — collecting & deciding, not commenting-first.

## Events

- Tab `/events`: “Your events” + filter chips (All / Upcoming / Planning / Past) + `EventCard` list.
- Create `/event/create`: **6-step funnel** — Type → Details (themed glass calendar) → Visibility (private/friends/public) → Entry (free/paid + ticket page if paid) → Budget → Review. App-bar **X** / system back exits the whole funnel with Save draft · Discard · Stay. Bottom **Back** only goes to the previous step.
- Events list: chips **My events / Around me / Upcoming** + horizontal **date strip** (today → upcoming).
- Detail `/events/:id`: tabs **Overview · Budget · Vendors · Tasks · Invites** (+ **Tickets** when paid) only for the **creator** (`isMine`). Other users get Overview only — no budget, tasks, invites, vendors, or visibility controls.
- **Vendors tab**: list of prestataires contacted for this event (`EventVendorLink`); filters All / Contacted / Working with. Working with = linked to ≥1 budget category. Assign/clear categories (multi-select; several vendors per category). Find vendors CTA passes `eventId` into contact flow.
- **Budget tab**: each line shows linked vendor chips; link/unlink vendors from the event’s contacted list.
- Contact vendor: choose (or inherit) an event; on accept, upserts `EventVendorLink`. Chat remains per vendor.
- Create details step: optional **cover photo** (gallery/camera) + short **description**. Empty cover → type default Unsplash cover. Date picker starts from **today** (no past dates).
- **Entry step**: Free (RSVP invites) vs Paid (ticket page: title, description, price XAF, quantity). Info note clarifies entry ≠ planning budget.
- **Invites tab**: customized invitation card (3 styles), share/copy link, auto-accept vs manual RSVP, invitee list with Pending/Accepted/Rejected filters + Accept/Reject, PDF guest list of accepted invitees.
- Money amounts use `intl` (`formatEventMoney`). Dialogs/modals use glassmorphism + gold border (`AppGlassDialog`).
- Defaults from `EventTemplates` by `EventType` (wedding, birthday, corporate, brunch, engagement, other). Currency XAF.
- Budget health: healthy · over-allocated · below recommended (guest×type) · under-allocated.
- Empty: muted calendar + “Plan your first celebration” CTA.
- Feed + search reuse seed `mockEvents`; mutable list via `eventsProvider`.

## Post detail

- Extend under frosted app bar; comment composer in column under list (keyboard safe).
- Composer: avatar + outlined field (scaffold fill) + shell FAB may hide when keyboard open.

## Vendors

- Search field, category chips, optional **AI matched vendors** banner (sparkles on gold circle).
- Vendor cards: image, meta, Contact / profile actions.
- Empty: muted icon + short message.
- **Follow** is vendor-only (anyone can follow). Contact/chat requires Planner space + an event-scoped connection.

## Contact vendor

- Full-screen over shell (`/vendors/:id/contact`) — **event required** (pick or inherit `eventId`).
- Vendor header card + event chips.
- Quick-ask chips prefill the inquiry.
- Message field + pinned **Send request** stadium CTA (keyboard-safe).
- LinkedIn-style accept/decline for the vendor; chat opens only after accept.
- Vendor→vendor contact blocked — `runInActiveSpace(Planner)`.

## Vendor profile

- Full-screen (`/vendors/:id`) with frosted app bar + favorite action.
- Hero image (AI Match badge when relevant), identity, rating, stats card.
- About, service chips, horizontal gallery, details rows.
- Sticky bottom: **Follow** + **Contact for event** (Planner space gate; chat if already accepted).

## Become a vendor onboarding

- Hub `/vendor-onboarding` with 1/3 progress + checklist tiles.
- Step 1 identity, Step 2 services/pricing/modalities, Step 3 KYC/KYB (mock uploads).
- Independent steps, draft save, SharedPreferences resume.
- Profile banner until approved; demo Approve/Request info while `pending_review`.
- Active space switcher: Planner | Vendor (gates Vendor until approved).

## Vendor manage profile (self)

- Full-screen `/vendor-onboarding/manage` — same layout as public vitrine (`/vendors/:id`).
- Per-section Edit / Add actions (photo, identity, about, services, gallery, details).
- Past-events gallery with remove on each tile.
- Profile card → manage when approved; otherwise → onboarding hub.
- Hub CTA “Manage vendor profile” when `canOfferServices`.

## AI event chat (target recipe)

When building AI chat for events:

1. **Context chip** at top — active event name (e.g. “Summer Wedding”).
2. **Message list** — AI bubbles = `surface` card; user bubbles = `primaryContainer` or soft gold wash; timestamps muted.
3. **Suggestions** (optional) — 2–3 gold-outline chips (“Find florists”, “Guest list tips”).
4. **Composer** — pinned bottom: text field + send; align with mic FAB / voice entry.
5. **Empty state** — calm headline + one line (“Ask anything about your event”) + one CTA; no dashboard widgets.
6. Keyboard: same pattern as post comment composer.

## Auth

- Frosted/transparent app bar, `AppRootLayout` + `extendUnderAppBar`.
- Stadium gold primary buttons; outlined social / secondary.

## HTML prototype mapping

```css
:root {
  --primary: #D3AF35;
  --on-primary: #1A0F2F;
  --bg-purple: #1A0F2F;
  --surface-purple: #241939;
  --muted-purple: #89809C;
  --bg-light: #F4F1F9;
  --surface-light: #FFFFFF;
  --muted-light: #6E6682;
  --radius: 16px;
  --font: "DM Sans", system-ui, sans-serif;
}
```

Frame width ~390px; use Dark (purple) theme as default prototype unless user asks Light.
