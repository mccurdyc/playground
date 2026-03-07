# Manual RAG Pipeline with a Local Model (credit: Zeke)

## Problem

AI coding assistants like opencode and Claude rely on proprietary
models, opaque system prompts, and built-in context retrieval that
you cannot inspect or control. It is not clear what context is
being fed to the model, why, or whether it is relevant. The system
prompt shapes model behavior in ways that are invisible to the user.

## Proposal

Build a minimal, manual RAG pipeline:

1. Run a local open-weight model via Ollama. Note: Gemini and Claude
   are proprietary and cannot be run locally. Realistic options are
   `qwen2.5-coder`, `deepseek-coder-v2`, or `codellama`.
2. Embed the codebase (or relevant subset) into a local vector store
   (e.g., `pgvector`, `chroma`, or even flat cosine similarity over
   stored embeddings).
3. At query time, retrieve the top-k relevant chunks and construct
   the prompt manually -- no system prompt, just retrieved context
   + the question.
4. Observe how the model behaves without a system prompt shaping its
   persona or constraints.

The goal is to understand what a baseline model actually does with
raw retrieved context, versus what layers of prompt engineering in
commercial tools are doing on your behalf.

## Trade-offs

- Local models are significantly behind frontier models on coding
  tasks. The output quality will be lower, especially for complex
  reasoning. This is a learning/research exercise, not a
  productivity replacement.
- Embedding and retrieval quality matters enormously. Bad chunking
  or irrelevant retrieval produces worse results than just pasting
  context manually.
- No system prompt means no guardrails, but also no hidden
  instructions steering the model away from what you asked.

## Open Questions

- Which embedding model to use? Running a separate local embedding
  model (e.g., `nomic-embed-text` via Ollama) keeps everything
  offline. Using an API embedding model is faster but defeats the
  "local" goal.
- What chunking strategy makes sense for code? File-level,
  function-level, and sliding-window all have different trade-offs.
- Is the interesting finding about RAG quality, model quality, or
  what system prompts in commercial tools are actually doing?
