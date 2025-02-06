-- https://github.com/milanglacier/minuet-ai.nvim
local M = {}

M.name = "milanglacier/minuet-ai.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.provider == "ai.kilic.dev", {
    plugin = function()
      ---@type Plugin
      return {
        "milanglacier/minuet-ai.nvim",
        event = { "BufReadPre", "BufNewFile", "FileType", "InsertEnter" },
      }
    end,
    setup = function()
      return {
        notify = nvim.lsp.ai.debug and "debug" or "warn",
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 16000,
        context_ratio = 0.75,
        throttle = 750,
        debounce = 250,
        provider_options = {
          openai_fim_compatible = {
            api_key = "AI_KILIC_DEV_API_KEY",
            name = "Ollama",
            end_point = "https://api.ai.kilic.dev/v1/completions",
            model = nvim.lsp.ai.model.completion,
            stream = false,
            request_timeout = 5,
            -- optional = {
            --   max_tokens = 256,
            --   top_p = 0.9,
            -- },
          },
        },
        blink = {
          enable_auto_complete = false,
        },
        virtualtext = {
          auto_trigger_ft = nvim.lsp.ai.filetypes.enabled,
          auto_trigger_ignore_ft = nvim.lsp.ai.filetypes.ignored,
          keymap = {
            next = "<M-j>",
            prev = "<M-k>",
            dismiss = "<M-h>",
            accept = "<M-l>",
            accept_line = nil,
            accept_n_lines = nil,
          },
          show_on_completion_menu = false,
        },
      }
    end,
    on_setup = function(c)
      require("minuet").setup(c)
    end,
  })
end

return M
