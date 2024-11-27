local s = require("ck.utils.snippets")

return {
  s.s(
    {
      name = "prettierrc.mjs",
      trig = "prettierrc",
      desc = { "Create a quick prettierrc." },
    },
    s.fmt(
      [[
      import prettierrc from '@cenk1cenk2/eslint-config/prettierrc'

      /** @type {import("prettier").Config} */
      export default {
        ...prettierrc,
        <>
      }
      ]],
      {
        s.i(1),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      name = "eslint.config.mjs",
      trig = "eslintrc",
      desc = { "Create a quick eslintrc." },
    },
    s.fmt(
      [[
      import { configs, utils } from '@cenk1cenk2/eslint-config'

      /** @type {import("eslint").Linter.Config[]} */
      export default [
        ...configs['typescript-dynamic'],
        ...utils.configImportGroup({ tsconfigDir: import.meta.dirname, tsconfig: 'tsconfig.json' }),
        <>
      ]
      ]],
      {
        s.i(1),
      },
      { delimiters = "<>" }
    )
  ),
}
