-- bootstrap lazy.nvim, LazyVim and your plugins
vim.cmd [[set runtimepath^=/home/ben/.config/nvim ]]
vim.cmd [[set runtimepath^=/home/ben/.config/nvim/lua ]]
require("config.lazy")
