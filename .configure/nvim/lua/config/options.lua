-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
-- disable relative numbers
vim.opt.relativenumber = false
-- set to follow markdown links
vim.g.vim_markdown_edit_url_in = "current"

-- command pallet autocomplete
vim.opt.wildmode = "longest,list,full"
vim.opt.wildmenu = true

-- turning off autoformat in hops it prevents the issue where {} cant be
-- split by a newline without stuff in it

vim.g.autoformat = false


