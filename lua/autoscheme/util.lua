local M = {}

function M.get_package_path()
  -- Path to this source file, removing the leading '@'
  local source = string.sub(debug.getinfo(1, "S").source, 2)

  -- Path to the package root
  return vim.fn.fnamemodify(source, ":p:h:h:h")
end

---@param output_dir string | nil
function M.create_or_reuse_output_dir(output_dir)
  local dir = output_dir or M.get_package_path() .. "/colors"

  vim.fn.mkdir(dir, "p", "0755")
end

return M
