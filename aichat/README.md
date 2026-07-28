# AIChat Local Setup

This is the local-docs assistant path. Keep Codex for repo edits;
use `ask` for quick one-shot questions; use AIChat RAG when you want answers
grounded in your dotfiles, tmux workflow, Neovim config, and CLI help captures.

## Configure Models

The tracked `aichat/config.yaml` is the portable local configuration. Copy or
link it to:

```text
~/Library/Application Support/aichat/config.yaml
```

It points chat traffic at oMLX and uses Ollama for optional local embeddings:

```sh
ollama pull nomic-embed-text
```

RAG will not work with only an oMLX chat model. AIChat needs an embedding model
to index and search documents.

## Build The Corpus

```sh
ask --build-devdocs
```

This writes a curated corpus to:

```text
~/dotfiles/.local-ai/devdocs
```

It includes selected dotfiles docs/configs and command help captures. It does
not index your whole home directory.

## Initialize The RAG

Run:

```sh
ask --init-devdocs
```

When AIChat prompts for documents, paste:

```text
dotfiles/.local-ai/devdocs/
```

After that, ask local-doc questions with:

```sh
ask --devdocs "what tmux binding opens the local AI popup?"
```

Re-run `ask --build-devdocs` after meaningful doc/config changes. If files have
changed inside the existing RAG, run this in AIChat:

```text
.rag devdocs
.rebuild rag
```
