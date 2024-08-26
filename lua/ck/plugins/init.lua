local M = {}

local plugins = {
  "plenary-nvim",
  "lazy-nvim",
  "nvim-notify",
  "structlog-nvim",
  "mini-nvim-icons",
  -- core
  "which-key",
  "alpha-nvim",
  "bufferline-nvim",
  "mini-bufremove",
  "lualine-nvim",
  "telescope",
  "cmp",
  "treesitter",
  "neoconf-nvim",
  "nvim-lspconfig",
  "schemastore-nvim",
  "lazydev-nvim",
  "mason",
  "mason-nvim-dap",
  "toggleterm-nvim",
  "flatten-nvim",
  "nvim-window-picker",
  "neotree-nvim",
  "comment-nvim",
  "gitsigns-nvim",
  "nvim-autopairs",
  "possession-nvim",
  "stickybuf-nvim",
  "noice-nvim",
  "nui-nvim",
  "nvim-lint",
  "conform-nvim",
  -- extensions
  "spider-nvim",
  "dap",
  "statuscol-nvim",
  "flash-nvim",
  "vim-repeat",
  "neoscroll",
  "auto-hlsearch-nvim",
  "grug-far-nvim",
  "copilot-nvim",
  "copilotchat-nvim",
  "aerial-nvim",
  "rnvimr",
  -- "vim-visual-multi",
  "nvim-treesitter-textobjects",
  "nvim-treesitter-context",
  "tree-climber-nvim",
  "indent-tools-nvim",
  "rainbow-delimiters-nvim",
  "nvim-recorder",
  "windows-nvim",
  "telescope-undo-nvim",
  "nvim-ufo",
  "quicker-nvim",
  "lsp-trouble",
  "todo-comments",
  "indent-blankline",
  "octo",
  "diffview",
  "markview-nvim",
  "helpview-nvim",
  "github-preview-nvim",
  "neogen",
  "gitignore-nvim",
  "lspsaga-nvim",
  "nvim-dap-ui",
  "nvim-dap-virtual-text",
  "dressing",
  "nvim-hlslens",
  "nvim-scrollbar",
  "lsp-lines-nvim",
  "yanky-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "nvim-retrail",
  "nvim-surround",
  "ccc-nvim",
  "nvim-colorizer",
  "vim-illuminate",
  "neotest",
  "nvim-coverage",
  "telescope-github",
  "telescope-dap",
  "nvim-docs-view",
  "mini-nvim-ai",
  "mini-nvim-bracketed",
  "treesj",
  "winshift-nvim",
  "browse-nvim",
  "edgy-nvim",
  "typescript-tools-nvim",
  "schema-companion-nvim",
  "uuid-nvim",
  "hurl-nvim",
  "dadbod",
  "git-worktree-nvim",
  "netman-nvim",
  "gitlab-nvim",
  "symbol-usage-nvim",
  "obsidian-nvim",
  "iswap-nvim",
  "iedit-nvim",
  -- "viedit-nvim",
  "decipher-nvim",
  "arrow-nvim",
  "urlview-nvim",
}

function M.config()
  local log = require("ck.log")

  for _, path in ipairs(plugins) do
    local ok, m = pcall(require, ("ck.plugins.%s"):format(path))

    if not ok then
      log:error("Plugin configuration does not exists: %s", path)
    else
      local ok, err = pcall(m.config)

      if not ok then
        log:error("Plugin configuration can not be loaded: %s -> %s", path, err)
      end
    end
  end
end

return M
