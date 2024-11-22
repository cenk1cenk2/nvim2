local M = {}

--- Safely quits the workspace.
function nvim.fn.workspace_quit()
  local buffers = vim.api.nvim_list_bufs()
  local modified = {}
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) and vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      table.insert(modified, require("ck.utils.fs").get_project_buffer_filepath(bufnr))
    end
  end

  if #modified > 0 then
    require("ck.utils").ui_confirm({
      prompt = ("You have unsaved changes, quit anyways?\n%s"):format(table.concat(modified, "\n")),
      choices = {
        {
          label = "Quit",
          callback = function()
            vim.cmd("qa!")
          end,
        },
        {
          label = "Save",
          callback = function()
            vim.cmd("wa")
            vim.cmd("qa!")
          end,
        },
        { label = "Cancel" },
      },
    })
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
