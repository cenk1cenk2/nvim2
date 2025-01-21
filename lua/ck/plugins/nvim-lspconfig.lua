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
        -- https://github.com/folke/neoconf.nvim/issues/104
        commit = "46de45200afab642a134cf4e26f8f495ab7a49dd",
        init = false,
        config = function()
          require("ck.lsp").setup()
        end,
      }
    end,
  })
end

return M
