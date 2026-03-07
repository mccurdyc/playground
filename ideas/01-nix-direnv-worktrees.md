# Nix direnv with Git Worktrees via Symlinked State

## Problem

Nix direnv evaluations are slow. When using git worktrees, each
worktree gets its own `.direnv/` state, triggering a full
re-evaluation per worktree. This makes terminal launches painfully
slow.

## Proposal

Symlink the `.direnv/` state directory in each worktree back to
the main worktree's `.direnv/`. This way, the Nix environment is
built once in the main worktree and shared across all worktrees.

## Trade-offs

- All direnv/Nix changes must be made against the main worktree.
  This is acceptable -- centralizing environment changes is
  preferable to slow terminal launches in every worktree.
- Worktrees cannot have divergent Nix environments. If a worktree
  needs a different flake input or package, the main worktree must
  be updated first.

## Open Questions

- Should the symlink be automated via a post-checkout hook or a
  wrapper script around `git worktree add`?
- How does this interact with `direnv allow` -- does each worktree
  need its own `.envrc` allow, or does the symlink bypass that?
- Does garbage collection in one worktree affect the shared state?
