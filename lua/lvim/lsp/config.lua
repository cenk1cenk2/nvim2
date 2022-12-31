return {
  templates_dir = join_paths(get_data_dir(), "site", "after", "ftplugin"),
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = lvim.icons.diagnostics.Error },
        { name = "DiagnosticSignWarn", text = lvim.icons.diagnostics.Warning },
        { name = "DiagnosticSignHint", text = lvim.icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo", text = lvim.icons.diagnostics.Information },
      },
    },
    virtual_text = {
      prefix = "",
      source = "always",
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = lvim.ui.border,
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          return string.format("%s [%s]", d.message, code):gsub("1. ", "")
        end
        return d.message
      end,
    },
  },
  code_lens_refresh = true,
  float = {
    focusable = true,
    style = "minimal",
    border = lvim.ui.border,
  },
  peek = {
    max_height = 36,
    max_width = 180,
    context = 48,
  },
  on_init_callbacks = {},
  on_attach_callbacks = {},
  on_exit_callbacks = {},
  buffer_mappings = require("keys.lsp-mappings"),
  automatic_configuration = {
    ---@usage list of servers that the automatic installer will skip
    skipped_servers = {},
    ---@usage list of filetypes that the automatic installer will skip
    skipped_filetypes = {},
  },
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },
  ---@usage list of settings of nvim-lsp-installer
  installer = {
    setup = {
      ensure_installed = {},
      automatic_installation = {
        exclude = {},
      },
    },
  },
  nlsp_settings = {
    setup = {
      config_home = join_paths(get_config_dir(), "lsp-settings"),
      -- set to false to overwrite schemastore.nvim
      append_default_schemas = true,
      ignored_servers = {},
      loader = "json",
    },
  },
  null_ls = {
    setup = {
      debug = false,
    },
    config = {},
  },
  ---@deprecated use lvim.lsp.automatic_configuration.skipped_servers instead
  override = {},
  ---@deprecated use lvim.lsp.installer.setup.automatic_installation instead
  automatic_servers_installation = nil,
}
