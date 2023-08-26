local M = {}

M.default_opts = {
  auto_reload = true,
  auto_generate = true,
}

local function generate_colorscheme(input, output)
  vim.fn.system {
    "colorgen-nvim",
    input,
    "--single-file",
    "--output",
    output,
  }
end

local function get_colorscheme_name(path)
  local file_name = path:match("[^/\\]*.lua$")
  return file_name:sub(0, #file_name - 4)
end

local function register_generate(value, group)
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = value[1],
    callback = function()
      if value.auto_generate then
        generate_colorscheme(value[1], value[2])
      end

      local colorscheme = get_colorscheme_name(value[2])

      if value.auto_reload and colorscheme == vim.g.colors_name then
        vim.cmd.colorscheme(colorscheme)
      end
    end,
    group = group,
  })
end

function M.setup(opts)
  local group = vim.api.nvim_create_augroup("autoscheme.nvim", { clear = true })
  for _, value in pairs(opts) do
    value = vim.tbl_deep_extend("force", M.default_opts, value)
    if value.auto_generate or value.auto_reload then
      register_generate(value, group)
    end
    generate_colorscheme(value[1], value[2])
  end
end

return M
