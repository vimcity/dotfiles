import { agentLoop, } from "@mariozechner/pi-agent-core";
/**
 * Run a sub-agent loop to completion.
 *
 * Returns nothing useful directly — by design, results are collected by the
 * `tools` the caller passes (their `execute` accumulates into caller-owned
 * state). This keeps the runner generic across every background task type.
 */
export async function runSubAgent(args) {
    const { model, apiKey, headers, systemPrompt, userPrompt, tools, maxTokens, signal } = args;
    const text = userPrompt.trim();
    if (!text)
        return;
    const prompts = [
        {
            role: "user",
            content: [{ type: "text", text }],
            timestamp: Date.now(),
        },
    ];
    const context = {
        systemPrompt,
        messages: [],
        tools,
    };
    const reasoning = model.reasoning;
    const config = {
        model,
        apiKey,
        headers,
        maxTokens: maxTokens ?? 4096,
        convertToLlm: (msgs) => msgs,
        toolExecution: "sequential",
        ...(reasoning ? { reasoning: "high" } : {}),
    };
    const stream = agentLoop(prompts, context, config, signal);
    for await (const _event of stream) {
        // Drain events; tool `execute` callbacks collect results caller-side.
    }
    await stream.result();
}
