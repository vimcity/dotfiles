#!/usr/bin/env bash
# Symlink tracked llm config into the datasette llm user directory.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
LLM_DIR="${LLM_DIR:-$HOME/Library/Application Support/io.datasette.llm}"
TEMPLATES_DIR="$LLM_DIR/templates"

mkdir -p "$TEMPLATES_DIR"

export OMLX_API_BASE="${OMLX_API_BASE:-${OMLX_URL:-http://127.0.0.1:8000}/v1}"
export OMLX_MODEL="${OMLX_MODEL:-Qwen3.6-35B-A3B-OptiQ-4bit}"
export OMLX_CODER_MODEL="${OMLX_CODER_MODEL:-Qwen2.5-Coder-32B-Instruct-4bit}"
python3 - "$DOTFILES_DIR/llm/extra-openai-models.yaml" "$LLM_DIR/extra-openai-models.yaml" <<'PY'
from pathlib import Path
import os, sys
source, target = map(Path, sys.argv[1:])
text = source.read_text()
text = text.replace('${OMLX_API_BASE}', os.environ['OMLX_API_BASE'])
text = text.replace('Qwen3.6-35B-A3B-OptiQ-4bit', os.environ['OMLX_MODEL'])
text = text.replace('Qwen2.5-Coder-32B-Instruct-4bit', os.environ['OMLX_CODER_MODEL'])
target.write_text(text)
PY

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

