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
        dependencies = {
          {
            -- https://github.com/Davidyz/VectorCode
            "Davidyz/VectorCode",
            version = "*", -- optional, depending on whether you're on nightly or release
            build = { "pipx install vectorcode", "pipx upgrade vectorcode" },
          },
        },
      }
    end,
    setup = function()
      local cacher = require("vectorcode.cacher")

      return {
        notify = nvim.lsp.ai.debug and "debug" or "error",
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 4000,
        context_ratio = 0.75,
        throttle = 750,
        debounce = 250,
        add_single_line_entry = true,
        provider_options = {
          openai_fim_compatible = {
            api_key = "AI_KILIC_DEV_API_KEY",
            name = "Ollama",
            end_point = "https://api.ai.kilic.dev/v1/completions",
            model = nvim.lsp.ai.model.completion,
            stream = true,
            request_timeout = 5,
            template = {
              prompt = function(pref, suff)
                local prompt_message = ""
                for _, file in ipairs(cacher.query_from_cache(0)) do
                  prompt_message = "<|file_sep|>" .. file.path .. "\n" .. file.document
                end
                return prompt_message .. "<|fim_prefix|>" .. pref .. "<|fim_suffix|>" .. suff .. "<|fim_middle|>"
              end,
              suffix = false,
              -- suffix = false,
              -- optional = {
              --   max_tokens = 256,
              --   top_p = 0.9,
              -- },
            },
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
    autocmds = function()
      return {
        {
          event = { "LspAttach" },
          group = "__completion",
          pattern = "*",
          callback = function(event)
            local cacher = require("vectorcode.cacher")

            cacher.async_check("config", function()
              cacher.register_buffer(event.buf, { notify = false, n_query = 10 })
            end, nil)
          end,
        },
      }
    end,
  })
end

return M
