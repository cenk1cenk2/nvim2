local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        vim.opt_local.indentexpr = "GetDjangoIndent()"

        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
      ["zsh"] = "sh",
      ["go.tmpl"] = "gotmpl",
      ["gotmpl"] = "gotmpl",
      ["tmpl"] = "gotmpl",
      ["tpl"] = function(path)
        if path:find("templates/") then
          return "helm"
        end

        return "gotmpl"
      end,
    },
    filename = {
      [".editorconfig"] = "toml",
      [".rgignore"] = "gitignore",
      [".npmignore"] = "gitignore",
      [".prettierignore"] = "gitignore",
      [".eslintignore"] = "gitignore",
      [".dockerignore"] = "gitignore",
      ["tsconfig.json"] = "jsonc",
      [".prettierrc"] = "json",
      [".eslintrc"] = "json",
      [".babelrc"] = "json",
    },
    pattern = {
      ["Dockerfile.*"] = "dockerfile",
      [".*%.yml"] = function(path)
        if path:find("docker%-compose.*$") then
          return "yaml.docker-compose"
        end

        local ansible_root = require("lspconfig/util").root_pattern("ansible.cfg", ".ansible-lint", ".vault-password")(path)

        if
          ansible_root
          and not (path:find("environments/") or path:find("vars/") or path:find("group_vars/") or path:find("host_vars/"))
          and vim.fs.dirname(path) ~= ansible_root
        then
          return "yaml.ansible"
        end

        return "yaml"
      end,
      [".*%.yaml"] = function(path)
        if require("lspconfig/util").root_pattern("Chart.yaml")(path) and path:find("templates/") then
          return "helm"
        end

        return "yaml"
      end,
    },
  })
end

return M
