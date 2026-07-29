#!/usr/bin/env bash
# Symlink tracked llm config into the datasette llm user directory.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
LLM_DIR="${LLM_DIR:-$HOME/Library/Application Support/io.datasette.llm}"
TEMPLATES_DIR="$LLM_DIR/templates"

mkdir -p "$TEMPLATES_DIR"

ln -sf "$DOTFILES_DIR/llm/extra-openai-models.yaml" "$LLM_DIR/extra-openai-models.yaml"

for template in "$DOTFILES_DIR/llm/templates/"*.yaml; do
    [[ -f "$template" ]] || continue
    ln -sf "$template" "$TEMPLATES_DIR/$(basename "$template")"
done

if command -v llm >/dev/null 2>&1; then
    llm aliases set local omlx-qwen 2>/dev/null || true
    llm aliases set remote gpt-4o-mini 2>/dev/null || true
    llm aliases set fast omlx-coder 2>/dev/null || true
fi

printf 'llm config linked into %s\n' "$LLM_DIR"

