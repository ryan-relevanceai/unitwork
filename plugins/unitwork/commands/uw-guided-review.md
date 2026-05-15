---
name: uw:guided-review
description: Active-learning PR review coach. AI asks Socratic questions in one dump, holds opinion until reveal. Pedagogical layer (Why we ask) compounds review skill across sessions.
argument-hint: "[pr <number>]"
---

# Active-learning PR review coach

## Introduction

**Coaching, not auditing.** When AI does the review, the human goes complacent — P1s slip past because AI "already looked." This command inverts the dynamic: AI is a staff-engineer-style coach that asks Socratic questions, holds back its own opinion until the very end, and forces the user to do the cognitive work.

**Two goals:**
1. **Active engagement** — user does cognition, not AI.
2. **Pedagogical compounding** — every question carries a *Why we ask* annotation explaining the staff-engineer heuristic behind it. Over sessions, the user learns to ask these questions without running the command.

**Delivery model: single-dump.** AI produces ONE long message containing the full inventory + every question across all steps + a risk-summary template. User responds in ONE long answer. AI then produces ONE reveal/compare turn. **Target: 2 AI turns total.** No `AskUserQuestion`. No per-step prompts. No splitting the dump across multiple turns.

**Depth model: 2-agent parallel + inline scan.** Halfway between coaching and full audit. `/uw:review` fans out to 7 agents and takes ~15 minutes — that latency kills the coaching loop. Pure inline scan misses too many subtle issues. Compromise: spawn **at most 2 high-leverage agents in parallel** (`architecture` + `patterns-utilities`) for the categories that benefit most from a dedicated prompt, then **inline-scan** the remaining patterns from `review-standards` (47 patterns total). The two-agent picks aren't arbitrary — `patterns-utilities` covers the Top 5 frequency patterns (~54% of real issues); `architecture` covers the highest-leverage failure mode (wrong direction makes all detail review moot). All findings — agent-returned or inline-flagged — stay internal during TURN 1 and surface only in TURN 2 with pattern names + `file:line` citations. If the user wants the exhaustive multi-agent audit, they run `/uw:review` separately.

**PR-only.** This command requires a PR description + commit log to frame against. Branch-diff and area-audit modes are rejected — use `/uw:review` for those.

**Coexists with `/uw:review`.** Pick audit mode (AI-driven, comprehensive) when you need findings shipped fast. Pick guided mode (active learning + skill-building) when you want to internalize the review heuristics yourself.

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before loading skills. Before reading the diff. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose accumulated learnings from past reviews and may surface questions the team has already internalized — or miss questions the team learned to ask the hard way.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall review-related learnings BEFORE any other work (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "code review learnings, past mistakes, type safety issues, security issues, pattern violations, magic numbers, asymmetries" --budget mid --include-chunks
```

### Display Learnings

After recall, display relevant learnings to the user before the dump:

```
**Relevant Learnings from Memory:**
- {past review finding or gotcha}
- {pattern violation discovered before}
```

If no relevant learnings found: "Memory recall complete - no relevant learnings found for this review."

Recalled learnings inform what to scrutinize in the inventory pass (silently), and may be cited in the reveal turn when they directly apply.

**DO NOT PROCEED to Required Reading until memory recall is complete.**

---

## Required Reading

Load the `review-standards` skill silently. It contains the 47 issue patterns + team standards. Use it internally to inform what the inventory pass scrutinizes and what your own answers reference during the reveal — **do not show its content to the user during the dump**. The dump is for questions, not for an audit.

---

## Source Resolution (PR-only)

Parse the argument:

**`pr <number>` provided:**
```bash
gh pr view $PR_NUMBER --json title,body,files,additions,deletions,commits
gh pr diff $PR_NUMBER
```

**No argument (auto-detect):**
```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

- Single PR found → confirm with user, then load.
- Multiple PRs → present list, ask user to pick.
- No PR found → ask for a PR number manually.

**Reject branch-diff and area modes.** If the user passes `area <path>` or supplies only a base branch, respond:

> This command is PR-only — it needs a PR description + commit log to frame against. Run `/uw:review` for branch-diff or area audits.

Do not proceed without a PR.

---

## Silent Audit Phase (before TURN 1)

**This phase runs entirely before any user-visible output.** It exists to give the dump real depth — without it, the questions are vibes and the reveal is shallow. The audit uses **at most 2 parallel subagents** for the highest-leverage categories, with everything else scanned inline. `/uw:review` fans out to 7 agents and takes ~15 minutes; that latency kills the coaching loop. Two agents in parallel cap the wall-clock at the slowest single agent — typically 2-4 minutes — while still beating pure inline scan on the patterns that benefit most from a dedicated prompt.

### Step S1 — Pre-walkthrough checks (inline)

Three lightweight diff scans:

1. **Unrelated Changes Check** — flag files whose presence doesn't match the PR title/purpose. Each becomes a candidate Step 0 scope-creep question.
2. **Removed Export Impact Check** — parse the diff for removed/renamed exports; grep the codebase for surviving usages. Each surviving usage becomes a candidate per-file question.
3. **New Concept Inventory** — list new types, IDs, terminology, module names. Each becomes a candidate "is this concept well-defined?" question.

### Step S2 — Architectural Zoom-Out (inline)

Read the full diff holistically against the `ARCHITECTURAL_DIRECTION` pattern from `review-standards`. Ask:

- Is this building something new when an existing module should be extended?
- Is logic in the wrong layer?
- Is this solving a symptom instead of the root cause?
- Is this reimplementing a flow that already exists?

If sound, note "Architectural direction: sound" in scratchpad. If concerns exist, draft an `Architectural Direction` observation — **save it for TURN 2**, do not surface in TURN 1.

### Step S3 — 2-agent parallel spawn + inline scan

**Hard cap: 2 subagents.** Spawn both in parallel via two `Task` tool calls in a single response. Picked for signal-per-agent, not arbitrarily:

1. **`architecture`** — runs the architectural-direction + file-organization + boundary-violation scan. Catches the failure mode that wastes all subsequent detail review when wrong.
2. **`patterns-utilities`** — runs the Top-5-frequency scan (`BETTER_IMPLEMENTATION_APPROACH` 18%, `EXISTING_UTILITY_AVAILABLE` 10%, `CODE_DUPLICATION` 8%, `MAGIC_NUMBER`, etc.). One agent covers ~36% of real issues.

Pass each agent:
- The PR diff
- Pre-walkthrough findings from Step S1 (so agents know what's already flagged)
- New-concept inventory from Step S1 (explicit scrutiny targets)
- Recalled memories routed to their domain:

  | Memory Topic | Route To Agent |
  |--------------|----------------|
  | Patterns, utilities, duplication, naming | `patterns-utilities` |
  | Architecture, file organization, boundaries | `architecture` |
  | General gotchas | Both |

Agents return findings in standard format (pattern name, severity, location, why, fix).

**Inline scan covers the rest of the 47 patterns** — main thread walks these against the diff while the 2 agents run in parallel. Categories to scan inline:

- **`type-safety`** patterns: grep for `as `, `!.`, missing nullable handling, `any` types. These are surface-readable from the diff.
- **`security`** patterns: only if diff touches user-input flows, auth, query construction, or HTML rendering. If no signals, skip.
- **`performance-database`** patterns: only if diff touches queries, loops over DB calls, or index-relevant schemas. If no signals, skip.
- **`simplicity`** patterns: redundant logic, debug code, unused exports — scan visually.
- **`memory-validation`** patterns: cross-check diff against any memory entries recalled in Step 0.

**Always-P1 set** (zero-tolerance — scan every PR inline, never skip):

- Any injection vulnerability
- Authentication/authorization bypass
- XSS in user content
- Security boundary violations
- Type casting to access properties
- Barrel files / debug code / swallowed errors

Let file character guide which inline patterns apply. UI file → XSS + null handling. Query file → injection + N+1. New service → already covered by `architecture` agent.

Recalled memories route into the inline scan too: if memory flagged a past type-safety bug, scrutinize the `TYPE_SAFETY_IMPROVEMENT` pattern harder on this PR.

### Step S4 — Lightweight verification (inline)

Merge findings from the 2 agents + inline scan into one scratchpad. For each candidate finding, run a fast verification pass — not the full `/uw:review` gate:

1. **Read the file at `file:line`** — does the claim actually hold? (One Read tool call per finding, no verification chain.)
2. **In-scope?** Pre-existing issues go to the held-back section in TURN 2 (informational only), not the dump.
3. **Dedupe** — if the `architecture` agent and inline scan flag the same issue, keep one entry. If `patterns-utilities` and inline scan overlap, keep the agent's (richer fix detail).
4. **Classify** as `VERIFIED` (keep), `DISMISSED` (discard), or `INFORMATIONAL` (existing code, held for TURN 2).

Goal: avoid coaching the user against false positives. If a finding survives a 30-second sanity check, keep it. Verification cost stays linear in findings, not multiplicative.

### Step S5 — Finding → Question translation

Convert each `VERIFIED` finding into a Socratic question that surfaces the *category* of issue without revealing the answer. Examples:

| Finding (internal) | Question (in dump) |
|--------------------|--------------------|
| `UNNECESSARY_CAST at src/api.ts:42 — uses 'as RequestBody' to access .userId` | "How do you feel about the type assertions on `src/api.ts:42`? What does the cast assert that the compiler can't prove?" |
| `MAGIC_NUMBER at src/bulk.ts:14 — MAX_BULK_ROWS = 500, no source cited` | "Why 500 for `MAX_BULK_ROWS` and not 100 or 1000? Where does that number come from?" |
| `EXISTING_UTILITY_AVAILABLE at src/format.ts:8 — re-implements pluraliseWord` | "Take a look at the helper on line 8 — does anything in the codebase already do this?" |
| `INJECTION_VULNERABILITY at src/query.ts:30 — raw SQL interpolation` | "Walk through how user input flows into the query on `src/query.ts:30`. What controls each variable?" |

Rules:
- **Never name the pattern** in the question. Pattern names show up in TURN 2 only.
- **Never state the severity**. Surface severity through user thinking.
- **Always carry a *Why we ask* annotation** explaining the underlying heuristic — not the specific finding.
- **One finding per question** when practical; combine when two findings share a heuristic on the same file.

Aim for ≥ 80% of `VERIFIED` findings represented in the dump. The rest go to the TURN 2 "Findings I held back" block (typically because they don't fit a Socratic frame).

### Step S6 — Architectural observation (if drafted)

If Step S2 flagged a directional concern, draft a single open question for Step 3 that surfaces the direction without naming it. Example: "If you were starting this PR over with the same goal, would you keep the same structure? Where would you diverge?" *Why we ask: most PRs have sound direction with imperfect execution — but the few that don't waste all subsequent execution work. Ask once.*

---

## TURN 1 — The Dump

**You emit ONE message containing every section below. No interaction. No `AskUserQuestion`. No splitting across turns.** Stop after the dump and wait for the user's single reply.

### Header banner

Open the dump with an explicit framing line so the user knows the protocol:

> **Answer everything below in ONE reply.** Don't skip questions. Don't ask me to continue. I'll respond once after you answer — with my own take side-by-side against yours, plus heuristics you can carry forward.

### Section A: Inventory

Surface the **raw inventory** for the user to chew on before the questions start. This is structural observation only — magic numbers, asymmetries, classifications — **not** agent findings. Pattern names, severities, and audit verdicts stay buried until TURN 2. Inventory contents:

- **PR metadata summary** — problem statement from description + listed concerns from commit log. If the PR description is empty or thin, **flag that as itself a review concern** and fall back to commit messages.
- **File classification** — split into **Modified** (touched existing logic) vs **Additive** (purely new files). Within each group, order by **information density** — smallest informative file first, then larger. This lets the user warm up on tight diffs before tackling sprawl.
- **Magic numbers** — extract with `file:line` annotations (e.g., `MAX_BULK_ROWS = 500` at `src/bulk.ts:42`, `max(20)` at `schemas/sets.ts:18`).
- **Asymmetries** — call out gaps like "7 new tools registered, only 5 have title overrides — why the gap?" or "added X in 3 files, only updated tests for 2."
- **New concepts** — new types, IDs, terminology, module names introduced in this PR.
- **Cross-cutting / drive-by changes** — config, `package.json`, `tsconfig`, lockfile, CI workflows.
- **Reversibility + blast-radius assessment** — one or two lines per: how reversible is this change, what's the blast radius if it's wrong?

**Large-PR guardrail:** if `modified + additive > 15` files, pick the top-N by information density and add a one-line note: "Questions truncated to top-N files by information density; rerun on a narrower subset for full coverage."

### Section B: Step 0 — Frame the PR

4 framing questions + a carry-forward prompt. Each question MUST carry a *Why we ask* annotation.

Example shape (vary per PR; do not paste verbatim):

> **Q0.1** — In one sentence, what problem does this PR solve, in the user's words (not the code's)?
> *Why we ask: the PR description and the code often disagree about scope. Stating the problem in your own words surfaces the gap before you grade the solution.*
>
> **Q0.2** — What is the scope-creep risk here? Is anything in the diff outside the stated problem?
> *Why we ask: drive-by changes hide in legitimate PRs. If you can't justify a file's presence against the problem statement, it probably shouldn't be there.*
>
> **Q0.3** — How reversible is this change once shipped? What's the rollback story?
> *Why we ask: irreversibility (db migrations, public APIs, persisted IDs) raises the review bar dramatically. Reversible changes can be shipped on lower confidence.*
>
> **Q0.4** — What is the blast radius if the core assumption is wrong?
> *Why we ask: scope of blame ≠ scope of impact. A 10-line change can take down a whole product surface; a 500-line refactor can be perfectly contained.*
>
> **Carry-forward prompt** — Write 2-3 questions you want to remember to ask on every future PR like this one. Don't worry about polish — first instinct is the goal.
> *Why we ask: the durable value of this session isn't the answers — it's the questions you keep. Naming them now forces them to stick.*

### Section C: Step 1 — Modified files

For each **modified** file (in information-density order, smallest informative first):

- **File header** — path + a one-line summary of what changed.
- **2–4 questions** per file. **Always lead with:**
  > **Q** — Why does this file appear in the diff at all? What forced the change?
  > *Why we ask: modified files are the highest-risk surface — they touched code that already worked. Forcing intent before judgment is the staff-engineer move.*
- Follow with file-specific questions targeting magic numbers, asymmetries, or new concepts you flagged in the inventory. Each carries *Why we ask*.

### Section D: Step 2 — Additive files

Same structure as Step 1 for each **additive** (purely new) file. **Always lead with:**

> **Q** — Why does this new file justify its existence vs. extending something existing?
> *Why we ask: new files are the cheapest abstraction to add and the most expensive to remove. Surface area is hard to take back; default should be "extend, don't add."*

Follow with 1–3 file-specific questions, each annotated.

### Section E: Step 3 — Architectural questions

3–5 questions covering the directional shape of the PR. Examples (vary per PR):

> **Q3.1** — Name one alternative architecture you'd consider for this same problem. What would you give up?
> *Why we ask: "no alternative considered" is itself a code smell. If you can't name the road not taken, you can't grade the road taken.*
>
> **Q3.2** — What's the simplest MVP version of this PR? Which 30% of the diff carries 80% of the value?
> *Why we ask: scope-trim discipline. The cheapest review fix is the deletion you propose before shipping, not the feature you add after.*
>
> **Q3.3** — How easy is it to build the next feature on top of this? Where will the next PR have to reach into this one?
> *Why we ask: today's interface is tomorrow's coupling. Reviewing for the next PR's pain catches abstraction mistakes that look fine in isolation.*
>
> **Q3.4** — How many files outside the diff would need to change if the core abstraction here is wrong? (N files touched = N future miss-points.)
> *Why we ask: coupling cost is paid in future bug reports, not in code review. Quantifying it forces honesty about lock-in.*
>
> **Q3.5** — Does the PR description match the actual code? Where do they disagree?
> *Why we ask: when description and code diverge, one of them is lying. Naming the gap is half the review.*

### Section F: Step 4 — Risk-summary TEMPLATE

**Provide a skeleton only — never a draft.** The user fills this in themselves as they answer.

```
## Risk summary (you fill this in)
- Top risk:
- Reversibility:
- Blast radius:
- One thing I'd push back on before approving:
```

Rationale: if AI drafts the bullets up front, the user copies them. The template forces independent thinking. **AI's own draft of the risk summary is held until TURN 2.**

### Closing instruction

End the dump with a single line reiterating the protocol:

> Answer everything above in **one reply**. I'll respond exactly once after that — with my own answers side-by-side, plus heuristics to carry forward to the next PR.

**Stop. Wait for the user's single reply. Do not say anything else.**

---

## TURN 2 — The Reveal

After the user's reply, emit ONE consolidated message containing:

### Side-by-side comparison

For each question in the dump, in order:

```
**Q0.1** — In one sentence, what problem does this PR solve?

Your answer: {user's answer, verbatim or paraphrased}
My answer:   {AI's own answer — for finding-derived questions, cite the verified
              finding with pattern name + `file:line` from the Silent Audit Phase
              scratchpad. For framing questions, draw on the diff + memory.}
Delta:       {one-line gap analysis — what did each side surface that the other missed?}
```

Keep it tight. One question per block. No re-asking. No "great answer!" filler.

**For findings that didn't fit a Socratic frame in TURN 1** (held back from the dump per Step S5), add a short section after the per-question blocks:

```
### Findings I held back from the dump

- `{PATTERN_NAME}` at `file:line` — {one-line description}. Severity: {P1/P2/P3}, Tier {1/2}.
- {more if any}
```

This is the only place raw findings appear in the user-visible output. Keep this section terse — no fix code, no walls of text. The user can rerun `/uw:review` if they want the full audit.

**Architectural Direction observation** (if Step S2 flagged one):

```
### Architectural Direction (informational)

{Description of the directional concern.}
```

This is not actionable by this command — it's a flag for the user to consider before approving.

### AI risk-summary draft

Now — and only now — produce your own risk-summary bullets in the same shape as the template, for comparison against the user's filled-in version.

```
## Risk summary (my draft, for comparison)
- Top risk: ...
- Reversibility: ...
- Blast radius: ...
- One thing I'd push back on before approving: ...
```

### Meta — heuristics that surfaced

Name the staff-engineer patterns this session exercised. Examples:

- **WHY-before-WHAT** — leading with intent before judgment.
- **Asymmetry scrutiny** — gaps between parallel things are signals.
- **Magic-number challenge** — every constant has a source; demand it.
- **Coupling cost** — N files touched = N future miss-points.
- **PR-desc-vs-code consistency** — divergence between description and diff is a code smell.
- **Info-density ordering** — review smallest informative diffs first; they compound understanding.

Pick the 3–5 that actually got exercised. Don't list all of them by default.

### Heuristics to carry forward

A short, plain-language summary the user can remember next week without rerunning this command. One line each, max 5 lines. Plain prose, not a checklist dump.

Example:

> 1. On every PR, ask "why is this file here?" before "is this code good?"
> 2. Every magic number gets a "where did this come from?" — load test, prod p99, vendor limit, or guess?
> 3. Count the files outside the diff that would break if the abstraction is wrong. That's the real review surface.

**Stop. Do not loop back. Do not ask follow-up questions. The session is over.**

---

## Hard Rules (Guardrails)

These are non-negotiable. Violating any of them collapses the command back into vanilla `/uw:review`:

1. **Do NOT use `AskUserQuestion`** anywhere in this command. Single dump → single user reply → single reveal. That's it.
2. **Do NOT split the dump across multiple turns.** Everything in TURN 1 ships in one message.
3. **Do NOT reveal your own take in TURN 1.** Inventory is descriptive (magic numbers, asymmetries, classifications). Questions are open. Opinions wait until TURN 2.
4. **Do NOT draft the risk-summary bullets in TURN 1.** Template only. The draft appears in TURN 2.
5. **Do NOT write to disk.** This command is **ephemeral** — no `.unitwork/guided-reviews/` directory, no artifact files, no Hindsight retain at the end. The session leaves only the risk summary the user pastes into the PR review themselves.
6. **Spawn AT MOST 2 subagents** — `architecture` + `patterns-utilities`, both in parallel via a single response with two `Task` calls. Never more. Never the full `/uw:review` 7-agent fan-out. Every other pattern category gets scanned inline by the main thread. If the user wants the exhaustive audit they run `/uw:review` separately.
7. **Do NOT leak findings into TURN 1.** All inline-audit output stays internal until TURN 2. No pattern names, no severities, no `file:line` audit lines in the dump. If a finding shows up in TURN 1, it must be reshaped as an open question.
8. **Every question MUST carry a *Why we ask* annotation.** No exceptions. Without the annotation, the user gets a worksheet; with it, they get a transferable mental model. The pedagogical layer is the durable value.
9. **PR-only.** Reject branch-diff and area-audit inputs upfront. Point users at `/uw:review` for those.
10. **No retain pass.** Ephemeral session = no Hindsight retain at the end. (Recall at the start is mandatory; retain at the end is forbidden.)

---

## Why this exists

`/uw:review` is the right tool when you need findings shipped fast — AI does the audit, presents P1s, fixes them. But it has a cost: the human reviewer stops engaging. They scroll past AI's findings, hit approve, and lose the chance to build their own review intuition.

`/uw:guided-review` flips that. AI runs a **2-agent parallel + inline** audit (`architecture` + `patterns-utilities` in parallel, rest of the 47 patterns scanned inline by the main thread) — heavier than vibes, lighter than the full `/uw:review` fan-out — and **hides the findings**, translating them into Socratic questions. The user surfaces the issue category through their own thinking; AI's verified findings appear only in TURN 2 to grade the answer. The *Why we ask* annotations make every question a teaching moment. Over enough sessions, the user internalizes the heuristics and starts asking them on every PR — without ever running this command again. If they want the exhaustive multi-agent audit, they run `/uw:review` separately.

That's the goal: **make yourself unnecessary**.
