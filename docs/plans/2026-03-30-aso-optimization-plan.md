# ASO Ultimate Plan — MatrixHabit
> Created: 2026-03-30 | Status: FINAL — Synthesized from 4-agent swarm review
> Agents: ASO Strategist, Conversion Specialist, Growth Hacker, Devil's Advocate

---

## Executive Summary

**ASO Score: 39/100. Zero ratings. Invisible for all high-traffic keywords.**

After independent research, cross-validation against the live App Store listing, and adversarial review, the team converged on this plan. Key debates were resolved as follows:

| Decision | Strategist | Conversion | Growth | Devil's Advocate | **FINAL** |
|----------|-----------|------------|--------|-----------------|-----------|
| Category switch? | Don't switch | Switch | Neutral | DON'T switch | **Keep H&F, add Productivity as secondary** |
| Subtitle word choice | "66-Day Streak & Habit Builder" | Keyword-rich | Neutral | Kill jargon, use human language | **"66-Day Streak & Habit Builder"** — best keyword/human balance |
| Review prompt spacing | 30 days | Neutral | 30 days | Keep 90, fix bugs first | **45 days + pre-screen + fix annual reset bug** |
| Free habit limit | Keep 2 | Neutral | Keep 2, free widgets | Increase to 3 | **Keep 2, make widgets free** |
| Description opening | Matrix theme | Problem-first | Neutral | Problem-first, theme later | **Problem-first** |
| Keyword "formation" | Swap out | Neutral | Neutral | Swap out | **Replaced with "quest"** |
| Keyword "morning" | Keep | Neutral | Neutral | Drop (intent mismatch) | **Dropped** |
| Search Ads | Not mentioned | Not mentioned | Not mentioned | Even $20/mo helps | **Recommend $20-40/mo** |

---

## Ground Truth (Verified from Live App Store, March 30 2026)

```
App Name:     MatrixHabit - Habit Tracker
Subtitle:     66-Day Streaks & XP Quests
Category:     Health & Fitness
Rating:       No ratings (0 reviews)
Price:        Free | IAP: Red Pill $3.99 (one-time)
Version:      1.1 (released ~1 day ago)
Size:         8.1 MB
Platforms:    iPhone, iPad, Mac (Silicon), visionOS
Developer:    Timur iuldashevi
What's New:   "Premium unlock available. Bug fixes and performance improvements."
Screenshots:  6 phone + 4 iPad (show EMPTY app state — Day 0, 0 XP, CRITICAL)
```

### Current Rankings
| Keyword | Rank | Traffic | Difficulty |
|---------|------|---------|------------|
| matrixhabit | #1 | 43 | 34 |
| offline habit tracker | #7 | 38 | 40 |
| private habit tracker | #14 | 39 | 39 |
| break bad habits | #70 | 40 | 35 |
| habit tracker | Not ranked | 57 | 85 |
| habit builder | Not ranked | 66 | 44 |
| streak tracker | Not ranked | 53 | 43 |

---

## THREE PROBLEMS (in priority order)

### Problem 1: Zero Ratings (Conversion Killer)
- No star rating displayed = 15-25% lower conversion than apps with 5+ ratings
- No social proof for a $3.99 IAP from unknown developer
- Apple's algorithm has no quality signal to boost rankings
- **This blocks everything else.** Perfect keywords still won't convert without ratings.

### Problem 2: Screenshots Show an Empty App
- Current screenshots show Day 0, 0 XP, "SYSTEM STATUS: CRITICAL," 0% completion
- Users see a dead-looking app and bounce
- First 2 screenshots are onboarding screens (terminal text, pill choice) — not the product
- **User never sees what the app actually does unless they scroll past 3 screenshots**

### Problem 3: Metadata Wastes Prime Real Estate
- Subtitle "XP Quests" = zero search volume, zero user comprehension
- Only 8 indexed words across all metadata (should be 20+)
- Description leads with movie reference instead of user problem
- What's New is generic boilerplate

---

## THE PLAN

### PHASE 1: App Store Connect Metadata (No Code Required)

All Phase 1 changes happen in App Store Connect. Can be submitted with next version update. Promotional text can change immediately without review.

#### 1A. Title
```
Current:  MatrixHabit - Habit Tracker  (28 chars)
Final:    MatrixHabit: Habit Tracker   (27 chars)
```
Indexed words: `matrixhabit`, `habit`, `tracker`

#### 1B. Subtitle ⭐ HIGHEST-IMPACT METADATA CHANGE
```
Current:  66-Day Streaks & XP Quests        (26 chars → 0 useful new keywords)
Final:    66-Day Streak & Habit Builder      (30 chars → 4 new indexed words)
```
New indexed words: `66`, `day`, `streak`, `builder`

**Why this won over alternatives:**
- "Gamified 66-Day Streak Builder" — rejected. "Gamified" is jargon that normal users don't search for or understand. Devil's Advocate correctly identified this as developer-speak.
- "Build Habits in 66 Days" — rejected. Only 23 chars, wastes 7 characters. Missing "streak" and "builder."
- "Offline 66-Day Streak Builder" — considered. Protects #7 ranking but "offline" is better served in keyword field (combines with everything).
- "66-Day Streak & Habit Builder" — **accepted.** Human-readable, every word is searchable, "Habit" reinforces primary keyword, "&" is natural. Creates: "habit builder" (traffic 66), "streak tracker" (53), "streak builder" (low comp), "66 day habit" (38).

#### 1C. Keyword Field (100 characters)
```
routine,daily,offline,private,break,bad,self,improvement,challenge,goal,quest,discipline,quit,game
```
*98 characters. 14 keywords. Zero duplication with title/subtitle.*

**What changed from the earlier draft and why:**

| Removed | Why | Replaced With | Why |
|---------|-----|---------------|-----|
| `formation` | Academic jargon. Nobody searches "habit formation" | `quest` | Enables "habit quest" — low competition, perfect product fit (XP/quests exist in-app) |
| `morning` | Intent mismatch. "Morning routine" searchers want alarm/routine apps, not habit trackers | `discipline` | Enables "self discipline" — high intent, aligns with 66-day message |
| `productive` | Borderline intent match, but dropped for higher-value additions | `quit` | Enables "quit bad habits," "quit smoking" — high intent, Agents feature is a perfect match |
| — | — | `game` | Enables "habit game" — low competition, gamification niche |

**Total unique indexed words: 21**
- Title (3): matrixhabit, habit, tracker
- Subtitle (4): 66, day, streak, builder
- Keywords (14): routine, daily, offline, private, break, bad, self, improvement, challenge, goal, quest, discipline, quit, game

**Top 15 cross-field search phrases this unlocks:**

| Phrase | Traffic | Difficulty | Can Rank Top 20 in 90d? |
|--------|---------|------------|------------------------|
| habit builder | 66 | 44 | Yes — top 15 |
| streak tracker | 53 | 43 | Yes — top 15 |
| offline habit tracker | 38 | 40 | Already #7 → push to #3 |
| private habit tracker | 39 | 39 | #14 → push to top 5 |
| break bad habits | 40 | 35 | #70 → top 15 |
| 66 day habit | 38 | 42 | Yes — top 10 |
| daily habit tracker | 50 | 55 | Needs 5+ ratings |
| habit challenge | 40 | 38 | Yes — top 15 |
| self discipline | 42 | 40 | Yes — top 15 |
| habit quest | 30 | 25 | Yes — top 5 |
| goal tracker | 48 | 55 | Needs ratings |
| streak builder | 28 | 20 | Yes — top 3 |
| quit bad habits | 35 | 30 | Yes — top 10 |
| habit game | 35 | 35 | Yes — top 10 |
| 66 day challenge | 35 | 35 | Yes — top 10 |

#### 1D. Category
```
Current:  Primary = Health & Fitness | Secondary = (none?)
Final:    Primary = Health & Fitness | Secondary = Productivity
```

**Why we're NOT switching primary to Productivity:**
1. Risk of losing #7 and #14 rankings. Category is a ranking signal. With 0 ratings, we have zero buffer to absorb a ranking drop.
2. Health & Fitness is where habit trackers live. Streaks, Atoms, Done are all there. Users browsing this category expect habit apps.
3. Productivity is NOT less competitive for habit trackers — it's dominated by Todoist, Things, Notion.
4. Adding Productivity as secondary still gets us browse visibility there.
5. We can revisit after 20+ ratings when we have ranking momentum to absorb disruption.

#### 1E. Promotional Text (170 chars — change anytime, no review needed)
```
Can't stick with habits? 66 days. Gamified. Offline. No subscriptions. Try 2 habits free.
```
**Why problem-first:** With zero ratings, lead with value proposition, not features. Switch to widget-focused text after novelty period.

**Rotation schedule:**
- Now: Problem-first (above)
- After 10+ ratings: "NEW: Lock screen widgets. Check in without opening the app. 66 days to unbreakable habits."
- January 2027: "New year, new powers. 66 days to build habits that actually stick. Try free."

#### 1F. Description (Conversion Copy — NOT indexed by Apple)

**Problem-first opening (above the fold — only text most users see):**
```
Struggling to build habits that stick? Most people give up by day 7.

MatrixHabit uses the 66-day science of habit formation — the real
number backed by research — to help you build good habits and
break bad ones. Gamified, offline, and private.
```

**Full description:**
```
Struggling to build habits that stick? Most people give up by day 7.

MatrixHabit uses the 66-day science of habit formation — the real
number backed by research — to help you build good habits and
break bad ones. Gamified, offline, and private.

YOUR MISSION

Build Powers (good habits) and defeat Agents (bad habits) over 66
days. Every check-in earns XP, every streak unlocks achievements,
and every day gets you closer to building an unbreakable habit.

WHAT MAKES IT DIFFERENT

• 66-Day Science — Not 21 days, not 30. Research says 66. We built
  the entire system around it.
• Powers vs Agents — Good habits are Powers you build. Bad habits
  are Agents you defeat. Track both.
• Gamified Progress — Earn XP, level up through ranks, unlock 23
  achievements. Discipline has never felt this rewarding.
• 100% Offline & Private — No accounts. No cloud. No tracking.
  Your habits stay on your device. Period.
• Lock Screen Widgets — Check in without even opening the app.
• Dark Mode Only — Built for focus, not distraction.

THE 66-DAY SYSTEM

Day 1-21:  Build momentum
Day 22-44: Strengthen resolve
Day 45-66: Cement the habit

Miss a day? Your streak resets. No negotiations.

FREE TO START

Track 2 habits completely free. Unlock unlimited habits and the
full system with a single payment — no subscriptions, no recurring
charges, ever. Just $3.99, once.

8.1 MB. Downloads in seconds. No bloat.

Love MatrixHabit? A rating helps others find it.
```

**Key changes from earlier draft:**
- Leads with user problem, not Matrix theme (Devil's Advocate was right)
- Matrix vocabulary introduced gradually ("Powers," "Agents") with explanations in parentheses
- Mentions 8.1 MB size (Conversion Specialist identified this as a trust signal)
- Mentions "$3.99, once" explicitly (anti-subscription positioning)
- Ends with soft review ask

#### 1G. What's New Text
```
What's new in 1.1:

• Lock Screen Widgets — check in without opening the app
• Home Screen Widgets — interactive habit check-in
• Widget Sync — check-ins sync instantly on app open
• Performance improvements

Your streak, always one tap away.
```

#### 1H. Screenshots ⭐ SECOND HIGHEST-IMPACT CHANGE

**Critical finding from Conversion Specialist:** Current screenshots show EMPTY app state — Day 0, 0 XP, 0% completion, "SYSTEM STATUS: CRITICAL." This makes the app look dead and punishing. Users see failure before they even download.

**First 3 screenshots appear in search results. They must sell the app alone.**

| # | Caption (benefit-first) | Screen Content | Notes |
|---|------------------------|----------------|-------|
| 1 | "Build Habits That Actually Stick" | Command Center with 3 habits at mid-progress (Day 34, streaks active) | POPULATED DATA. Never show empty state. |
| 2 | "Track Your 66-Day Streak" | Signal Analysis showing 34-day progress, weekly grid lit up, stats positive | Show success, not "CRITICAL" |
| 3 | "Earn XP & Unlock Achievements" | Achievements view with several unlocked | Show accomplishment |
| 4 | "Defeat Bad Habits" | Agents section with active resistance streaks | Show the unique Agents feature |
| 5 | "100% Offline. 100% Private." | Privacy-focused framing or settings view | Key differentiator |
| 6 | "One Price. No Subscriptions." | Red Pill paywall | Trust signal — $3.99 once |
| 7 | "Check In From Your Lock Screen" | Lock screen widget in-context | NEW — widget feature |
| 8 | "Home Screen Widgets" | Home screen with medium widget | NEW — widget feature |

**Design guidelines:**
- Dark charcoal/green marketing frames (not white — would clash with dark UI)
- Large, clean sans-serif caption text (NOT monospaced — captions must be instantly readable even though in-app uses monospace)
- Show latest iPhone frame in space black
- All screenshots show POPULATED, mid-progress data
- Move onboarding screens (terminal text, pill choice) to positions 9-10 or remove — they don't show the product

**Apple OCR indexing:** Screenshot caption text is now indexed for search. Captions like "Break Bad Habits," "66-Day Challenge," "100% Offline" provide free additional keyword coverage.

---

### PHASE 2: Code Changes (Ship in Next Update)

#### 2A. ReviewManager Overhaul ⭐ CRITICAL

**Bug found by Devil's Advocate:** `reviewRequestCount` increments forever but never resets after 365 days. After year 1, NO user will ever see a review prompt again. This must be fixed regardless of any other changes.

**New ReviewManager design:**

```
ENGAGEMENT GATES (ALL must pass before any prompt):
├── User has 2+ habits created
├── User has checked in on 5+ distinct calendar days
├── User has 10+ total check-ins across all habits
├── User has NOT broken a streak in the last 48 hours
└── No review prompt shown in last 45 days

TRIGGER CONDITIONS (any ONE fires a prompt attempt):
├── Any habit reaches 7-day streak
├── Any habit reaches 14-day streak (NEW — fills gap between 7 and 21)
├── Any habit reaches 21-day streak
├── 3rd achievement unlocked (changed from 1st — too early)
├── 7th achievement unlocked (changed from 5th)
└── 66-day streak

PRE-SCREEN (before calling SKStoreReviewController):
├── Show custom dialog: "You've hit a milestone! Enjoying MatrixHabit?"
├── "Yes!" → trigger SKStoreReviewController.requestReview()
├── "Not yet" → dismiss, eligible again at next trigger
└── "I have feedback" → open feedback email compose

TIMING:
├── minimumDaysBetweenPrompts: 45 (compromise: not too aggressive, not too conservative)
├── Annual reset: Track by calendar year, reset counter on Jan 1
└── Maximum 3 prompts per 365-day rolling window (Apple limit)
```

**Why 45 days, not 30 or 90:**
- 90 days (current): Too conservative. With triggers at streaks 7, 14, 21, the first 3 prompts span 270 days minimum. Wastes the critical early months.
- 30 days (proposed): Too aggressive per Devil's Advocate. Risk burning all 3 annual slots on dismissals in 90 days if user hits streaks quickly across 2 habits.
- 45 days: First prompt ~Day 7-10. Second ~Day 52-55. Third ~Day 97-100. Covers first 3 months without burning slots.

**Why pre-screen matters:** The #1 risk with review prompts is getting 1-2 star reviews from frustrated users (especially those hitting the 2-habit limit). The pre-screen captures negative sentiment before it becomes a public review, and saves Apple's 3 annual prompt slots for users likely to rate 4-5 stars.

#### 2B. Add "Rate" Button in Settings (ZionMainframeView)

Add in the CONSTRUCT CONFIG section after the Achievements button:

```
"TRANSMIT SIGNAL" → deep link to:
https://apps.apple.com/app/id6757750786?action=write-review
```

This catches users who dismissed the automatic prompt but later want to rate on their own schedule. Settings visitors are already invested users.

#### 2C. Make Widgets Available to Free Users

**Growth Hacker's strongest recommendation:** Widgets are the #1 passive growth loop. Every free user with a MatrixHabit widget on their lock screen or home screen is a walking billboard. The distinctive green Matrix aesthetic on a phone screen generates "what app is that?" conversations.

Currently, widgets appear to be listed as a Red Pill premium feature. Move widgets to free tier. Replace with another premium perk if needed (e.g., premium-only achievement set, or custom habit icons).

#### 2D. Add Share Cards to Milestone Celebrations

The app already has celebration overlays for streaks (7, 21, 66 days) and achievements. Add a "SHARE" button that generates a screenshot-worthy card:

- Achievement share card: icon, name, streak info, MatrixHabit branding
- 66-day completion card: "PROTOCOL COMPLETE: 66 DAYS" + habit name + app branding
- Weekly summary card: habits completed, streaks, XP earned

The Matrix-themed achievement names ("I Know Kung Fu," "The Source") are inherently shareable. These create organic distribution at zero cost.

---

### PHASE 3: Growth & Distribution (Manual Effort)

#### 3A. Personal Outreach — This Week (TARGET: 5 ratings in 14 days)

- Message every TestFlight tester with: "The app is live on the App Store now. If you've been enjoying it, an honest review would mean the world." Include App Store link.
- Ask friends/family who have iPhones to download and rate.
- **Important geographic note:** Reviews are localized by storefront. Georgian reviews only show on the Georgian store. Target English-speaking users (US/UK/CA/AU) for maximum impact.
- Even 5 genuine ratings at 4.5+ unlocks the star rating display, which changes everything.

#### 3B. Reddit Campaign — Weeks 2-4 (TARGET: 30-100 installs)

**Tier 1 subreddits (highest alignment):**
| Subreddit | Members | Post Angle |
|-----------|---------|------------|
| r/getdisciplined | 1.7M | "The science says 66 days, not 21. Here's what happened when I built an app around it." |
| r/theXeffect | 90K | "Digital version of the X-effect card system. 66 days. Matrix themed." |
| r/iosapps | 120K | Direct app showcase with screenshots |

**Tier 2 (month 2):**
| Subreddit | Post Angle |
|-----------|------------|
| r/DecidingToBeBetter | Personal story + app mention |
| r/NoFap, r/StopGaming, r/StopDrinking | "Agent" (bad habit) feature is a perfect fit |
| r/SwiftUI, r/iOSProgramming | Technical post about the hold-to-check-in gesture or SwiftData architecture |

**Rules:** Never post a bare link. Front-load value. Engage with every comment for 24 hours. Space posts 2-3 days apart.

**Devil's Advocate reality check:** Reddit self-promotion often gets downvoted. Realistic conversion: 5-20 downloads per post that stays up. The r/theXeffect post is the highest-alignment opportunity — their community literally tracks habit streaks on cards.

#### 3C. Product Hunt Launch — Week 4

- Launch Tuesday or Wednesday at 12:01 AM PT (11 AM Georgia time)
- Tagline: "Break habits like Neo breaks the Matrix. 66-day protocol."
- Ask 10-15 people to upvote and comment genuinely in first 2 hours
- **Reality check:** PH is web-focused. Expect 50-200 iOS downloads, mostly from tech workers. Worth doing for social proof and backlinks, but not a primary growth driver.

#### 3D. TikTok/Instagram Reels — Month 2 Onwards

The Matrix UI aesthetic is genuinely cinematic and TikTok-friendly:
- "This habit tracker looks like the Matrix" (scroll through dark UI)
- "Day 66. Protocol complete." (show the epic celebration with confetti)
- "My app makes you HOLD to check in" (show the hold-to-sync animation)
- 3-4 short videos per week. Screen recordings with text overlays. No face required.

#### 3E. Apple Search Ads — $20-40/month (Devil's Advocate addition)

**This was missing from the original plan and is potentially the highest-ROI item.**

Even a minimal $20-40/month budget on Apple Search Ads targets people who are searching "habit tracker" RIGHT NOW. Key advantages:
- Direct intent match (they're looking for exactly what you offer)
- You only pay per tap
- Drives real downloads that can become real ratings
- For a new app with 0 ratings, this may generate more ratings than all organic efforts combined
- Target long-tail keywords where your bid goes further: "offline habit tracker," "gamified habit tracker," "66 day habit"

#### 3F. Review Response Strategy

- Respond to EVERY review within 24-48 hours
- Positive: Brief, on-theme thanks ("Welcome to the real world")
- Negative: Acknowledge, state plan, invite email. Users who feel heard update ratings upward.

---

## EXECUTION TIMELINE

### Week 1 (IMMEDIATE)
| Action | Type | Impact |
|--------|------|--------|
| Update Promotional Text in ASC | ASC (no review) | Medium |
| Personal outreach for ratings | Manual | Very High |
| Start ReviewManager code changes | Code | Very High |
| Start share card implementation | Code | High |

### Week 2-3 (NEXT UPDATE)
| Action | Type | Impact |
|--------|------|--------|
| Submit metadata update (title, subtitle, keywords, description, What's New) | ASC | Very High |
| Submit screenshot overhaul | ASC + Design | Very High |
| Submit ReviewManager + Settings rate button | Code | Very High |
| Submit widget free-tier change | Code | High |
| Reddit campaign begins | Manual | Medium |

### Week 4
| Action | Type | Impact |
|--------|------|--------|
| Product Hunt launch | Manual | Medium |
| Set up Apple Search Ads ($20-40/mo) | Paid | High |

### Month 2-3 (ONGOING)
| Action | Type | Impact |
|--------|------|--------|
| TikTok/Reels content (3-4/week) | Manual | Medium-High |
| X/Twitter building-in-public | Manual | Medium |
| Indie Hackers launch story | Manual | Medium |
| Category switch evaluation (after 20+ ratings) | ASC | TBD |

---

## SUCCESS METRICS

| Metric | Now | 30 days | 60 days | 90 days |
|--------|-----|---------|---------|---------|
| Ratings count | 0 | 5-10 | 12-20 | 20-35 |
| Average rating | N/A | 4.5+ | 4.5+ | 4.5+ |
| Keywords in top 50 | 4 | 8-12 | 12-16 | 15-20 |
| Keywords in top 10 | 2 | 3-5 | 5-8 | 7-10 |
| "offline habit tracker" | #7 | #3-5 | #1-3 | #1-2 |
| "private habit tracker" | #14 | Top 8 | Top 5 | Top 3 |
| "habit builder" | Unranked | Top 20 | Top 12 | Top 8 |
| "break bad habits" | #70 | Top 30 | Top 15 | Top 10 |
| "gamified habit tracker" | Unranked | Top 30 | Top 15 | Top 5 |

**Honest assessment (per Devil's Advocate):** 30+ ratings in 90 days is ambitious without paid acquisition. With Apple Search Ads ($20-40/mo), it's realistic. Without, expect 10-20 ratings in 90 days. The keyword ranking targets are achievable with metadata changes alone — ratings primarily affect the medium-difficulty (50+) keywords.

---

## KEYWORDS WE SHOULD DOMINATE (Our Niches)

These are keywords where we have genuine product differentiation AND low competition:

1. **"offline habit tracker"** — We ARE this. #7 → #1.
2. **"private habit tracker"** — No accounts, no cloud. #14 → top 3.
3. **"habit quest" / "habit game"** — XP, achievements, quests in-app. Habitica (4.2★, 129 iOS ratings) is only competitor. Own this.
4. **"66 day habit" / "66 day challenge"** — Science-backed, baked into product. Life Reset is main competitor but doesn't own all variants.
5. **"break bad habits" / "quit bad habits"** — Agents feature is literally designed for this. #70 → top 10.
6. **"streak builder"** — In our subtitle. Almost zero competition.
7. **"self discipline"** — 66-day protocol IS a discipline system. Low competition.

---

## BUGS TO FIX (Found During Review)

### BUG: ReviewManager never resets annual counter
**File:** `Services/ReviewManager.swift`
**Issue:** `reviewRequestCount` increments forever, checked against `maxRequestsPerYear = 3`, but never resets after 365 days. After first year of use, no user will ever see a review prompt again.
**Fix:** Track first prompt date. If 365+ days have passed since first prompt, reset counter to 0.

### BUG: Achievement trigger fires too early
**File:** `Services/ReviewManager.swift:34`
**Issue:** `checkForReviewAfterAchievement()` fires on `achievementCount == 1` — this is the "First Signal" achievement for logging your very first check-in. User has zero investment. Wasted prompt slot.
**Fix:** Change triggers from `[1, 5]` to `[3, 7]`.

---

## WHAT WE CHOSE NOT TO DO (And Why)

| Rejected Idea | Why |
|---------------|-----|
| Switch primary category to Productivity | Too risky with 0 ratings. Could lose #7 and #14 rankings with no buffer to recover. Revisit after 20+ ratings. |
| "Gamified" in subtitle | Jargon. Normal users don't search for or understand "gamified." |
| "formation" in keyword field | Academic term. Real users search "build habits" not "habit formation." |
| "morning" in keyword field | Intent mismatch. Morning routine searchers want alarm/routine apps, not habit trackers. |
| Increase free limit to 3 habits | Debated. Keep at 2 for now but make widgets free instead. Revisit if ratings skew negative citing the limit. |
| Preview video (now) | Medium effort for uncertain gain. Do this in Month 2-3 after screenshot overhaul proves conversion improvement. |
| Localization | Good idea but deprioritized. English-speaking markets (US/UK/CA/AU) are priority. Consider adding after hitting 30+ ratings. |
