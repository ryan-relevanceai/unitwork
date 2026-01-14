# Learnings: Learnings Format Improvement
Date: 14-01-2026
Spec: .unitwork/specs/14-01-2026-learnings-format-improvement.md

## Summary
Refactored the learnings template and uw-compound command to focus on the journey (deviations, surprises, patterns) rather than duplicating spec content like file paths and implementation details.

## What Deviated from Spec
- Spec said "Out of Scope: Modifying Hindsight retain patterns" but we significantly simplified them during review: the review found that showing 4 separate retain calls leaked implementation details, so we replaced with one concrete example + guidance bullets. The spec was too conservative about what could change.

## Gotchas & Surprises
- First draft duplicated the same anti-pattern it was trying to fix: the new template had verbose inline prompts that repeated section header meaning, and the command had a "Memory Format Guidelines" section that duplicated what the template already expressed. Documentation refactoring is susceptible to the same problems it's solving.

## Generalizable Patterns
- Concrete examples over abstract placeholders: When documentation shows template syntax like `<feature type>`, users don't know if it's literal or should be substituted. Always include one filled-in example (e.g., "OAuth integrations") alongside the template.
- Flexible sections with "(if any)": When a template has multiple optional sections, mark them explicitly so users don't feel forced to fill empty sections with filler content.
- One source of truth: If guidance appears in the template structure, don't repeat it in a separate "guidelines" section. Choose one place for each piece of information.
