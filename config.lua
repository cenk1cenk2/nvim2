lvim.log.level = "info"

if is_headless() then
  lvim.log.level = "trace"
end

lvim.lsp.ensure_installed = {
  ---- language servers
  "json-lsp",
  "lua-language-server",
  "yaml-language-server",
  "typescript-language-server",
  "bash-language-server",
  "pyright",
  "graphql-language-service-cli",
  "grammarly-languageserver",
  "dockerfile-language-server",
  "vue-language-server",
  "gopls",
  "tailwindcss-language-server",
  "css-lsp",
  "html-lsp",
  "svelte-language-server",
  "rust-analyzer",
  "ansible-language-server",
  "emmet-ls",
  "golangci-lint-langserver",
  "prisma-language-server",
  "prosemd-lsp",
  "taplo",
  "docker-compose-language-service",
  "helm-ls",
  -- "efm",
  "eslint-lsp",
  ---- formatters/linters
  "stylua",
  "eslint_d",
  "markdownlint",
  "markdown-toc",
  "prettierd",
  -- "misspell",
  "shfmt",
  "black",
  "isort",
  -- "marksman",
  "flake8",
  "shellcheck",
  -- "mypy",
  -- "goimports",
  "golines",
  "goimports",
  "golangci-lint",
  "shellharden",
  "beautysh",
  "cspell",
  -- "checkmake",
  -- "revive",
  -- "rustfmt",
  "hadolint",
  "proselint",
  "bufls",
  "protolint",
  -- "tflint",
  "tfsec",
  "terraform-ls",
  -- "djlint",
  ---- debugers
  "delve",
  "node-debug2-adapter",
  "chrome-debug-adapter",
  -- external
  "markdown-toc",
  -- "md-printer",
  -- "rustywind",
}

lvim.lsp.automatic_configuration.skipped_filetypes = {}

lvim.lsp.automatic_configuration.skipped_servers = {
  "angularls",
  -- "ansiblels",
  "denols",
  "ember",
  "csharp_ls",
  "cssmodules_ls",
  -- "emmet_ls",
  -- "eslint",
  "eslintls",
  "glint",
  -- "grammarly",
  -- "graphql",
  "jedi_language_server",
  "ltex",
  "phpactor",
  "pylsp",
  "rome",
  "spectral",
  "sqlls",
  "sqls",
  "remark_ls",
  "stylelint_lsp",
  "sourcery",
  -- "tailwindcss",
  "quick_lint_js",
  "tflint",
  "vuels",
  -- "volar",
  "zk",
  "zeta_note",
}

require("utils.setup").fn.append_to_setup("treesitter", {
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
    "go",
    "gomod",
    "gowork",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "graphql",
    "html",
    "vimdoc",
    "java",
    "javascript",
    "make",
    "markdown",
    "markdown_inline",
    "jsdoc",
    "json",
    "jsonnet",
    "json5",
    "jsonc",
    "lua",
    "php",
    "python",
    "prisma",
    "proto",
    "regex",
    "ruby",
    "rust",
    "scss",
    "svelte",
    "sql",
    "tsx",
    "typescript",
    "terraform",
    "toml",
    "vim",
    "vue",
    "yaml",
    "gotmpl",
  },
})
