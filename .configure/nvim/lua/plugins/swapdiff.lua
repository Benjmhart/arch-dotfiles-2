-- swapdiff.nvim — replace Neovim's E325 "ATTENTION" prompt with a menu that can
-- DIFF the swap against the file on disk instead of forcing a blind choice between
-- them. See beast-arch task 25: ~/BRAIN is rewritten by obsidian-sync underneath a
-- permanently-open nvim, so swap conflicts here are routine rather than a crash
-- symptom, and picking the wrong side can lose another device's edits.
--
-- Trialled 2026-08-03. If it proves unhelpful, deleting this file is the whole
-- uninstall; nothing else references it.
return {
  "trippwill/swapdiff.nvim",
  lazy = false,
  priority = 100, -- load before anything that might open a file at startup
  opts = {
    prompt_config = {
      style = "Interactive", -- Interactive | Notify | None
      once = false,
    },
    log_level = vim.log.levels.WARN,
    notify_level = vim.log.levels.WARN,
  },
  -- Upstream leaves a debug `print()` in setup (lua/swapdiff/init.lua:197), so every
  -- nvim start dumps "SwapDiff Handler: Setting up with options: {...}" into the
  -- message area. It is a bare print(), not vim.notify, so log_level/notify_level do
  -- not suppress it -- verified 2026-08-03 by raising both and seeing it anyway.
  -- Silence it for the duration of the setup call only. Delete this wrapper (and go
  -- back to plain `opts`) if upstream removes the print.
  config = function(_, opts)
    local real_print = print
    print = function() end
    local ok, err = pcall(require("swapdiff").setup, opts)
    print = real_print
    if not ok then
      error(err)
    end
  end,
}
