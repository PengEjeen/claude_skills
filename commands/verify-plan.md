# Verify Plan

Summarize the verification plan for changed files before running checks.

## Usage

`/verify-plan [files|staged|all]`

## Instructions

1. Read `rules/verification.md`.
2. Inspect the requested changed file set:
   - no argument or `files`: use modified and untracked files from `git status --short`
   - `staged`: use staged files from `git diff --cached --name-only`
   - `all`: use all changed files from `git diff --name-only HEAD` plus untracked files
3. Classify each file with the same policy as `hooks/verification-planner.sh`.
4. Print a concise plan grouped by risk.
5. Do not execute the checks. This command is for plan review before running verification.

## Output

Use this format:

```markdown
VERIFY PLAN: advisory

High Risk:
- <file>
  Checks: <command list or none>
  Manual: <manual checks or none>

Medium Risk:
- <file>
  Checks: <command list or none>
  Manual: <manual checks or none>

Low Risk:
- <file>
  Checks: none
  Manual: none

Next:
- Confirm this plan before running `/verify` or manual commands.
- Do not apply migrations or Terraform changes from this command.
```

## Arguments

$ARGUMENTS:
- `files` - modified and untracked files
- `staged` - staged files only
- `all` - all changed files
