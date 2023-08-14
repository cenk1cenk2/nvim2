local M = {
  banner = {},
}

local fmt = string.format
local text = require("lvim.interface.text")
local lsp_utils = require("lvim.lsp.utils")

local function str_list(list)
  return #list == 1 and list[1] or fmt("[%s]", table.concat(list, ", "))
end

local function make_efm_info(ft)
  local efm = require("lvim.lsp.efm")

  local supported_linters = efm.list_registered(ft, efm.METHOD.LINTER)
  local supported_formatters = efm.list_registered(ft, efm.METHOD.FORMATTER)

  local section = {
    "efm",
    fmt("* Active Linters: %s%s", table.concat(supported_linters, " " .. lvim.ui.icons.ui.BoxChecked .. " , "), vim.tbl_count(supported_linters) > 0 and "  " or ""),
    fmt("* Active Formatters: %s%s", table.concat(supported_formatters, " " .. lvim.ui.icons.ui.BoxChecked .. " , "), vim.tbl_count(supported_formatters) > 0 and "  " or ""),
  }

  return section
end

local function tbl_set_highlight(terms, highlight_group)
  for _, v in pairs(terms) do
    vim.cmd('let m=matchadd("' .. highlight_group .. '", "' .. v .. "[ ,│']\")")
    vim.cmd('let m=matchadd("' .. highlight_group .. '", ", ' .. v .. '")')
  end
end

--- @param client lsp.Client
--- @return table<string> | nil
local function make_client_info(client)
  local client_enabled_caps = lsp_utils.get_client_capabilities(client.id)
  local id = client.id
  local name = client.name
  local client_info = {
    fmt("* name:                      %s", name),
    fmt("* id:                        %s", tostring(id)),
    fmt("* supported filetype(s):     %s", str_list(client.config.filetypes)),
    fmt("* attached buffers:          %s", tostring(str_list(vim.lsp.get_buffers_by_client_id(client.id)))),
    fmt("* root directory:            %s", tostring(client.config.root_dir)),
  }
  if not vim.tbl_isempty(client_enabled_caps) then
    local caps_text = "* capabilities:              "
    local caps_text_len = caps_text:len()
    local enabled_caps = text.format_table(client_enabled_caps, 3, " | ")
    enabled_caps = text.shift_right(enabled_caps, caps_text_len)
    enabled_caps[1] = fmt("%s%s", caps_text, enabled_caps[1]:sub(caps_text_len + 1))
    vim.list_extend(client_info, enabled_caps)
  end

  vim.list_extend(client_info, { "" })

  return client_info
end

local function make_auto_lsp_info(ft)
  local skipped_filetypes = lvim.lsp.automatic_configuration.skipped_filetypes
  local skipped_servers = lvim.lsp.automatic_configuration.skipped_servers
  local info_lines = { "Automatic LSP info" }

  if vim.tbl_contains(skipped_filetypes, ft) then
    vim.list_extend(info_lines, { "* Status: disabled for " .. ft })
    return info_lines
  end

  local supported = lsp_utils.get_supported_servers(ft)
  local skipped = vim.tbl_filter(function(name)
    return vim.tbl_contains(supported, name)
  end, skipped_servers)

  if #skipped == 0 then
    return { "" }
  end

  vim.list_extend(info_lines, { fmt("* Skipped servers: %s", str_list(skipped)) })

  return info_lines
end

function M.toggle_popup(ft)
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  local client_names = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local ts_active_buffers = vim.tbl_keys(vim.treesitter.highlighter.active)
  local is_treesitter_active = function()
    local status = "inactive"
    if vim.tbl_contains(ts_active_buffers, bufnr) then
      status = "active"
    end
    return status
  end
  local header = {
    "Buffer info",
    fmt("* filetype:                %s", ft),
    fmt("* bufnr:                   %s", bufnr),
    fmt("* treesitter status:       %s", is_treesitter_active()),
  }

  local current_buffer_lsp_info = {
    "Current buffer LSP client(s)",
  }

  for _, client in pairs(clients) do
    local client_info = make_client_info(client)
    if client_info then
      vim.list_extend(current_buffer_lsp_info, client_info)
    end
    table.insert(client_names, client.name)
  end

  local lsp_info = {
    "Active LSP client(s)",
  }

  for _, client in pairs(vim.lsp.get_clients()) do
    local client_info = make_client_info(client)
    if client_info then
      vim.list_extend(lsp_info, client_info)
    end
  end

  local auto_lsp_info = make_auto_lsp_info(ft)
  local efm_info = make_efm_info(ft)

  local content_provider = function(popup)
    local content = {}

    for _, section in ipairs({
      { "" },
      { "" },
      header,
      { "" },
      current_buffer_lsp_info,
      { "" },
      efm_info,
      { "" },
      lsp_info,
      { "" },
      auto_lsp_info,
    }) do
      vim.list_extend(content, section)
    end

    return text.align_left(popup, content, 0.5)
  end

  local function set_syntax_hl()
    vim.cmd([[highlight LvimInfoIdentifier gui=bold]])
    vim.cmd([[highlight link LvimInfoHeader Type]])
    vim.fn.matchadd("LvimInfoHeader", "Buffer info")
    vim.fn.matchadd("LvimInfoHeader", "Current buffer LSP client(s)")
    vim.fn.matchadd("LvimInfoHeader", "Active LSP client(s)")
    vim.fn.matchadd("LvimInfoHeader", fmt("Overridden %s server(s)", ft))
    vim.fn.matchadd("LvimInfoHeader", "efm")
    vim.fn.matchadd("LvimInfoHeader", "Automatic LSP info")
    vim.fn.matchadd("LvimInfoIdentifier", " " .. ft .. "$")
    vim.fn.matchadd("string", "true")
    vim.fn.matchadd("string", "active")
    vim.fn.matchadd("string", "")
    vim.fn.matchadd("boolean", "inactive")
    vim.fn.matchadd("error", "false")
  end

  local Popup = require("lvim.interface.popup"):new({
    win_opts = { number = false },
    buf_opts = { modifiable = false, filetype = "lspinfo" },
  })
  Popup:display(content_provider)
  set_syntax_hl()

  return Popup
end
return M
