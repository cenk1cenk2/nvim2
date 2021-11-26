lvim.log.level = "debug"

lvim.lsp.ensure_installed = {
  "jsonls",
  "sumneko_lua",
  "vimls",
  "yamlls",
  "tsserver",
  "bashls",
  "pyright",
  "graphql",
  "dockerls",
  "vuels",
  "stylelint_lsp",
  "gopls",
  "tailwindcss",
  "svelte",
  -- "angularls",
  "rust_analyzer",
  -- "eslint",
  -- "ansiblels",
  -- managed by extensions
  "stylua",
  "eslint_d",
  "markdownlint",
  "prettierd",
  "misspell",
  "markdown_toc",
  "shfmt",
  "black",
  "isort",
  "flake8",
  "mypy",
  "goimports",
  "golines",
  "rustywind",
  "rustfmt",
  "hadolint",
  "proselint",
}

lvim.lsp.override = {
  "angularls",
  "ansiblels",
  "denols",
  "ember",
  -- "emmet_ls",
  "eslint",
  "eslintls",
  -- "graphql",
  "jedi_language_server",
  "ltex",
  "phpactor",
  "pylsp",
  "rome",
  "sqlls",
  "sqls",
  "stylelint_lsp",
  -- "tailwindcss",
  "tflint",
  "volar",
}

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "cmake",
  "comment",
  "cpp",
  "css",
  "dart",
  "dockerfile",
  "go",
  "graphql",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "julia",
  "lua",
  "php",
  "python",
  "regex",
  "ruby",
  "rust",
  "scss",
  "svelte",
  "tsx",
  "typescript",
  "vue",
  "yaml",
}

lvim.autocommands.custom_groups = {
  TerminalOpen = { "TermOpen", "*", "nnoremap <buffer><LeftRelease> <LeftRelease>i" },
  ReloadLaunchJsonDebug = { "BufWritePost", "launch.json", "lua require('dap.ext.vscode').load_launchjs()" },
}
