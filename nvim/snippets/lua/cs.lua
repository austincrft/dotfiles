local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local function get_namespace()
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  -- Walk up directories to find .csproj
  local csproj_dir = nil
  local search_dir = current_dir

  while search_dir ~= vim.fn.fnamemodify(search_dir, ":h") do
    local csproj_files = vim.fn.glob(search_dir .. "/*.csproj", false, true)
    if #csproj_files > 0 then
      csproj_dir = search_dir
      break
    end
    search_dir = vim.fn.fnamemodify(search_dir, ":h")
  end

  if not csproj_dir then
    return "MyNamespace"
  end

  -- Get the relative path from csproj directory to current file
  local relative_path = current_dir:sub(#csproj_dir + 2) -- +2 to skip the path separator

  -- Convert path separators to dots
  local namespace = relative_path:gsub("[\\/]+", ".")

  -- If we're in the same directory as csproj, use the csproj name
  if namespace == "" then
    local csproj_name = vim.fn.fnamemodify(vim.fn.glob(csproj_dir .. "/*.csproj"), ":t:r")
    return csproj_name
  end

  -- Prepend the project name
  local csproj_name = vim.fn.fnamemodify(vim.fn.glob(csproj_dir .. "/*.csproj"), ":t:r")
  return csproj_name .. "." .. namespace
end

local namespace = s("namespace", {
  t("namespace "), f(get_namespace, {}), t(";"),
})

return {
  namespace,
}
