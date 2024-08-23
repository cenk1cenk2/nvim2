local M = {}
local log = require("lvim.log")

function M.enable_format_on_save()
  vim.api.nvim_create_augroup("lsp_format_on_save", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = "lsp_format_on_save",
    pattern = lvim.lsp.format_on_save.pattern,
    callback = function(args)
      lvim.lsp.wrapper.format({ bufnr = args.bufnr })
    end,
  })
  log:debug("enabled format-on-save")
end

function M.disable_format_on_save()
  require("utils.setup").clear_augroup("lsp_format_on_save")
  log:debug("disabled format-on-save")
end

function M.configure_format_on_save()
  if lvim.lsp.format_on_save.enable then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.toggle_format_on_save()
  local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_format_on_save",
    event = "BufWritePre",
  })
  if not exists or #autocmds == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

return M
