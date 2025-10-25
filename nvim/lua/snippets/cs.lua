local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node


local xunitfact = s("xunitfact", {
    t({
      "[Fact]",
      "public void ",
    }),
    i(1, "Test"),
    t({
      "()",
      "{",
      "    // Arrange",
      "",
    }),
    i(2),
    t({
      "",
      "    // Act",
      "",
    }),
    i(3),
    t({
      "",
      "    // Assert",
      "",
    }),
    i(4),
    t({
      "}",
    }),
  }
)

return {
  xunitfact,
}
