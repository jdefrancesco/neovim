return {
  -- Add Tree-sitter textobjects plugin
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Enable textobjects in treesitter config
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.textobjects = opts.textobjects or {}

      -- Selection textobjects: af/if/ac/ic
      opts.textobjects.select = vim.tbl_deep_extend("force", opts.textobjects.select or {}, {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      })
    end,
  },
}
