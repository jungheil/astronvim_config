return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
      "c",
      "cmake",
      "cpp",
      "css",
      "cuda",
      "dockerfile",
      "gitcommit",
      "gitignore",
      "go",
      "html",
      "java",
      "javascript",
      "json",
      "jsonc",
      "julia",
      "latex",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "matlab",
      "ninja",
      "python",
      "regex",
      "rust",
      "toml",
      "yaml",
    })
  end,
}