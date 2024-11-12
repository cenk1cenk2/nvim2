local M = {}

--- Safely quits the workspace.
function nvim.fn.workspace_quit()
  local buffers = vim.api.nvim_list_bufs()
  local modified = false
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) and vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      modified = true

      break
    end
  end

  if modified then
    vim.ui.select({ { name = "yes", value = true }, { name = "no", value = false } }, {
      prompt = "You have unsaved changes. Quit anyway? (y/n) ",
      format_item = function(item)
        return item.name
      end,
    }, function(input)
      if not input then
        return
      end

      vim.cmd("qa!")
    end)
  else
    vim.cmd("qa!")
  end
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SESSION, "q" }),
          function()
            nvim.fn.workspace_quit()
          end,
          desc = "quit",
        },
      }
    end,
  })
end

return M
