-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Japanese IME (fcitx5 + mozc): leave insert mode with mozc still on and
-- normal-mode keys (hjkl, :, /) get swallowed by the IME. Switch it off on
-- InsertLeave, restore it on InsertEnter, so the toggle only ever applies
-- while actually inserting text.
if vim.fn.executable("fcitx5-remote") == 1 then
  local group = vim.api.nvim_create_augroup("fcitx5_ime", { clear = true })
  local ime_was_active = false

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.system({ "fcitx5-remote" }, { text = true }, function(res)
        -- fcitx5-remote prints 2 when the active IM is not the first
        -- (keyboard-us) entry, i.e. mozc is on.
        ime_was_active = vim.trim(res.stdout or "") == "2"
        if ime_was_active then
          vim.system({ "fcitx5-remote", "-c" })
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if ime_was_active then
        vim.system({ "fcitx5-remote", "-o" })
      end
    end,
  })
end
