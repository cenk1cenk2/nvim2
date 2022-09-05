local M = {}
local Log = require "lvim.core.log"
local utils = require "lvim.utils"
local autocmds = require "lvim.core.autocmds"

local function add_lsp_buffer_options(bufnr)
  for k, v in pairs(lvim.lsp.buffer_options) do
    vim.api.nvim_buf_set_option(bufnr, k, v)
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  local mappings = {
    normal_mode = "n",
    insert_mode = "i",
    visual_mode = "v",
  }

  for mode_name, mode_char in pairs(mappings) do
    for key, remap in pairs(lvim.lsp.buffer_mappings[mode_name]) do
      local opts = { buffer = bufnr, desc = remap[2], noremap = true, silent = true }
      vim.keymap.set(mode_char, key, remap[1], opts)
    end
  end
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

function M.common_on_exit(_, _)
  if lvim.lsp.document_highlight then
    autocmds.clear_augroup "lsp_document_highlight"
  end
  if lvim.lsp.code_lens_refresh then
    autocmds.clear_augroup "lsp_code_lens_refresh"
  end
end

function M.common_on_init(client, bufnr)
  if lvim.lsp.on_init_callback then
    lvim.lsp.on_init_callback(client, bufnr)
    Log:debug "Called lsp.on_init_callback"
    return
  end
end

function M.common_on_attach(client, bufnr)
  if lvim.lsp.on_attach_callback then
    lvim.lsp.on_attach_callback(client, bufnr)
    Log:debug "Called lsp.on_attach_callback"
  end
  local lu = require "lvim.lsp.utils"
  if lvim.lsp.document_highlight then
    lu.setup_document_highlight(client, bufnr)
  end
  if lvim.lsp.code_lens_refresh then
    lu.setup_codelens_refresh(client, bufnr)
  end
  add_lsp_buffer_keybindings(bufnr)
  add_lsp_buffer_options(bufnr)
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.common_capabilities(),
  }
end

function M.setup()
  if #vim.api.nvim_list_uis() == 0 then
    Log:debug "headless mode detected, skipping setting lsp support"
    return
  end

  Log:debug "Setting up LSP support"

  Log:debug "Installing LSP servers."

  local installer_ok, installer = pcall(require, "mason-tool-installer")

  if installer_ok then
    installer.setup {
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = lvim.lsp.ensure_installed,

      -- if set to true this will check each tool for updates. If updates
      -- are available the tool will be updated. This setting does not
      -- affect :MasonToolsUpdate or :MasonToolsInstall.
      -- Default: false
      auto_update = false,

      -- automatically install / update on startup. If set to false nothing
      -- will happen on startup. You can use :MasonToolsInstall or
      -- :MasonToolsUpdate to install tools and check for updates.
      -- Default: true
      run_on_start = true,

      start_delay = 1000, -- 3 second delay
    }
  else
    Log:warn "LSP installer not available."
  end

  local lsp_status_ok, _ = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end

  require("modules-lsp").setup()

  if lvim.use_icons then
    for _, sign in ipairs(lvim.lsp.diagnostics.signs.values) do
      vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end
  end

  require("lvim.lsp.handlers").setup()

  if not utils.is_directory(lvim.lsp.templates_dir) then
    require("lvim.lsp.templates").generate_templates()
  end

  pcall(function()
    require("nlspsettings").setup(lvim.lsp.nlsp_settings.setup)
  end)

  pcall(function()
    require("mason-lspconfig").setup(lvim.lsp.installer.setup)
    local util = require "lspconfig.util"
    -- automatic_installation is handled by lsp-manager
    util.on_setup = nil
  end)

  require("lvim.lsp.null-ls").setup()

  autocmds.configure_format_on_save()
end

return M
