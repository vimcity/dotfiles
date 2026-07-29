# AIChat Local Setup

This is the local-docs assistant path. Keep Codex for repo edits;
use `ask` for quick one-shot questions; use AIChat RAG when you want answers
grounded in your dotfiles, Neovim config, and CLI help captures.

## Configure Models

The tracked `aichat/config.yaml` is the portable local configuration. Copy or
link it to:

```text
~/Library/Application Support/aichat/config.yaml
```

Chat traffic uses oMLX. RAG embeddings are optional — configure
`rag_embedding_model` in your local copy if you add an embedding provider.

## Build The Corpus

```sh
ask --build-devdocs
```

This writes a curated corpus to:

```text
~/dotfiles/.local-ai/devdocs
```

## Initialize The RAG

```sh
ask --init-devdocs
```

When AIChat prompts for documents, paste:

```text
dotfiles/.local-ai/devdocs/
```

After that:

```sh
ask --devdocs "what binding opens the local AI popup?"
```

Re-run `ask --build-devdocs` after meaningful doc/config changes.
