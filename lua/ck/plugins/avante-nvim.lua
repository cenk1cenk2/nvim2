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
        provider = nvim.lsp.ai.provider.chat,
        gemini = {
          model = "gemini-2.0-flash",
        },
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
          enable_token_counting = true,
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = fn.local_keystroke({ "c", "o" }),
            theirs = fn.local_keystroke({ "c", "t" }),
            all_theirs = fn.local_keystroke({ "a", "t" }),
            both = fn.local_keystroke({ "c", "b" }),
            cursor = fn.local_keystroke({ "c", "c" }),
            next = "]c",
            prev = "[c",
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

local role_map = {
  user = "user",
  assistant = "assistant",
  system = "system",
  tool = "tool",
}

---@param opts AvantePromptOptions
local parse_messages = function(self, opts)
  local messages = {}
  local has_images = opts.image_paths and #opts.image_paths > 0
  -- Ensure opts.messages is always a table
  local msg_list = opts.messages or {}
  -- Convert Avante messages to Ollama format
  for _, msg in ipairs(msg_list) do
    local role = role_map[msg.role] or "assistant"
    local content = msg.content or "" -- Default content to empty string
    -- Handle multimodal content if images are present
    -- *Experimental* not tested
    if has_images and role == "user" then
      local message_content = {
        role = role,
        content = content,
        images = {},
      }
      for _, image_path in ipairs(opts.image_paths) do
        local base64_content = vim.fn.system(string.format("base64 -w 0 %s", image_path)):gsub("\n", "")
        table.insert(message_content.images, "data:image/png;base64," .. base64_content)
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

local function parse_curl_args(self, code_opts)
  -- Create the messages array starting with the system message
  local messages = {
    { role = "system", content = code_opts.system_prompt },
  }
  -- Extend messages with the parsed conversation messages
  vim.list_extend(messages, self:parse_messages(code_opts))
  -- Construct options separately for clarity
  local options = {
    num_ctx = (self.options and self.options.num_ctx) or 4096,
    temperature = code_opts.temperature or (self.options and self.options.temperature) or 0,
  }
  -- Check if tools table is empty
  local tools = (code_opts.tools and next(code_opts.tools)) and code_opts.tools or nil
  -- Return the final request table
  return {
    url = self.endpoint .. "/api/chat",
    headers = {
      ["Content-Type"] = "application/json",
      ["Accept"] = "application/json",
      ["Authorization"] = "Bearer " .. os.getenv(self.api_key_name),
    },
    body = {
      model = self.model,
      messages = messages,
      options = options,
      -- tools = tools, -- Optional tool support
      stream = true, -- Keep streaming enabled
    },
  }
end

local function parse_stream_data(data, handler_opts)
  local json_data = vim.fn.json_decode(data)
  if json_data then
    if json_data.done then
      handler_opts.on_stop({ reason = json_data.done_reason or "stop" })
      return
    end
    if json_data.message then
      local content = json_data.message.content
      if content and content ~= "" then
        handler_opts.on_chunk(content)
      end
    end
    -- Handle tool calls if present
    if json_data.tool_calls then
      for _, tool in ipairs(json_data.tool_calls) do
        handler_opts.on_tool(tool)
      end
    end
  end
end

---@param result table
local function on_error(result)
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
  endpoint = "https://api.ai.kilic.dev",
  parse_messages = parse_messages,
  parse_stream_data = parse_stream_data,
  parse_curl_args = parse_curl_args,
  on_error = on_error,
  model = nvim.lsp.ai.model.chat,
  stream = true, -- Optional
  options = {
    num_ctx = 512,
    temperature = 0,
  },
  -- for open ai compatible api
  -- endpoint = "https://api.ai.kilic.dev/v1",
  -- __inherited_from = "openai",
}

return M
