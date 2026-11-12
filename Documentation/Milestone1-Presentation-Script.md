# Scrap — Milestone 1 Presentation Script
### 15-minute single-narrator script — September 24, 2026

*Timing cues are approximate, based on a natural speaking pace of about 140 words per minute. Bracketed notes are stage directions, not spoken text — pause on them if you're pairing this with slides.*

---

## Opening (0:00–1:00)

Good [morning/afternoon]. We're Team Scrap, and today we're presenting our Milestone 1 design proposal.

Here's the one-line version of what we're building: Scrap is a mobile app that tells you what you can cook *right now*, using the ingredients you already have — instead of starting from a recipe and making you go buy things.

*[Advance: title slide]*

## The Problem and Our Mission (1:00–3:00)

Here's a number to start with: the average American consumer loses about seven hundred dollars a year to food they buy and never eat. Across the country, over a third of the food we produce is never eaten at all, and a lot of that waste happens right at home — over-buying, poor planning, ingredients that get forgotten in the back of the fridge. And using up leftovers before they spoil turns out to be one of the single most effective things a household can do to cut that waste down.

We didn't just find those numbers in a report — we lived a version of this problem. All three of us are college students who moved into apartments and suddenly had to figure out cooking and grocery shopping on our own, on a student budget, in small kitchens. We talked to several people outside our own group about this directly, and heard the same pattern over and over: recipes assume you're starting from zero and buying a full ingredient list, which means you end up with half-used bags of things you'll never finish, and a lot of stress deciding what to make in the first place.

So our mission with Scrap is to make cooking easier, more affordable, more fun, and less wasteful, by flipping the normal recipe search around: instead of picking a recipe and shopping for it, you tell Scrap what you already have, and it finds recipes ranked by how much of that recipe you can already make. Whatever's missing becomes your grocery list.

*[Advance: mission / key drivers slide]*

## Key Drivers and Constraints (3:00–5:00)

Four things are driving our design decisions: ease, affordability, reducing waste, and — importantly — making this social rather than just another utility app. We want people to browse and share recipes with each other and feel like part of a community of home cooks, not just run a search and close the app.

We're also being realistic about our constraints. This is a crowded market — there are a lot of recipe and meal-planning apps out there already, so our ingredient-first approach has to actually feel different, not just be a feature buried somewhere in someone else's app. None of us has built a full production app before, so there's a genuine learning curve with the tools we've chosen, and that affects how much scope we can realistically take on. And because the whole app depends on having good recipe and ingredient data, we had to make a deliberate, specific call about where that data comes from and how it's stored — which I'll get to now.

*[Advance: development plan slide]*

## Development Plan — What We're Actually Building (5:00–8:30)

Concretely: Scrap is a native iOS app, built in Swift and SwiftUI, following Apple's own frameworks and design guidelines rather than a cross-platform tool — that keeps us close to the platform and avoids an extra abstraction layer while we're all still learning it. For the backend, we're using Supabase: a hosted Postgres database with built-in authentication and file storage, so we're not building or running our own server. Our schema covers users, pantry items, recipes, recipe ingredients, and grocery list items, and the app talks to it over Supabase's own Swift SDK. For recipe and ingredient data, we're using the Spoonacular API, which gives us ingredient-based search out of the box, merged with recipes our own users contribute directly.

Alongside the app, we're also building a small companion website — a separate, static site whose only job is introducing Scrap to people and pointing them to the app. It shares no code and no backend with the app itself; it's really a marketing and advertising piece more than a technical one.

On testing: core logic like ingredient matching and grocery-list generation gets unit tested with XCTest, and key flows like account creation and recipe search get UI tested with XCUITest. Before we release anything publicly, it goes out to a small group of beta testers through Apple's TestFlight first, and any bugs we find along the way get tracked in GitHub Issues.

On process: we're working out of a shared GitHub repository, each of us on our own branch so we're not stepping on each other's work, merging in once a feature actually works. We keep our report and research in shared documents, use a group messaging platform for quick day-to-day questions, and check in with each other constantly through the week — not just at our next class — so if someone's stuck, the team finds out early instead of right before a deadline. And no matter who's working on a piece, nobody merges AI-generated code without a second person on the team looking it over first.

We've also been upfront with ourselves about risk. The biggest one is that all three of us are learning this exact stack — Swift, SwiftUI, Supabase — at the same time, so our first stretch of real development will probably be slower than later stretches; our plan is to start with one small, well-scoped feature rather than several things in parallel. We're also depending on Spoonacular as an outside service we don't control, so we're building in handling for when it fails or returns something unexpected. And because our full feature list is bigger than what's realistic in the time we have, we've already marked a few features — like recipe videos, leftover tracking, expiration alerts, and barcode scanning — as bonus, not required, so the core experience stays achievable no matter what.

## Roles and Responsibilities (8:30–9:15)

Each of us leads a specific piece of this. Deanna owns the product side — grooming our backlog, deciding what's required versus bonus each sprint, and setting how we use AI well as a team. Samah owns the technical build end to end — the app itself, the backend, and our testing. And Salome owns the business side — understanding what makes Scrap different from what's already out there, running our companion website as a marketing tool, and, drawing on her finance background, keeping an eye on our budget so we don't get surprised by our free-tier limits.

## How We're Using AI (9:15–9:45)

Since we're building most of this with AI assistance, we want to be upfront about how. We use it to help with the coding itself, and, for this report, to help us structure and write up decisions we've already made ourselves — not to make those decisions for us. Every meaningful use is logged in our report's AI Prompt Log, and as I mentioned, no AI-written code gets merged without one of us reviewing it first. We treat it as a tool that speeds up execution, not as a replacement for actually understanding what we're shipping.

*[Advance: timeline slide]*

## Timeline (9:45–11:15)

We're planning the fall in two-week checkpoints. This report, today, is checkpoint one. By October 8th we want our Xcode project set up and talking to Supabase. By October 22nd, our first real end-to-end slice: enter what's in your pantry, get back a ranked recipe search. By mid-November we want the rest of our core screens built and the full database schema wired up, which lines up with our Preliminary Design Review. And our target for December 3rd, right before winter break, is a complete working prototype.

Spring is farther out, so we're planning it by month instead of by the week: January is about getting a small group of real beta users onto the app through TestFlight. February and March are about iterating on what they tell us, and — this is where our business side comes in — starting to actually grow our user base, not just keep building features in a vacuum. We wrap the year with our final report and demo in May.

## User Stories, Requirements, and Use Cases (11:15–13:45)

Everything we're building traces back to actual people. We interviewed several people outside our own group directly, and deliberately went beyond just end users — we also wrote stories for the people building this with us, for the business side, and even one about keeping the community feed safe from bad content. For example, one of our core stories is simple: as a college student cooking in a small kitchen, I want to see which recipes I can already make, so that I don't waste time gathering ingredients. All fourteen of our stories follow that same one-sentence shape, on purpose, so they stay sharp and easy to trace back to a specific requirement.

From those stories we've written eighteen functional requirements — things the app actually does, like ingredient matching, recipe ranking, and grocery list generation. We also have non-functional requirements, like the app staying usable and responsive even with a large pantry list; constraints, like everything being built on free-tier services, which is exactly why we picked Supabase and Spoonacular in the first place; and thirteen technical requirements covering the specific platform and architecture decisions I already walked through.

We've also written ten use cases that walk through exactly how a real interaction plays out step by step. As one example: a user opens the app, enters the ingredients sitting in their kitchen, and Scrap returns a ranked list of recipes by how much of each one they can already make; if they're missing something, they can add it straight to a grocery list with one tap. Every one of our requirements is checked against use cases like that one, and we keep a full traceability matrix in the report so nothing falls through the cracks — every story maps to requirements, and every requirement maps to at least one use case.

*[Advance: closing slide]*

## Closing (13:45–15:00)

So to sum up: Scrap solves a real problem we've all run into ourselves — food and money wasted because cooking starts from the wrong end. We've picked a stack we can realistically build in the time we have, split the work across our own strengths, been honest about the risks, and laid out a concrete, dated plan that gets us to a working prototype by early December and real users testing it by the spring. Every piece of that plan — the requirements, the use cases, the timeline — is documented and cross-referenced in the full report, so it's easy to see exactly where any part of this came from.

Thank you — we're happy to take any questions.

---

*[Note: this script runs close to the full 15 minutes as written, which should leave a little room for slide transitions and pacing without feeling rushed. If you need to trim it further, the Development Plan and User Stories/Requirements sections are the easiest to shorten — cut a sentence or two rather than a whole paragraph so the flow still holds together.]*
