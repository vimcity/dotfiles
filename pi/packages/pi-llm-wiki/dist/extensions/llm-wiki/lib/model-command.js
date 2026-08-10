import { parseModelRef, persistTaskModel } from "./task-config.js";
/** Words that clear the override and revert to the session model. */
const CLEAR_WORDS = new Set(["session", "default", "reset", "clear", "none", "unset"]);
/** The status-bar key for the active-model label (so we can update it in place). */
export const MODEL_STATUS_KEY = "llm-wiki-model";
/**
 * Human-readable label for the active background task model. Shows the
 * configured `provider/id` when set, otherwise the session model (with its id
 * when known). Pure — safe to unit test and reuse for the status line.
 */
export function formatActiveModelLabel(config, sessionModelId) {
    if (config.taskModel)
        return `${config.taskModel.provider}/${config.taskModel.id}`;
    return sessionModelId ? `session model (${sessionModelId})` : "session model";
}
/** "provider/id" ref for a model. */
function modelRef(m) {
    return `${m.provider}/${m.id}`;
}
/**
 * Register the `/wiki-model` slash command. Lets the user view the active
 * background task model and choose another (or revert to the session model).
 * The choice is persisted to project settings and applied immediately.
 *
 *   /wiki-model                 → interactive picker (lists available models)
 *   /wiki-model provider/id     → set directly (scriptable / no UI needed)
 *   /wiki-model session|clear   → clear the override, use the session model
 */
export function registerWikiModelCommand(pi, runtime) {
    pi.registerCommand("wiki-model", {
        description: "View or set the model used for LLM Wiki background tasks (default: session model)",
        handler: async (args, ctx) => {
            runtime.ensureConfig(ctx.cwd);
            const sessionId = ctx.model?.id;
            const apply = (model) => {
                persistTaskModel(ctx.cwd, model);
                runtime.config = { ...runtime.config, taskModel: model };
                const label = formatActiveModelLabel(runtime.config, sessionId);
                ctx.ui.setStatus(MODEL_STATUS_KEY, `🧠 wiki model: ${label}`);
                ctx.ui.notify(`LLM Wiki: background tasks now use ${label}`, "info");
            };
            const trimmed = args.trim();
            // Explicit clear → session model.
            if (trimmed && CLEAR_WORDS.has(trimmed.toLowerCase())) {
                apply(undefined);
                return;
            }
            // Direct "provider/id" set (works without UI).
            if (trimmed) {
                const ref = parseModelRef(trimmed);
                if (!ref) {
                    ctx.ui.notify(`LLM Wiki: could not parse "${trimmed}". Use provider/id (e.g. anthropic/claude-haiku) or "session".`, "error");
                    return;
                }
                const found = ctx.modelRegistry.find(ref.provider, ref.id);
                if (!found) {
                    ctx.ui.notify(`LLM Wiki: model ${ref.provider}/${ref.id} is not in the registry (run /wiki-model with no argument to pick from available models).`, "error");
                    return;
                }
                apply({ provider: found.provider, id: found.id });
                return;
            }
            // No argument: interactive picker.
            const current = formatActiveModelLabel(runtime.config, sessionId);
            if (!ctx.hasUI) {
                ctx.ui.notify(`LLM Wiki: active background model is ${current}. Pass provider/id to change it (no interactive UI here).`, "info");
                return;
            }
            const available = ctx.modelRegistry.getAvailable() ?? [];
            const pool = available.length > 0 ? available : ctx.modelRegistry.getAll();
            const sessionOption = "↩ Use session model (clear override)";
            const options = [sessionOption, ...pool.map(modelRef)];
            const picked = await ctx.ui.select(`Wiki background model (current: ${current})`, options);
            if (picked === undefined)
                return; // cancelled
            if (picked === sessionOption) {
                apply(undefined);
                return;
            }
            const ref = parseModelRef(picked);
            if (ref)
                apply(ref);
        },
    });
}
