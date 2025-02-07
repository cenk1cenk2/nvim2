-- https://github.com/milanglacier/minuet-ai.nvim
local M = {}

M.name = "milanglacier/minuet-ai.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.provider == "ai.kilic.dev", {
    plugin = function()
      ---@type Plugin
      return {
        "milanglacier/minuet-ai.nvim",
        event = { "LspAttach", "BufReadPre", "BufNewFile", "FileType", "InsertEnter" },
        dependencies = {
          -- TODO: this seems promising revisit this project when it is completed
          -- {
          --   -- https://github.com/Davidyz/VectorCode
          --   "Davidyz/VectorCode",
          --   build = { "pipx install vectorcode", "pipx upgrade vectorcode" },
          -- },
        },
      }
    end,
    setup = function()
      return {
        notify = nvim.lsp.ai.debug and "debug" or "error",
        provider = "openai_fim_compatible",
        n_completions = 3,
        context_window = 4096,
        context_ratio = 0.75,
        throttle = 750,
        debounce = 250,
        request_timeout = 30,
        add_single_line_entry = true,
        after_cursor_filter_length = 10,
        provider_options = {
          openai_fim_compatible = {
            api_key = "AI_KILIC_DEV_API_KEY",
            name = "Ollama",
            end_point = "https://api.ai.kilic.dev/v1/completions",
            model = nvim.lsp.ai.model.completion,
            stream = true,
            request_timeout = 15,
            template = {
              prompt = function(prefix, _)
                local utils = require("minuet.utils")
                local language = utils.add_language_comment()
                local tab = utils.add_tab_comment()

                -- local context = ""
                -- for _, file in ipairs(require("vectorcode.cacher").query_from_cache()) do
                --   context = context .. "// " .. file.path .. "\n" .. file.document .. "\n\n"
                -- end

                -- return language .. "\n" .. tab .. "\n" .. context .. prefix
                return language .. "\n" .. tab .. "\n" .. prefix
              end,
              suffix = function(_, suffix)
                return suffix
              end,
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
      -- require("vectorcode").setup({
      --   n_query = 1,
      -- })

      require("minuet").setup(c)
    end,
    -- autocmds = function()
    --   return {
    --     {
    --       event = { "LspAttach" },
    --       group = "__completion",
    --       callback = function(event)
    --         local cacher = require("vectorcode.cacher")
    --
    --         cacher.async_check("config", function()
    --           cacher.register_buffer(event.buf, {
    --             notify = nvim.lsp.ai.debug,
    --             n_query = 1,
    --             run_on_register = true,
    --             query_cb = require("vectorcode.utils").surrounding_lines_cb(-1),
    --             events = { "BufWritePost", "InsertEnter", "BufReadPost" },
    --           })
    --         end, nil)
    --       end,
    --     },
    --   }
    -- end,
  })
end

return M
