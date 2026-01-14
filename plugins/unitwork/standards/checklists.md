# Implementation Checklists

Checklists for before writing code, during implementation, and before PR submission. Derived from the most common PR feedback patterns.

---

## Before Writing Code

Run through this checklist BEFORE implementing:

### Search First
- [ ] **Searched for existing utilities** that do what I need
  - Error handling utilities
  - Parallel execution utilities
  - Timing/measurement utilities
  - Domain-specific utilities in the area I'm working in
- [ ] **Searched for similar patterns** elsewhere in the codebase
- [ ] **Checked framework/library features** that might handle this

### Design Considerations
- [ ] Is this the **simplest approach** that works?
- [ ] Am I **leveraging existing patterns** rather than inventing new ones?
- [ ] If adding to shared infrastructure, is it **generic enough**?
- [ ] If this requires configuration, where does it **logically belong**?
- [ ] For functions with 4+ params, should I use a **single args object**?

### Database (if applicable)
- [ ] Do **indexes exist** for columns I'm filtering on?
- [ ] Am I using a **query builder** instead of raw SQL?
- [ ] Have I checked for **overlapping indexes** I might consolidate?
- [ ] Could this data be **computed on-the-fly** instead of stored?

---

## During Implementation

### Type Safety
- [ ] **No type casting** (`as SomeType`) to access properties
- [ ] Type guards **validate all properties** that will be accessed
- [ ] Fields are **non-nullable when guaranteed** to exist
- [ ] Using **generated types** where available
- [ ] Python has **type hints** on all functions

### Null Handling
- [ ] Using **`null` for absence**, not empty strings or zeros
- [ ] Not using **default fallbacks** that mask missing data
- [ ] Optional fields are **truly optional**, not always present

### Error Handling
- [ ] Errors **propagate to callers** (services don't swallow errors)
- [ ] Error messages include **sufficient context** for debugging
- [ ] External services have **graceful degradation**

### Naming
- [ ] Not using **domain-specific terms** for unrelated concepts
- [ ] No **abbreviations** in public APIs
- [ ] **Consistent terminology** (not mixing state/status, etc.)
- [ ] Following **language conventions** (snake_case, camelCase, etc.)

### Code Organization
- [ ] **No barrel files** (index.ts re-exports)
- [ ] Code is **near its domain context**, not in generic utils
- [ ] Tests are at the **service layer** for business logic
- [ ] 4+ params uses **single args object**

### Schemas (if applicable)
- [ ] JSON schemas have **`required` array**
- [ ] JSON schemas have **`additionalProperties: false`**

### Configuration
- [ ] Time durations use **named constants**
- [ ] Magic values use **named constants** with clear names
- [ ] Rate limit keys include **tenant identifiers**
- [ ] Non-obvious values have **documentation**

---

## Before Submitting PR

### Cleanup
- [ ] **Removed all debug code** (print, console.log)
- [ ] **Removed commented-out code**
- [ ] No **AI-generated artifacts** (unnecessary reorganization, generic comments)
- [ ] Diff contains **only intentional changes**

### Scope
- [ ] PR is **focused on single concern**
- [ ] No **unrelated changes** mixed in
- [ ] No **"helpful" additions** beyond the task

### Tests
- [ ] Test names **accurately describe** what's tested
- [ ] Tests **updated** to match implementation changes
- [ ] Using **realistic test data**
- [ ] No **committed test output files**

### Database (if applicable)
- [ ] New queries verified with **EXPLAIN ANALYZE**
- [ ] **Redundant indexes** dropped in same migration
- [ ] Index changes **documented**

### Security
- [ ] Authorization is **appropriately restrictive**
- [ ] User input is **sanitized** before use
- [ ] Not **logging PII** or sensitive data
- [ ] Sensitive operations have **appropriate permissions**

### Comments
- [ ] Unusual patterns have **"why" comments**
- [ ] No **"what" comments** (code is self-describing)
- [ ] Magic numbers have **explanatory comments or constants**
- [ ] Workarounds are **documented**

---

## Quick Reference - Most Common Issues

**Top 5 issues by frequency:**
1. **BETTER_IMPLEMENTATION_APPROACH (18%)** - Search first, leverage framework features
2. **TYPE_SAFETY_IMPROVEMENT (12%)** - No casting, complete type guards
3. **EXISTING_UTILITY_AVAILABLE (10%)** - Search codebase before implementing
4. **CODE_DUPLICATION (8%)** - Check for existing implementations
5. **NULL_HANDLING (6%)** - Use null, not empty strings

**Zero-tolerance items:**
- No type casting to access properties
- No barrel files
- No debug code in PRs
- Errors propagate (services don't catch)
- Null represents absence

---

## Self-Review Shortcuts

Before submitting, run these quick checks:

```bash
# Search for type casting
grep -rn "as [A-Z]" [changed files] | grep -v "// safe cast"

# Search for empty string fallbacks
grep -rn '?? ""' [changed files]
grep -rn "?? ''" [changed files]

# Search for debug code
grep -rn "console.log" [changed files]
grep -rn "^[^#]*print(" [changed files]  # Python

# Check for barrel files
git diff --name-only | grep "index.ts"
```

---

## Severity Quick Reference

**Tier 1 (Correctness) - Always Higher Priority:**
- Security vulnerabilities (P1)
- Architecture problems
- Implementation bugs
- Type safety violations
- Functionality gaps

**Tier 2 (Cleanliness) - Lower Priority:**
- Naming clarity
- File organization
- Code duplication
- Comment quality
- Style consistency

At the same P-level, address Tier 1 issues before Tier 2 issues.
