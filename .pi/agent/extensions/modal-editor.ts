/**
 * Modal Editor - vim-like modal editing example
 *
 * Usage: pi --extension ./examples/extensions/modal-editor.ts
 *
 * - Escape: insert → normal mode (in normal mode, aborts agent)
 * - i: normal → insert mode
 * - hjkl: navigation in normal mode
 * - w/b: word forward / back; e: end of word
 * - ctrl+c, ctrl+d, etc. work in both modes
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// Normal mode key mappings: key -> escape sequence (or null for mode switch)
const NORMAL_KEYS: Record<string, string | null> = {
	h: "\x1b[D", // left
	j: "\x1b[B", // down
	k: "\x1b[A", // up
	l: "\x1b[C", // right
	w: "\x1bf", // word right  (ESC-f → alt+right → cursorWordRight)
	W: "\x1bf", // WORD right  (same motion; pi has no distinct WORD move)
	b: "\x1bb", // word left   (ESC-b → alt+left  → cursorWordLeft)
	B: "\x1bb", // WORD left   (same motion)
	e: null, // end of word  (handled in handleInput)
	E: null, // end of WORD  (handled in handleInput)
	"0": "\x01", // line start
	$: "\x05", // line end
	x: "\x1b[3~", // delete char
	i: null, // insert mode
	a: null, // append (insert + right)
};

class ModalEditor extends CustomEditor {
	private mode: "normal" | "insert" = "insert";

	handleInput(data: string): void {
		// Escape toggles to normal mode, or passes through for app handling
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.mode = "normal";
			} else {
				super.handleInput(data); // abort agent, etc.
			}
			return;
		}

		// Insert mode: pass everything through
		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		// Normal mode: check mapped keys
		if (data in NORMAL_KEYS) {
			const seq = NORMAL_KEYS[data];
			if (data === "i") {
				this.mode = "insert";
			} else if (data === "a") {
				this.mode = "insert";
				super.handleInput("\x1b[C"); // move right first
			} else if (data === "e" || data === "E") {
				// End of word: forward one word, then back one char.
				// pi has no native "end of word" motion, so this approximates vim's `e`.
				super.handleInput("\x1bf");
				super.handleInput("\x1b[D");
			} else if (seq) {
				super.handleInput(seq);
			}
			return;
		}

		// Pass control sequences (ctrl+c, etc.) to super, ignore printable chars
		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		// Add a color-coded mode indicator to the bottom border:
		// insert = green (success), normal = yellow (warning).
		const theme = (this as any).theme;
		const rawLabel = this.mode === "normal" ? " NORMAL " : " INSERT ";
		const color = (s: string) =>
			this.mode === "normal"
				? theme?.fg?.("warning", s) ?? s
				: theme?.fg?.("success", s) ?? s;
		const label = color(rawLabel);
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= rawLabel.length) {
			lines[last] = truncateToWidth(lines[last]!, width - rawLabel.length, "") + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, kb) => new ModalEditor(tui, theme, kb));
	});
}
