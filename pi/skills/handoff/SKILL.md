---
name: handoff
description: Create or update a concise plan so another session can continue the current work.
argument-hint: "<plan path> [topic or scope]"
disable-model-invocation: true
---

# Handoff

Use this when the user wants to continue work in a fresh session or preserve the current session as a concise plan.

## Workflow

1. Use `~/Documents/org/plans` as the default location. If the user names an existing plan, update that file; otherwise create a concise plan there with a descriptive filename.
2. Read the existing handoff before editing. Preserve prior findings and append a dated refresh unless the user explicitly asks for a rewrite.
3. Use whatever context is already available in the session, including conversation details, local files, repositories, knowledge, decisions, reference links. Only do extra research when it is needed to make the handoff accurate.
4. Separate the result into:
   - Plan
   - Decisions
   - Implementation
   - Reference links/context
   - Todo State

