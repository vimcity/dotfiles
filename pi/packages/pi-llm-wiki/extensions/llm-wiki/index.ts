import { existsSync, readFileSync } from "node:fs";
import { basename, join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { bootstrapVault } from "./lib/bootstrap.js";
import { installGuardrails } from "./lib/guardrails.js";
import {
	buildAgentStartInjection,
	normalizeSystemPrompt,
} from "./lib/inject.js";
import { registerWikiModelCommand } from "./lib/model-command.js";
import {
	buildSessionNotice,
	createReminderState,
	registerObservationReminder,
	registerWikiObserve,
} from "./lib/observation.js";
import {
	formatRecallContext,
	registerWikiRecall,
	searchWikiHybrid,
	shouldUseLinksFirst,
	vaultPageCount,
} from "./lib/recall.js";
import { registerWikiRetro } from "./lib/retro.js";
import { registerBackgroundRuntime } from "./lib/runtime.js";
import {
	loadTaskConfig,
	noticesEnabled,
	trajectoriesEnabled,
} from "./lib/task-config.js";
import {
	registerWikiBootstrap,
	registerWikiCaptureSource,
	registerWikiEnsurePage,
	registerWikiIngest,
	registerWikiLint,
	registerWikiLogEvent,
	registerWikiRebuildMeta,
	registerWikiReindexEmbeddings,
	registerWikiSearch,
	registerWikiStatus,
	registerWikiWatch,
} from "./lib/tools.js";
import { registerWikiTrajectoriesCommand } from "./lib/trajectories-command.js";
import {
	registerWikiCaptureTrajectory,
	registerWikiDistillSkills,
	registerWikiRecallSkill,
} from "./lib/trajectory.js";
import { migrateDoubledPersonalVault, resolveVaultPaths } from "./lib/utils.js";
import { inspectWritableVault } from "./lib/vault-format.js";
import { applySessionStartStatus } from "./lib/visible-status.js";

/**
 * @zosmaai/pi-llm-wiki — LLM Wiki extension for Pi
 *
 * Registers 13 custom tools and installs guardrails (+3 agent-trajectory tools
 * when `llm-wiki.trajectories` is enabled — opt-in, off by default, issue #80):
 * - wiki_recall (layered: personal + project vaults)
 * - wiki_retro (lightweight: single markdown file)
 * - wiki_capture_source (full 4-layer pipeline)
 *
 * Guardrails:
 * - Blocks direct edits to raw/** and meta/**
 * - Auto-rebuilds metadata after wiki/** edits
 *
 * Layered recall:
 * - before_agent_start hook searches personal + project vaults
 * - Injects matching knowledge as system context with vault labels
 * - wiki_recall tool available for explicit task-specific searches
 */

export default function (pi: ExtensionAPI) {
	// Background-task lane (issues #64, #65): shared runtime for off-thread LLM
	// work. Created first so tools (e.g. wiki_ingest) can dispatch to it.
	const runtime = registerBackgroundRuntime(pi);

	registerWikiBootstrap(pi);
	registerWikiCaptureSource(pi, runtime);
	registerWikiIngest(pi, runtime);
	registerWikiEnsurePage(pi, runtime);
	registerWikiSearch(pi);
	registerWikiLint(pi, runtime);
	registerWikiStatus(pi);
	registerWikiRebuildMeta(pi, runtime);
	registerWikiReindexEmbeddings(pi, runtime);
	registerWikiLogEvent(pi);
	registerWikiWatch(pi);
	registerWikiRecall(pi, runtime);
	registerWikiRetro(pi, runtime);
	// Agent working-memory (issue #80): capture what the agent *did* (its
	// tool-call trajectory), distill it into reusable skills, and recall past
	// skills/cases. OPT-IN, default OFF — registered ONLY when enabled so the 3
	// tools cost nothing in the system prompt for users who don't opt in.
	//
	// Gate on loadTaskConfig(process.cwd()) at factory time, NOT runtime.config:
	// runtime.config is empty ({}) until ensureConfig runs in a later hook, so a
	// runtime.config gate here would read as permanently off. Toggling the flag
	// via /wiki-trajectories reloads the extension, re-running this gate.
	const trajectoriesOn = trajectoriesEnabled(loadTaskConfig(process.cwd()));
	if (trajectoriesOn) {
		registerWikiCaptureTrajectory(pi);
		registerWikiDistillSkills(pi);
		registerWikiRecallSkill(pi);
	}
	// Activation surface for the above (always available so users can turn it on).
	registerWikiTrajectoriesCommand(pi);
	// Model selection surface (issue #69): /wiki-model command to view/set the
	// background task model. The taskModel config field + resolveModel already
	// exist; this exposes them to the user (default stays the session model).
	registerWikiModelCommand(pi, runtime);
	const reminderState = createReminderState();
	registerWikiObserve(pi, runtime, reminderState);
	// Visible observe/retro reminder by default (issue #77); silenced when the
	// user sets `llm-wiki.notices: false`. Resolver reads the live config so the
	// setting takes effect without a restart.
	registerObservationReminder(pi, reminderState, {
		display: () => noticesEnabled(runtime.config),
	});

	installGuardrails(pi, runtime);

	// Track if wiki was just auto-created and needs topic inference
	let needsTopicInference = false;

	pi.on("session_start", async (_event, ctx) => {
		// One-shot recovery for vaults created with the broken personal-root
		// (~/.llm-wiki/.llm-wiki/… doubled layout). Runs on every session start
		// because it is a cheap existence-check no-op when the layout is correct.
		try {
			const migration = migrateDoubledPersonalVault();
			if (migration && migration.moved.length > 0) {
				// INTENTIONALLY NOT gated by `noticesEnabled` (issues #77, #84): this is
				// a one-shot data-integrity recovery signal, not chat-noise. If the
				// user has a broken doubled-dotdir layout we want them to see that it
				// was fixed, even in quiet mode.
				ctx.ui.setStatus(
					"llm-wiki",
					`🧠 Personal wiki layout fixed: flattened ${migration.moved.length} entries out of ${migration.from} (see CHANGELOG)`,
				);
			}
		} catch (err) {
			// Never let migration crash session start.
			console.warn(
				`[llm-wiki] doubled-dotdir migration skipped: ${(err as Error).message}`,
			);
		}

		const paths = resolveVaultPaths(process.cwd());
		if (!existsSync(join(paths.dotWiki, "config.json"))) {
			// Silently create the wiki vault — no UI prompts. Topic/mode will be
			// inferred from the user's first prompt via before_agent_start.
			const result = bootstrapVault(paths, {
				topic: "pending",
				mode: "personal",
			});
			if (!result.ok || !result.projection.ok) {
				ctx.ui.setStatus(
					"llm-wiki",
					`🧠 Wiki setup blocked: ${
						result.ok
							? result.projection.diagnostics[0].message
							: result.diagnostics[0].message
					}`,
				);
				return;
			}

			needsTopicInference = true;
			// INTENTIONALLY NOT gated by `noticesEnabled` (issues #77, #84): one-shot
			// first-run setup signal. The user needs to know the wiki was just
			// auto-created, regardless of quiet mode.
			ctx.ui.setStatus(
				"llm-wiki",
				"🧠 Wiki created (inferring topic from first prompt…)",
			);
			return;
		}

		const writable = inspectWritableVault(paths);
		if (!writable.ok) {
			ctx.ui.setStatus(
				"llm-wiki",
				`🧠 Wiki setup blocked: ${writable.diagnostics[0].message}`,
			);
			return;
		}

		// Surface the "wiki active" badge and the active background task model
		// (issue #69), both gated by `llm-wiki.notices` (issue #77, regression
		// fixed in #83, helper extracted in #84). `ensureConfig` MUST run first so
		// the gate sees the loaded project settings.
		runtime.ensureConfig(process.cwd());
		applySessionStartStatus({
			ui: ctx.ui,
			runtime,
			trajectoriesOn,
			sessionModelId: (ctx.model as { id?: string })?.id,
		});

		// One-time, user-visible session notice announcing the full wiki loop
		// (issue #77). Without this, recall/observe/retro are invisible — they
		// live only in the system prompt. Queued for the first prompt so it never
		// interrupts; silenced when `llm-wiki.notices: false`.
		if (noticesEnabled(runtime.config)) {
			pi.sendMessage(
				{
					customType: "wiki-session-notice",
					content: buildSessionNotice(),
					display: true,
				},
				{ deliverAs: "nextTurn" },
			);
		}
	});

	// ─── Stable system prompt footer + topic inference ──
	//
	// Returns systemPrompt (base + <wiki_status> footer) EVERY turn
	// with the SAME value, so the `instructions` field in the API body
	// stays byte-identical and the provider cache stays warm. The footer
	// nudges the model to use wiki_recall when relevant.
	//
	// Auto-injected recall context is NOT included — it changed the
	// messages array every turn and busted the cache. Use wiki_recall
	// explicitly instead.
	pi.on("before_agent_start", async (event, ctx) => {
		const paths = resolveVaultPaths(process.cwd());
		if (!existsSync(join(paths.dotWiki, "config.json"))) {
			return;
		}

		const prompt = event.prompt || "";
		let dynamicContext = "";

		// Topic inference on first turn after auto-creation
		if (needsTopicInference && prompt.trim()) {
			needsTopicInference = false;

			const cwd = process.cwd();
			const dirName = basename(cwd);
			let projectHints = `Project directory: "${dirName}" (path: ${cwd})`;

			try {
				const pkgPath = join(cwd, "package.json");
				if (existsSync(pkgPath)) {
					const pkg = JSON.parse(readFileSync(pkgPath, "utf-8"));
					projectHints += `\nPackage: ${pkg.name || "unknown"} v${pkg.version || "?"}`;
					if (pkg.description)
						projectHints += `\nDescription: ${pkg.description}`;
				}
			} catch {
				// ignore
			}

			dynamicContext += `

## Wiki Setup Required
The LLM Wiki was just auto-created but needs its topic and mode configured. Before responding to the user, analyze their prompt and this project's context to infer:
- **topic**: What is this wiki about? (e.g. "React app", "personal notes", "startup finances")
- **mode**: "personal" or "company" based on whether this looks like work or personal use

Project context hints:
${projectHints}

Then call wiki_bootstrap with the inferred topic and mode to finalize the setup. This is a one-time step.`;
		}

		// Build the stable system prompt footer + any dynamic message
		const priorSystemPrompt = normalizeSystemPrompt(event.systemPrompt);
		const { systemPrompt, message } = buildAgentStartInjection(priorSystemPrompt, [dynamicContext]);

		// Always return systemPrompt (base + <wiki_status> footer) so the
		// `instructions` field is STABLE every turn. The runner always passes
		// the base prompt (without footer), so appendWikiStatus always looks
		// like a "change" — but the OUTPUT string is the same every turn.
		// Writing the same value to _systemPromptOverride keeps the API body
		// byte-identical, and the provider cache stays warm.
		return {
			systemPrompt,
			...(message ? { message } : {}),
		};
	});}
