# Test Plan: {Feature Name}

**Date:** {DD-MM-YYYY}
**Branch:** {branch-name}
**Repos Analyzed:** {list of repos with their type, e.g., "Backend (current), Frontend (~/path/to/frontend)"}

## Feature Summary
{1-3 sentence summary of what the feature does, derived from diff analysis}

## Changed Files

### Backend
- `{file}`: {what changed}

### Frontend
- `{file}`: {what changed}

## Prerequisites
- {prerequisite 1, e.g., "Log in as a user with admin permissions"}
- {prerequisite 2, e.g., "Navigate to Settings > Integrations"}
- {prerequisite 3, e.g., "Ensure local backend is running on port 8001"}

## Test Steps

### Step 1: {action title}
{Detailed instruction of what to do}

**Verify:** {Expected outcome - what you should see or confirm}

### Step 2: {action title}
{Detailed instruction of what to do}

**Verify:** {Expected outcome}

<!-- Continue with sequential steps. Happy path first, then edge cases woven in. -->
<!-- Each step should be concrete: use specific test data, name exact UI elements, describe exact expected behavior. -->

## Edge Cases Covered
- {edge case 1}: Tested in Step {N}
- {edge case 2}: Tested in Step {N}

## Visual/Layout Checks (Human Only)
- Step {N}: {what needs human eyes - spacing, alignment, responsiveness, styling}
