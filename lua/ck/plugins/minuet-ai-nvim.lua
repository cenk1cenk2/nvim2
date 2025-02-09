-- https://github.com/milanglacier/minuet-ai.nvim
local M = {}

local log = require("ck.log")

M.name = "milanglacier/minuet-ai.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.provider.completion ~= "copilot", {
    plugin = function()
      ---@type Plugin
      return {
        "milanglacier/minuet-ai.nvim",
        event = { "LspAttach", "BufReadPre", "BufNewFile", "FileType", "InsertEnter" },
        dependencies = {
          -- TODO: this seems promising revisit this project when it is completed
          {
            -- https://github.com/Davidyz/VectorCode
            "Davidyz/VectorCode",
            cond = nvim.lsp.ai.completion.vectorcode.enabled == true,
            build = { "pipx install vectorcode", "pipx upgrade vectorcode" },
          },
        },
      }
    end,
    setup = function()
      local provider = nvim.lsp.ai.provider.completion
      if nvim.lsp.ai.provider.completion == "ai.kilic.dev" then
        provider = "openai_fim_compatible"
      end

      return {
        notify = nvim.lsp.ai.debug and "debug" or "error",
        provider = provider,
        n_completions = nvim.lsp.ai.completion.number_of_completions,
        context_window = nvim.lsp.ai.completion.context_window,
        context_ratio = 0.75,
        throttle = 750,
        debounce = 250,
        request_timeout = 30,
        add_single_line_entry = false,
        after_cursor_filter_length = nvim.lsp.ai.completion.line_limit,
        provider_options = {
          openai_fim_compatible = {
            api_key = "AI_KILIC_DEV_API_KEY",
            name = "Ollama",
            end_point = "https://api.ai.kilic.dev/v1/completions",
            model = nvim.lsp.ai.model.completion,
            stream = true,
            request_timeout = 15,
            template = {
              -- https://platform.openai.com/docs/api-reference/completions/create
              -- https://api-docs.deepseek.com/api/create-completion
              prompt = function(prefix, suffix)
                local utils = require("minuet.utils")
                local language = utils.add_language_comment()
                local tab = utils.add_tab_comment()

                return "// current file that requires completion is as follows \n" .. language .. "\n" .. tab .. "\n" .. prefix
              end,
              suffix = function(_, suffix)
                local context = ""
                --- @module "vectorcode.cacher"
                local ok, cacher = pcall(require, "vectorcode.cacher")
                if ok then
                  local cache = cacher.query_from_cache()
                  for _, file in ipairs(cache) do
                    context = context .. "// reference file that is in the same project is as follows: " .. file.path .. "\n" .. file.document .. "\n\n"
                  end

                  if nvim.lsp.ai.debug then
                    log:info(
                      "Files selected for context: %s",
                      vim.tbl_map(function(value)
                        return value.path
                      end, cache)
                    )
                  end
                end

                return suffix .. "\n\n" .. context
              end,
            },
            optional = {
              max_tokens = 256,
              top_p = 0.95,
              top_k = 10,
            },
          },
          gemini = {
            model = "gemini-2.0-flash",
            stream = true,
            api_key = "GEMINI_API_KEY",
            optional = {},
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
            accept_line = "<M-o>",
            accept_n_lines = nil,
          },
          show_on_completion_menu = false,
        },
      }
    end,
    on_setup = function(c)
      ---@module "vectorcode"
      local ok, vectorcode = pcall(require, "vectorcode")
      if ok then
        vectorcode.setup({
          n_query = nvim.lsp.ai.completion.vectorcode.number_of_files,
        })
      end

      require("minuet").setup(c)
    end,
    autocmds = function()
      return {
        {
          event = { "LspAttach" },
          group = "__completion",
          callback = function(event)
            --- @module "vectorcode.cacher"
            local ok, cacher = pcall(require, "vectorcode.cacher")
            if not ok then
              return
            end

            cacher.async_check("config", function()
              cacher.register_buffer(event.buf, {
                notify = nvim.lsp.ai.debug,
                run_on_register = true,
                events = { "BufWritePost" },
                debounce = 15,
              })
            end, nil)
          end,
        },
      }
    end,
  })
end

return M
