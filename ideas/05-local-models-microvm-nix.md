# Local Models in Per-Project MicroVMs via Nix Flakes

## Problem

Running a local model (see
[04-manual-rag-local-model](04-manual-rag-local-model.md)) on the
host machine mixes model-serving dependencies (Ollama, CUDA
libraries, model weights) with the project environment. Different
projects may need different models or versions. There is no
isolation or reproducibility.

## Proposal

Define a microVM in the project's `flake.nix` using
`nixos-generators` or `microvm.nix`. The VM spec declares the
model, Ollama version, resource limits (RAM, vCPU), and any exposed
ports. Running `nix run .#vm` (or similar) boots a Firecracker or
QEMU microVM with the model server ready, scoped entirely to that
project.

This pairs with [04-manual-rag-local-model](04-manual-rag-local-model.md)
-- the RAG pipeline in the host project points at `localhost:<port>`
where the per-project VM is serving the model.

## Trade-offs

- MicroVM boot time adds latency vs. a long-running host Ollama
  daemon. Firecracker boots in ~125ms but model load time dominates.
- Model weights are large. Storing them in the Nix store or as
  a flake input is impractical -- they need to be fetched separately
  and mounted into the VM, which complicates the "fully reproducible"
  story.
- GPU passthrough to microvms is non-trivial. Without it, inference
  is CPU-only and slow for larger models.

## Open Questions

- `microvm.nix` vs. `nixos-generators` vs. hand-rolled NixOS VM
  config -- which has the best developer ergonomics for this use
  case?
- How are model weights managed? Options: download at VM first boot,
  declare a content-addressed fetch in the flake, or mount from a
  host path.
- Does this compose well with
  [01-nix-direnv-worktrees](01-nix-direnv-worktrees.md)? The VM
  definition could live in `.envrc` so it starts when you enter the
  project directory.
- See also: `firecracker/` in this repo. Existing work is
  shell-script-based (Arch rootfs, bridge networking, manual host
  setup) -- not Nix-managed. The gap to a declarative
  `flake.nix`-driven VM is significant; that work would need to be
  redone using `microvm.nix` or `nixos-generators`.
