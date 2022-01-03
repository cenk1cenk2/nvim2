local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, installers = pcall(require, "nvim-lsp-installer.installers")
local _, npm = pcall(require, "nvim-lsp-installer.installers.npm")

local server_name = "prettierd"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe { npm.packages { "@fsouza/prettierd" } },
  default_options = { cmd = { server_name }, cmd_env = vim.tbl_extend('force', npm.env(root_dir),  {

        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand "~/.config/nvim/utils/linter-config/.prettierrc.json",
  })  },
})
