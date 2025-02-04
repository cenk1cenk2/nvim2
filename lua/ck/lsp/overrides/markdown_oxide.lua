---@module "lspconfig"
---@type lspconfig.Config
return {
  condition = function()
    return vim.fs.root(0, { ".obsidian" }) ~= nil
  end,
}
