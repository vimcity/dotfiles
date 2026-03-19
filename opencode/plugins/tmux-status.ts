import type { Plugin } from "@opencode-ai/plugin"

/**
 * Tmux Status Indicator Plugin
 *
 * Changes the Tmux window background color based on OpenCode status:
 * - Yellow: Permission requested (awaiting user approval)
 * - Green: Task completed (session idle)
 * - Blue: Default state (permission granted or window focused)
 *
 * Colors reset to blue when you switch to the Tmux window containing the session.
 */
export const TmuxStatusPlugin: Plugin = async ({ $ }) => {
  /**
   * Set the current Tmux window's status bar background color
   * Uses the currently active window if TMUX_PANE is set
   */
  const setWindowColor = async (color: string): Promise<void> => {
    try {
      // Check if we're running inside Tmux
      if (!process.env.TMUX_PANE) {
        return
      }

      // Extract window ID from TMUX_PANE (format: /path/to/tmux:session:window.pane)
      // We use "current" to target the active window
      await $`tmux set-window-option -t current status-style bg=${color}`
    } catch (error) {
      // Silently fail if tmux command doesn't work (e.g., running outside Tmux)
      // This prevents the plugin from breaking non-Tmux sessions
    }
  }

  return {
    /**
     * When OpenCode asks for permission (e.g., "Allow this action?")
     * Set window color to yellow to grab attention
     */
    "permission.asked": async () => {
      await setWindowColor("yellow")
    },

    /**
     * When user responds to permission prompt
     * Reset window color to blue (default state)
     */
    "permission.replied": async () => {
      await setWindowColor("blue")
    },

    /**
     * When OpenCode session becomes idle (task completed)
     * Set window color to green to indicate completion
     */
    "session.idle": async () => {
      await setWindowColor("green")
    },
  }
}
