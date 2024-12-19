---@module "lspconfig"
---@type lspconfig.options.grammarly
return {
  cmd = { "mise", "x", "node@16", "--", "grammarly-languageserver", "--stdio" },
  filetypes = { "markdown", "plaintext", "text", "gitcommit" },
  single_file_support = true,
  settings = {
    grammarly = {
      startTextCheckInPausedState = false,
      config = {
        documentDialect = "american",
        documentDomain = "business",
        suggestions = {
          MissingSpaces = false,
          OxfordComma = true,
        },
      },
    },
  },
}
