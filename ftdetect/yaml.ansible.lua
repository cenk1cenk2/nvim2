vim.cmd [[
  au BufRead *.yaml,*.yml if search('hosts:\|tasks:', 'nw') | set ft=yaml.ansible | endif
  au BufRead,BufNewFile deploy.yml setlocal filetype=yaml.ansible
  au BufRead,BufNewFile provision.yml setlocal filetype=yaml.ansible
  au FileType yaml.ansible lua require("lvim.lsp.manager").setup("ansiblels")
]]
