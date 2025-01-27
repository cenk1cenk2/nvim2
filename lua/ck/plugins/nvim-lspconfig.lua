-- https://github.com/neovim/nvim-lspconfig
local M = {}

M.name = "neovim/nvim-lspconfig"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
        -- TODO: https://github.com/neovim/nvim-lspconfig/commit/1f941b3668151963fca3e1230922c433ea4b7b64 causes problems with the current version of the plugins
        commit = "637293ce23c6a965d2f11dfbf92f604bb1978052",
        init = false,
        config = function()
          require("ck.lsp").setup()
        end,
      }
    end,
  })
end

return M
