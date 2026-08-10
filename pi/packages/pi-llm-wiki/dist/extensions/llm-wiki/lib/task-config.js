import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { getAgentDir } from "@mariozechner/pi-coding-agent";
export const TASK_DEFAULTS = {};
/**
 * Resolve whether user-facing wiki notices are enabled (issue #77). Defaults
 * to `true`; only an explicit `notices: false` disables them.
 */
export function noticesEnabled(config) {
    return config?.notices !== false;
}
/**
 * Resolve whether agent-trajectory working-memory is enabled (issue #80).
 * INVERSE polarity of `noticesEnabled`: defaults to `false`; only an explicit
 * `trajectories: true` turns it on.
 */
export function trajectoriesEnabled(config) {
    return config?.trajectories === true;
}
const SETTINGS_KEY = "llm-wiki";
function readModelSpec(value) {
    if (!value || typeof value !== "object")
        return undefined;
    const v = value;
    if (typeof v.provider === "string" && typeof v.id === "string" && v.provider && v.id) {
        return { provider: v.provider, id: v.id };
    }
    return undefined;
}
function readNamespacedConfig(path) {
    try {
        const raw = readSettingsObject(path);
        const nested = raw[SETTINGS_KEY];
        if (!nested || typeof nested !== "object")
            return {};
        const section = nested;
        const out = {};
        const taskModel = readModelSpec(section.taskModel);
        if (taskModel)
            out.taskModel = taskModel;
        for (const key of [
            "embeddingProvider",
            "embeddingModel",
            "embeddingBaseUrl",
            "embeddingApiKey",
            "embeddingApiKeyEnv",
        ]) {
            const value = section[key];
            if (typeof value === "string" && value.trim())
                out[key] = value.trim();
        }
        const weight = section.semanticWeight;
        if (typeof weight === "number" && Number.isFinite(weight)) {
            out.semanticWeight = Math.min(1, Math.max(0, weight));
        }
        const threshold = section.recallLinksThreshold;
        if (typeof threshold === "number" && Number.isFinite(threshold)) {
            out.recallLinksThreshold = Math.max(0, Math.floor(threshold));
        }
        const inlineMax = section.recallSkillInlineMax;
        if (typeof inlineMax === "number" && Number.isFinite(inlineMax)) {
            out.recallSkillInlineMax = Math.max(0, Math.floor(inlineMax));
        }
        if (typeof section.notices === "boolean") {
            out.notices = section.notices;
        }
        if (typeof section.trajectories === "boolean") {
            out.trajectories = section.trajectories;
        }
        const lang = section.synthesisLanguage;
        if (typeof lang === "string" && lang.trim()) {
            const canonical = validateSynthesisLanguage(lang.trim());
            if (canonical)
                out.synthesisLanguage = canonical;
        }
        return out;
    }
    catch {
        return {};
    }
}
/**
 * Parse a `"provider/id"` model reference (issue #69). Splits on the FIRST
 * slash so model ids that themselves contain slashes (e.g.
 * `openrouter/meta/llama-3`) are preserved. Returns `undefined` for empty,
 * slashless, or partial (`provider/` / `/id`) refs so callers can reject bad
 * input. Whitespace is trimmed.
 */
export function parseModelRef(ref) {
    const trimmed = ref.trim();
    const slash = trimmed.indexOf("/");
    if (slash <= 0)
        return undefined;
    const provider = trimmed.slice(0, slash).trim();
    const id = trimmed.slice(slash + 1).trim();
    if (!provider || !id)
        return undefined;
    return { provider, id };
}
/**
 * Validate and canonicalize a BCP 47 language tag for synthesisLanguage (issue #124).
 * Returns the canonical tag, or undefined if invalid or suspicious.
 * Uses Intl.getCanonicalLocales for validation; rejects tags containing
 * newlines, quotes, or other prompt-injection candidates.
 */
export function validateSynthesisLanguage(tag) {
    // Reject obvious injection attempts: newlines, quotes, braces, angle brackets
    if (/\n|\r|"|'|<|>|{|}/.test(tag))
        return undefined;
    // Reject if it looks like an instruction (contains "write", "ignore", "translate", etc.)
    const lower = tag.toLowerCase();
    if (/\b(write|ignore|translate|system|prompt|instruction)\b/.test(lower))
        return undefined;
    // Basic BCP 47 pattern: language[-script][-region][-variant]*
    // Must start with 2-3 letter language code
    if (!/^[a-z]{2,3}(?:-[A-Za-z]{1,8})*$/.test(tag))
        return undefined;
    const canonical = Intl.getCanonicalLocales(tag);
    if (canonical.length === 0)
        return undefined;
    return canonical[0];
}
/**
 * Read a settings JSON file as a plain object, or `{}` when it is absent or
 * corrupt. Reads directly (no `existsSync` pre-check) so there is no
 * check-then-use race: a missing file throws ENOENT, which the catch treats
 * the same as an empty file.
 */
function readSettingsObject(path) {
    try {
        const parsed = JSON.parse(readFileSync(path, "utf-8"));
        if (parsed && typeof parsed === "object")
            return parsed;
    }
    catch {
        // Missing or corrupt settings file: start from an empty object.
    }
    return {};
}
/**
 * Persist (or clear) the wiki background `taskModel` in the PROJECT settings
 * file `<cwd>/.pi/settings.json` under the namespaced `llm-wiki` key (issue
 * #69). Project settings win over global in `loadTaskConfig`, so this takes
 * effect immediately on the next config load. Other top-level keys and other
 * `llm-wiki` settings are preserved; passing `undefined` removes the key
 * (reverting to the session model).
 */
export function persistTaskModel(cwd, model) {
    const settingsPath = join(cwd, ".pi", "settings.json");
    const raw = readSettingsObject(settingsPath);
    const existing = raw[SETTINGS_KEY];
    const section = existing && typeof existing === "object" ? { ...existing } : {};
    if (model) {
        section.taskModel = { provider: model.provider, id: model.id };
    }
    else {
        // biome-ignore lint/performance/noDelete: one-off settings rewrite, not a hot path; removing the key (vs setting undefined) keeps the JSON clean
        delete section.taskModel;
    }
    raw[SETTINGS_KEY] = section;
    mkdirSync(dirname(settingsPath), { recursive: true });
    writeFileSync(settingsPath, `${JSON.stringify(raw, null, 2)}\n`, "utf-8");
}
/**
 * Persist the agent-trajectory flag in the PROJECT settings file
 * `<cwd>/.pi/settings.json` under the namespaced `llm-wiki` key (issue #80).
 * Mirrors `persistTaskModel`: project settings win in `loadTaskConfig`, other
 * keys are preserved. `true` writes `trajectories: true`; `false` removes the
 * key (reverting to the default-off behavior).
 */
export function persistTrajectoriesEnabled(cwd, enabled) {
    const settingsPath = join(cwd, ".pi", "settings.json");
    const raw = readSettingsObject(settingsPath);
    const existing = raw[SETTINGS_KEY];
    const section = existing && typeof existing === "object" ? { ...existing } : {};
    if (enabled) {
        section.trajectories = true;
    }
    else {
        // biome-ignore lint/performance/noDelete: one-off settings rewrite, not a hot path; removing the key keeps the JSON clean (default is off)
        delete section.trajectories;
    }
    raw[SETTINGS_KEY] = section;
    mkdirSync(dirname(settingsPath), { recursive: true });
    writeFileSync(settingsPath, `${JSON.stringify(raw, null, 2)}\n`, "utf-8");
}
export function loadTaskConfig(cwd) {
    let globalPath;
    try {
        globalPath = join(getAgentDir(), "settings.json");
    }
    catch {
        globalPath = "";
    }
    const projectPath = join(cwd, ".pi", "settings.json");
    return {
        ...TASK_DEFAULTS,
        ...(globalPath ? readNamespacedConfig(globalPath) : {}),
        ...readNamespacedConfig(projectPath),
    };
}
