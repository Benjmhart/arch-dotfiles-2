return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  -- "BufReadPre ~/BRAIN/**/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  keys = { { "<leader>os", ":ObsidianSearch<cr>", desc = "obsidian search" } },
  opts = {
    workspaces = {
      {
        name = "brain",
        path = "~/BRAIN",
      },
    },
    note_id_func = function(title)
      return title
    end,
  },
}
