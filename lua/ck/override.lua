nvim.log.level = "info"

if is_headless() then
  nvim.log.level = "trace"
end

if vim.tbl_contains({ "emanet", "fanboy" }, vim.uv.os_gethostname()) then
  nvim.lsp.automatic_update = false
end

nvim.lsp.codelens.refresh = true

nvim.lsp.inlay_hints.enabled = true
nvim.lsp.inlay_hints.toggled = false
nvim.lsp.inlay_hints.mode = "eol"

nvim.lsp.copilot.debounce = 50
nvim.lsp.copilot.completion = { "inline" }
nvim.lsp.copilot.filetypes = {
  yaml = true,
  markdown = true,
  help = false,
  gitcommit = true,
  gitrebase = false,
  hgcommit = false,
  svn = false,
  cvs = false,
  ["."] = false,
}

nvim.lsp.ensure_installed = {
  ---- language servers
  "ansiblels",
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "eslint",
  "golangci_lint_ls",
  "gopls",
  "grammarly",
  "graphql",
  "helm_ls",
  "html",
  "jsonls",
  "lua_ls",
  "prismals",
  "prosemd_lsp",
  "pyright",
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "typos_lsp",
  "volar",
  "yamlls",

  ---- formatters/linters
  "beautysh",
  "black",
  "flake8",
  "goimports",
  "golangci-lint",
  "golines",
  "hadolint",
  "isort",
  "markdownlint",
  "prettierd",
  "proselint",
  "protolint",
  "shellcheck",
  "shellharden",
  "shfmt",
  "stylua",
  "terraform-ls",
  "tfsec",
  -- TODO: https://github.com/williamboman/mason-lspconfig.nvim/pull/485 After this merge request.
  -- "buf_ls",
  -- "djlint",
  -- "eslint_d",
  -- "mypy",
  -- "tflint",

  ---- debugers
  "chrome-debug-adapter",
  "delve",
  "node-debug2-adapter",

  -- external
  "checkmake",
  "markdown-toc",
  -- "md-printer",
  -- "rustywind",
}

nvim.lsp.skipped_servers = {
  "angularls",
  "csharp_ls",
  "cssmodules_ls",
  "denols",
  "ember",
  "eslintls",
  "glint",
  "jedi_language_server",
  "ltex",
  "phpactor",
  "pylsp",
  "quick_lint_js",
  "remark_ls",
  "rome",
  "sourcery",
  "spectral",
  "sqlls",
  "sqls",
  "stylelint_lsp",
  "tflint",
  "vuels",
  "zeta_note",
  "zk",
  -- "ansiblels",
  -- "emmet_ls",
  -- "eslint",
  -- "grammarly",
  -- "graphql",
  -- "tailwindcss",
  -- "volar",
}

nvim.lsp.skipped_filetypes = {}

require("ck.setup").setup_callback(require("ck.plugins.treesitter").name, function(c)
  return vim.tbl_extend("force", c, {
    indent = {
      -- TSBufDisable indent
      disable = { "yaml" },
    },
    ensure_installed = {
      "bash",
      "c",
      "c_sharp",
      "cmake",
      "comment",
      "cpp",
      "css",
      "dart",
      "diff",
      "dockerfile",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gotmpl",
      "gowork",
      "graphql",
      "html",
      "htmldjango",
      "http",
      "hurl",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "jsonnet",
      "latex",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "php",
      "prisma",
      "proto",
      "python",
      "regex",
      "ruby",
      "rust",
      "scss",
      "sql",
      "svelte",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "vue",
      "xml",
      "yaml",
    },
  })
end)
