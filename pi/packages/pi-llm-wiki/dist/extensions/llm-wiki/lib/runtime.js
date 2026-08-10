import { TASK_DEFAULTS, loadTaskConfig, noticesEnabled } from "./task-config.js";
export class Runtime {
    config = { ...TASK_DEFAULTS };
    /**
     * Extension API handle, attached at registration. Used by `report()` to emit
     * visible completion messages for background actions (issue #77). Optional so
     * the Runtime stays unit-testable without a live `pi`.
     */
    pi;
    /** Labels of tasks currently in flight (single-flight guard per label). */
    inFlightLabels = new Set();
    /** All in-flight task promises, keyed for await-at-exit and dedupe. */
    inFlight = new Map();
    /** Whether we've already surfaced a model-resolution failure (avoid spam). */
    resolveFailureNotified = false;
    ensureConfig(cwd) {
        this.config = loadTaskConfig(cwd);
    }
    /** True if a task with this label is currently running. */
    isInFlight(label) {
        return this.inFlightLabels.has(label);
    }
    /** Number of background tasks currently running. */
    get pendingCount() {
        return this.inFlight.size;
    }
    /**
     * Resolve the model + auth for background work.
     *
     * Precedence (issue #69): per-call `override` → configured `taskModel` →
     * session model. Each configured layer is applied only when the model is
     * found in the registry; a missing layer warns (when UI is available) and
     * falls through to the next. Returns { ok: false } when nothing resolves or
     * no API key exists, so callers can fall back to the synchronous
     * main-agent path.
     */
    async resolveModel(ctx, override) {
        let model = ctx.model;
        // Configured taskModel layer (beats the session model).
        const configured = this.config.taskModel;
        if (configured) {
            const found = ctx.modelRegistry.find(configured.provider, configured.id);
            if (found) {
                model = found;
            }
            else if (ctx.hasUI && ctx.ui) {
                ctx.ui.notify(`LLM Wiki: configured task model ${configured.provider}/${configured.id} not found, using session model`, "warning");
            }
        }
        // Per-call override layer (beats both config and session).
        if (override) {
            const found = ctx.modelRegistry.find(override.provider, override.id);
            if (found) {
                model = found;
            }
            else if (ctx.hasUI && ctx.ui) {
                ctx.ui.notify(`LLM Wiki: model override ${override.provider}/${override.id} not found, using ${configured ? "configured/session" : "session"} model`, "warning");
            }
        }
        if (!model) {
            return {
                ok: false,
                reason: "no model available (session has no model and no taskModel configured)",
            };
        }
        const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
        if (!auth.ok || !auth.apiKey) {
            const provider = model.provider ?? "unknown";
            return { ok: false, reason: `no API key for provider "${provider}"` };
        }
        return { ok: true, model, apiKey: auth.apiKey, headers: auth.headers };
    }
    /**
     * Fire-and-forget a background task.
     *
     * The work runs in a detached promise so the caller (an agent hook/tool)
     * is never blocked. Errors are caught and surfaced via the UI (when
     * available) instead of crashing the agent. Single-flight per label: if a
     * task with the same label is already running, the new request is dropped
     * and the existing promise is returned.
     *
     * The returned promise resolves when the work completes; hold onto it (or
     * call awaitAll) to drain background work before compaction/exit.
     */
    launchTask(ctx, label, work) {
        const existing = this.inFlight.get(label);
        if (existing)
            return existing;
        // Capture ctx properties synchronously — after `await work()` the extension
        // ctx may be stale (e.g. after newSession/fork/switchSession/reload), and
        // accessing ctx.hasUI or ctx.ui on a stale proxy throws.
        const hasUI = ctx.hasUI;
        const ui = ctx.ui;
        this.inFlightLabels.add(label);
        // biome-ignore lint/style/useConst: referenced inside its own initializer (finally block)
        let promise;
        promise = (async () => {
            try {
                await work();
            }
            catch (error) {
                const msg = error instanceof Error ? error.message : String(error);
                if (hasUI && ui)
                    ui.notify(`LLM Wiki: ${label} failed: ${msg}`, "warning");
            }
            finally {
                this.inFlightLabels.delete(label);
                if (this.inFlight.get(label) === promise)
                    this.inFlight.delete(label);
            }
        })();
        this.inFlight.set(label, promise);
        return promise;
    }
    /**
     * Report a completed background action to the user (issue #77).
     *
     * Every mutating wiki action runs off the agent's critical path; this is how
     * the work becomes visible. Emits a `wiki-action-report` custom message,
     * shown in the UI when notices are enabled (the `notices` config, default
     * on) and otherwise injected silently. Delivered as `nextTurn` so it never
     * interrupts or triggers a turn. Never throws — reporting must not crash the
     * background task that called it.
     */
    report(summary, opts) {
        if (!this.pi || !summary)
            return;
        const display = opts?.display ?? noticesEnabled(this.config);
        try {
            this.pi.sendMessage({ customType: "wiki-action-report", content: summary, display }, { deliverAs: "nextTurn" });
        }
        catch {
            // Reporting is best-effort; a stale/torn-down session must not propagate.
        }
    }
    /**
     * Run a mutating action in the background and report its result (issue #77).
     *
     * Thin wrapper over `launchTask`: `work` performs the off-thread mutation and
     * returns a one-line human summary (or null to stay silent). On success the
     * summary is surfaced via `report()`. Single-flight, error-isolated, and
     * awaited-at-exit exactly like `launchTask`.
     */
    launchReported(ctx, label, work) {
        return this.launchTask(ctx, label, async () => {
            // Capture synchronously — after `await work()` the extension ctx may be
            // a stale proxy (newSession/fork/switchSession/reload) and accessing
            // ctx.hasUI or ctx.ui on it throws (see launchTask).
            const hasUI = ctx.hasUI;
            const ui = ctx.ui;
            const summary = await work();
            if (summary) {
                // Instant completion feedback: the nextTurn report below is queued for
                // the next user prompt, so without a toast a background task looks
                // stuck. Mirrors the failure notification in launchTask and the
                // success toast already used by wiki_ingest.
                if (hasUI && ui)
                    ui.notify(summary.split("\n")[0].replace(/\*\*/g, ""), "info");
                this.report(summary);
            }
        });
    }
    /**
     * Await all in-flight background tasks. Call at compaction / session exit so
     * background work is not lost. Never rejects — task errors are already
     * isolated inside launchTask.
     */
    async awaitAll() {
        while (this.inFlight.size > 0) {
            await Promise.allSettled([...this.inFlight.values()]);
        }
    }
}
/**
 * Register the shared background runtime and wire it into the extension
 * lifecycle: config is loaded lazily per turn, and in-flight tasks are drained
 * before compaction and on shutdown so background work is never lost.
 *
 * Returns the Runtime instance so concrete background workers (issues #65,
 * #66) can launch tasks on it.
 */
export function registerBackgroundRuntime(pi) {
    const runtime = new Runtime();
    // Attach the API so background tasks can emit visible completion reports
    // (issue #77). Done here (not in the constructor) to keep Runtime testable.
    runtime.pi = pi;
    pi.on("turn_start", (_event, ctx) => {
        runtime.ensureConfig(ctx.cwd);
    });
    // Drain in-flight background work before the session is compacted or shut
    // down, so nothing is lost mid-flight.
    pi.on("session_before_compact", async () => {
        await runtime.awaitAll();
    });
    pi.on("session_shutdown", async () => {
        await runtime.awaitAll();
    });
    return runtime;
}
