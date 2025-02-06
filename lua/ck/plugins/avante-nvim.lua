-- https://github.com/yetone/avante.nvim
local M = {}

M.name = "yetone/avante.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "yetone/avante.nvim",
        build = "make",
        dependencies = {
          { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
          { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "AvanteInput",
        "Avante",
      })

      -- fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
      --   vim.list_extend(c.right, {
      --     {
      --       title = "Avante",
      --       ft = "Avante",
      --       size = {
      --         width = function()
      --           if vim.o.columns < 180 then
      --             return 0.5
      --           end
      --
      --           return 120
      --         end,
      --       },
      --     },
      --   })
      --
      --   return c
      -- end)
    end,
    setup = function(_, fn)
      local categories = fn.get_wk_categories()

      ---@type avante.Config
      return {
        debug = nvim.lsp.ai.debug,
        -- provider = "copilot",
        provider = nvim.lsp.ai.provider,
        vendors = {
          ["ai.kilic.dev"] = M.ai_kilic_dev,
        },
        windows = {
          wrap = true, -- similar to vim.o.wrap
          width = 50, -- default % based on available width
          sidebar_header = {
            rounded = false,
          },
          input = {
            prefix = nvim.ui.icons.misc.Robot .. " ",
            height = 20, -- Height of the input window in vertical layout
          },
        },
        behaviour = {
          auto_set_highlight_group = false,
          auto_set_keymaps = false,
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = fn.local_keystroke({ "c", "o" }),
            theirs = fn.local_keystroke({ "c", "t" }),
            all_theirs = fn.local_keystroke({ "a", "t" }),
            both = fn.local_keystroke({ "c", "b" }),
            cursor = fn.local_keystroke({ "c", "c" }),
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-k>",
            prev = "<M-j>",
            dismiss = "<C-h>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          sidebar = {
            apply_all = fn.local_keystroke({ "A" }),
            apply_cursor = fn.local_keystroke({ "a" }),
            switch_windows = "<C-n>",
            reverse_switch_windows = "<C-p>",
          },
          ask = fn.wk_keystroke({ categories.COPILOT, "c" }),
          edit = fn.wk_keystroke({ categories.COPILOT, "e" }),
          refresh = fn.wk_keystroke({ categories.COPILOT, "r" }),
          focus = fn.wk_keystroke({ categories.COPILOT, "f" }),
          toggle = {
            debug = fn.wk_keystroke({ categories.COPILOT, "A" }),
            hint = fn.wk_keystroke({ categories.COPILOT, "a" }),
          },
        },
      }
    end,
    on_setup = function(c)
      require("avante").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("avante.api").ask()
          end,
          desc = "toggle chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "e" }),
          function()
            require("avante.api").edit()
          end,
          desc = "edit [avante]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("avante.api").refresh()
          end,
          desc = "refresh [avante]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "Avante",
          "AvanteInput",
        }),
      }
    end,
  })
end

---@param opts AvantePromptOptions
function M.ollama_parse_messages(opts)
  local Config = require("avante.config")
  local Clipboard = require("avante.clipboard")

  local messages = {}

  local has_images = Config.behaviour.support_paste_from_clipboard and opts.image_paths and #opts.image_paths > 0

  -- Convert avante messages to ollama format

  for _, msg in ipairs(opts.messages) do
    local role = msg.role == "user" and "user" or "assistant"

    local content = msg.content

    -- Handle multimodal content if images are present

    if has_images and role == "user" then
      local message_content = {

        role = role,

        content = content,

        images = {},
      }

      for _, image_path in ipairs(opts.image_paths) do
        table.insert(message_content.images, "data:image/png;base64," .. Clipboard.get_base64_content(image_path))
      end

      table.insert(messages, message_content)
    else
      table.insert(messages, {

        role = role,

        content = content,
      })
    end
  end

  return messages
end

---@param data string
---@param handler_opts AvanteHandlerOptions
function M.ollama_parse_stream_data(data, handler_opts)
  local Utils = require("avante.utils")

  local ok, json_data = pcall(vim.json.decode, data)

  if not ok or not json_data then
    -- Add debug logging

    Utils.debug("Failed to parse JSON: " .. data)

    return
  end

  -- Add debug logging

  Utils.debug("Received data: " .. vim.inspect(json_data))

  if json_data.message and json_data.message.content then
    local content = json_data.message.content

    if content and content ~= "" then
      Utils.debug("Sending chunk: " .. content)

      handler_opts.on_chunk(content)
    end
  end

  if json_data.done then
    Utils.debug("Stream complete")

    handler_opts.on_stop({ reason = "complete" })

    return
  end
end

---@param provider AvanteProvider
---@param prompt_opts AvantePromptOptions
function M.ollama_parse_curl_args(provider, prompt_opts)
  local Utils = require("avante.utils")
  local P = require("avante.providers")

  local base, body_opts = P.parse_config(provider)

  if not base.model or base.model == "" then
    error("Ollama model must be specified in config")
  end

  if not base.endpoint then
    error("Ollama requires endpoint configuration")
  end

  return {
    url = Utils.url_join(base.endpoint, "/api/chat"),

    headers = {
      ["Content-Type"] = "application/json",
      ["Accept"] = "application/json",
      ["Authorization"] = "Bearer " .. os.getenv(provider.api_key_name),
    },

    body = vim.tbl_deep_extend("force", {
      model = base.model,
      messages = M.ollama_parse_messages(prompt_opts),
      stream = true,
      system = prompt_opts.system_prompt,
    }, body_opts),
  }
end

---@param result table
function M.ollama_on_error(result)
  local Utils = require("avante.utils")

  local error_msg = "Ollama API error"

  if result.body then
    local ok, body = pcall(vim.json.decode, result.body)

    if ok and body.error then
      error_msg = body.error
    end
  end

  Utils.error(error_msg, { title = "Ollama" })
end

-- Ollama API Documentation https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-completion
-- https://github.com/yetone/avante.nvim/issues/1149
M.ai_kilic_dev = {
  api_key_name = "AI_KILIC_DEV_API_KEY",
  -- endpoint = "https://api.ai.kilic.dev",
  model = nvim.lsp.ai.model.chat,
  stream = true, -- Optional
  -- options = {
  --   num_ctx = 32768, -- Optional
  --   temperature = 0, -- Optional see https://github.com/ollama/ollama/blob/main/docs/api.md for all options
  -- },
  -- parse_messages = M.ollama_parse_messages,
  -- parse_stream_data = M.ollama_parse_stream_data,
  -- parse_curl_args = M.ollama_parse_curl_args,
  -- on_error = M.ollama_on_error,
  -- for open ai compatible api
  endpoint = "https://api.ai.kilic.dev/v1",
  __inherited_from = "openai",
}

return M
