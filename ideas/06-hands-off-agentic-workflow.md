# Hands-Off Agentic Workflow with a Human Merge Gate

## Problem

Current AI-assisted coding requires constant supervision -- reviewing
each step, approving tool calls, correcting course mid-task. This is
babysitting. But the opposite extreme (fully autonomous merge) is
also wrong: code you plan to live with deserves scrutiny before it
lands.

The missing piece is a workflow where the agent works autonomously
end-to-end, but nothing merges without explicit human approval at
the PR boundary.

## Proposal

Let the agent run fully unsupervised: read code, write code, run
tests, iterate, open a PR. The human's only required touch point is
the PR review. If the PR is bad, close it. The cost of a bad PR is
low; the cost of babysitting every keystroke is high.

This aligns with Mitchell Hashimoto's framing: for some tasks the
implementation does not matter -- a wedding website for a friend,
a one-off script, a throwaway prototype. Ship it, don't read it.
For other tasks -- software you will interact with daily, that you
will debug at 2am, that reflects how you think about a problem --
the implementation matters. You need to read it, understand it, and
be willing to own it. Those PRs deserve real review, not rubber
stamping.

The workflow is the same in both cases (agent works, human gates at
PR). What changes is how much scrutiny you apply at the gate.

## Trade-offs

- An agent that can open PRs can also make a large mess that is
  tedious to untangle. The PR gate only helps if you actually read
  the diff.
- Autonomous agents tend to go down wrong paths confidently. Without
  mid-task correction, a bad initial interpretation compounds. The
  PR review may arrive after significant wasted work.
- The "implementation doesn't matter" category is harder to define
  in practice than in principle. Be honest about which bucket a
  project is actually in before handing it off fully.

## Open Questions

- What is the right signal for "this is code I will live with"?
  Is it: touches a critical path, has existing tests, is in a
  repo you maintain long-term?
- How do you prompt the agent to produce a PR that is actually
  reviewable -- small, focused, with a useful description -- rather
  than a 2000-line diff?
- Does this compose with
  [03-opencode-repo-scoped-sessions](03-opencode-repo-scoped-sessions.md)?
  The agent's session context should probably be scoped to the repo
  so it has relevant history without noise from other projects.
