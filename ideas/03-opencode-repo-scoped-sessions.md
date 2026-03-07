# Repository-Scoped opencode Sessions

## Problem

opencode stores all sessions in a single global store. When working
across multiple repositories, sessions from different codebases are
intermixed, making it hard to find relevant history. There is no
locality between a session and the code it was about.

## Proposal

Scope session storage to the repository root. When opencode is
launched from within a git repo, sessions are stored under
`.git/opencode/` (or a configurable path) rather than the global
state directory. Launching outside a repo falls back to the global
store.

Using `.git/` as the storage root means session data travels with
the repo, is excluded from the working tree, and is automatically
scoped without any naming convention.

## Trade-offs

- Sessions in `.git/` are not committed and won't survive a fresh
  clone -- this is probably the right default, but worth noting.
- Worktrees share the same `.git/` directory (via the main worktree
  or `.git` file pointer), so sessions would naturally be shared
  across worktrees of the same repo. This is likely desirable but
  could cause noise if worktrees are used for very different tasks.
- Tooling that wipes or re-creates `.git/` (e.g., some CI setups)
  would silently destroy session history.

## Open Questions

- Does opencode support configuring the session storage path, or
  would this require a wrapper that sets an env var / config before
  launch?
- Should `.git/opencode/` be the path, or is there a better
  `.git/`-adjacent location (e.g., alongside `.git/` as
  `.opencode/`, gitignored)?
- How does this interact with
  [02-opencode-session-lifecycle](02-opencode-session-lifecycle.md)?
  A per-repo store likely needs its own retention policy.
- Should sessions be indexable globally (e.g., a global index that
  references per-repo stores) for cross-repo search?
