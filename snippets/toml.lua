local s = require("ck.utils.snippets")

return {
  s.s(
    {
      trig = "mise",
      name = "mise",
      desc = { "Create a mise configuration." },
    },
    s.fmt(
      [[
      # $schema  = 'https://mise.jdx.dev/schema/mise.json'
      ]],
      {}
    )
  ),
}
