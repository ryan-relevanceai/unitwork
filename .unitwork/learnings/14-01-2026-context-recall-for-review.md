# Learnings: Context Recall for uw:review

Date: 14-01-2026
Spec: N/A (single-feature enhancement, no formal spec)

## Summary

Added Context Recall section to `/uw:review` that recalls past review learnings from Hindsight before spawning agents, then routes domain-specific memories to appropriate agents. This mirrors the pattern from `/uw:work` (v0.2.2) for consistency.

## Generalizable Patterns

- **Symmetry across workflow phases**: When adding a capability to one workflow phase (uw:work got Context Recall in v0.2.2), consider whether other phases need the same capability. uw:review needed it too so past review learnings inform current reviews.

- **Domain-specific routing for memories**: Rather than dumping all recalled memories to all agents, route memories to agents by topic (type safety learnings → type-safety agent). This keeps agent context focused and relevant.
