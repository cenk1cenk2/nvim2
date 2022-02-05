local M = {}

local extension_name = "aerojump_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {},
    keymaps = {
      ["<C-p>"] = "AerojumpUp",
      ["<Left>"] = "AerojumpSelPrev",
      ["<C-g>"] = "AerojumpSelPrev",
      ["<C-j>"] = "AerojumpSelect",
      ["<Down>"] = "AerojumpDown",
      ["<C-k>"] = "AerojumpUp",
      ["<Up>"] = "AerojumpUp",
      ["<C-n>"] = "AerojumpDown",
      ["<Right>"] = "AerojumpSelNext",
      ["<C-l>"] = "AerojumpSelNext",
      ["<C-q>"] = "AerojumpExit",
      ["<ESC>"] = "AerojumpSelect",
      ["<CR>"] = "AerojumpSelect",
    },
  }
end

function M.setup()
  vim.g.aerojump_keymaps = lvim.extensions[extension_name].keymaps
  vim.g.aerojump_bolt_lines_before = 3
  vim.g.aerojump_bolt_lines_after = 3

  lvim.builtin.which_key.mappings["f"]["a"] = {
    ":Aerojump kbd bolt<CR>",
    "aerojump",
  }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
