# opencode Session Lifecycle Management

## Problem

opencode accumulates sessions over time -- untitled sessions from
throwaway usage and stale sessions that are no longer relevant.
There is no automatic cleanup, so the session list grows unbounded
and becomes noisy.

## Proposal

Enforce a session retention policy at session start or exit:

- Delete any session with no title (untitled/default name).
- Delete any session older than 7 days.

This could run as a hook -- either when opencode starts, when it
exits, or both.

## Trade-offs

- Running at startup has the benefit of a clean session list before
  you pick one, but adds latency to launch.
- Running at exit is less disruptive but means stale sessions linger
  until the next close.
- Deleting untitled sessions aggressively assumes the user always
  titles sessions they want to keep. If opencode doesn't make
  titling easy or prompt for it, sessions get silently lost.

## Open Questions

- Does opencode expose a CLI or API for session deletion, or would
  this require directly manipulating its state files on disk?
- Where does opencode store session state? (`~/.local/share/opencode`
  or similar?)
- Should the 7-day threshold be configurable?
- Is "untitled" a reliable signal, or does opencode auto-generate
  names that are effectively meaningless?
