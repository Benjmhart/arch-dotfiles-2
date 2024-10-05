-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- disable highlight
vim.keymap.set("n", "<C-H>", ":nohls<Enter>", { desc = "clear highlight" })
-- lazy write file
vim.keymap.set("n", "<leader>w", ":w<Enter>", { desc = "write buffer" })

-- toggle comments
-- this isn't working because it's owned by mini.comment plugin
-- remapped in plugins/mini-comment

-- neotree open with leader-n doesn't work here because it's owned by neotree
-- 't work here because it's owned by neotree
-- this is remapped in plugins/neotree

-- paste with ctrl-v in insert mode
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "paste from clipboard" })
