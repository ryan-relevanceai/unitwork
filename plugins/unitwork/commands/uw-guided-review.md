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

## TURN 1 — The Dump

**You emit ONE message containing every section below. No interaction. No `AskUserQuestion`. No splitting across turns.** Stop after the dump and wait for the user's single reply.

### Header banner

Open the dump with an explicit framing line so the user knows the protocol:

> **Answer everything below in ONE reply.** Don't skip questions. Don't ask me to continue. I'll respond once after you answer — with my own take side-by-side against yours, plus heuristics you can carry forward.

### Section A: Inventory

Silently analyze the PR diff and surface the **raw inventory** for the user to chew on before the questions start. Inventory contents:

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
My answer:   {AI's own answer based on the diff + memory + review-standards}
Delta:       {one-line gap analysis — what did each side surface that the other missed?}
```

Keep it tight. One question per block. No re-asking. No "great answer!" filler.

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
6. **Do NOT spawn subagents.** All inventory analysis + question generation + reveal happens inline. This command is about user cognition, not AI throughput.
7. **Every question MUST carry a *Why we ask* annotation.** No exceptions. Without the annotation, the user gets a worksheet; with it, they get a transferable mental model. The pedagogical layer is the durable value.
8. **PR-only.** Reject branch-diff and area-audit inputs upfront. Point users at `/uw:review` for those.
9. **No retain pass.** Ephemeral session = no Hindsight retain at the end. (Recall at the start is mandatory; retain at the end is forbidden.)

---

## Why this exists

`/uw:review` is the right tool when you need findings shipped fast — AI does the audit, presents P1s, fixes them. But it has a cost: the human reviewer stops engaging. They scroll past AI's findings, hit approve, and lose the chance to build their own review intuition.

`/uw:guided-review` flips that. AI surfaces the *raw material* (inventory, magic numbers, asymmetries) and the *questions a staff engineer would ask*, then steps back. The user does the cognition. The *Why we ask* annotations make every question a teaching moment. Over enough sessions, the user internalizes the heuristics and starts asking them on every PR — without ever running this command again.

That's the goal: **make yourself unnecessary**.
