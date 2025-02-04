---@module "lspconfig"
---@type lspconfig.Config
return {
  settings = {
    settings = {
      evenBetterToml = {
        schema = {
          catalogs = { "https://taplo.tamasfe.dev/schema_index.json" },
        },
      },
    },
  },
}
