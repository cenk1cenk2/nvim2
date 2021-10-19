local M = {}

function M.config()
  local utils_table = require "lvim.utils.table"
  local pre_hook = nil
  if lvim.builtin.treesitter.context_commentstring.enable then
    pre_hook = function()
      if
        utils_table.contains({ "javascript", "typescriptreact", "vue", "svelte" }, function(type)
          return type == vim.bo.filetype
        end)
      then
        require("ts_context_commentstring.internal").update_commentstring()
      end
    end
  end
  lvim.builtin.comment = {
    active = true,
    on_config_done = nil,
    ---Add a space b/w comment and the line
    ---@type boolean
    padding = true,

    ---Lines to be ignored while comment/uncomment.
    ---Could be a regex string or a function that returns a regex string.
    ---Example: Use '^$' to ignore empty lines
    ---@type string|function
    -- ignore = "^$",

    ---Whether to create basic (operator-pending) and extra mappings for NORMAL/VISUAL mode
    ---@type table
    mappings = {
      ---operator-pending mapping
      ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
      basic = true,
      ---extended mapping
      ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
      extra = false,
    },

    ---LHS of line and block comment toggle mapping in NORMAL/VISUAL mode
    ---@type table
    toggler = {
      ---line-comment toggle
      line = "gcc",
      ---block-comment toggle
      block = "gbc",
    },

    ---LHS of line and block comment operator-mode mapping in NORMAL/VISUAL mode
    ---@type table
    opleader = {
      ---line-comment opfunc mapping
      line = "gc",
      ---block-comment opfunc mapping
      block = "gb",
    },

    ---Pre-hook, called before commenting the line
    ---@type function|nil
    pre_hook = pre_hook,

    ---Post-hook, called after commenting is done
    ---@type function|nil
    post_hook = nil,
  }
end

function M.setup()
  local nvim_comment = require "Comment"

  require("lvim.keymappings").load {
    normal_mode = {
      ["<C-\\>"] = ":lua require('Comment').toggle()<CR>",
      ["<C-#>"] = ":lua require('Comment').toggle()<CR>",
      ["<M-#>"] = ":lua ___comment_call('gbc')<CR>g@$",
    },

    visual_mode = {
      ["<C-\\>"] = ":lua require('Comment').toggle()<CR>",
      ["<C-#>"] = ":lua require('Comment').toggle()<CR>",
      ["<M-#>"] = ":lua ___comment_call('gb')<CR>g@$",
    },
  }

  nvim_comment.setup(lvim.builtin.comment)
  if lvim.builtin.comment.on_config_done then
    lvim.builtin.comment.on_config_done(nvim_comment)
  end
end

return M
