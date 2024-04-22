local M = {}

local util = require "autoscheme.util"

---@type ColorschemeOpts
local default_opts = {
  reload = true,
  generate = true,
  on_startup = true,
  input_dir = vim.fn.stdpath "config",
  output_dir = util.get_package_path() .. "/colors",
}

---@type ColorschemeOpts
local opts = default_opts
local autocmd_group = nil

---@class Colorscheme
---@field input string
---@field output string | nil
---@field real_input string | nil
---@field opts ColorschemeOpts

---@class ColorschemeOpts
---@field reload boolean | nil
---@field generate boolean | nil
---@field on_startup boolean | nil
---@field input_dir string
---@field output_dir string

---@param config Colorscheme | string
---@param defaults ColorschemeOpts | nil
---@return Colorscheme
function M.expand_config(config, defaults)
  vim.validate {
    config = { config, { "table", "string" } },
    defaults = { defaults, { "table", "nil" } },
  }

  local input
  local output
  local real_input
  defaults = vim.tbl_deep_extend("force", default_opts, defaults)

  if type(config) == "string" then
    -- this won't work on windows
    if config[1] == "/" then
      input = config
    else
      -- this likely neither
      input = defaults.input_dir .. "/" .. config
    end
  elseif type(config) == "table" then
    vim.validate {
      input = { config.input, "string" },
      output = { config.output, { "string", "nil" } },
      opts = { config.opts, { "table", "nil" } },
    }

    input = config.input
    output = config.output
    defaults = vim.tbl_deep_extend("force", defaults, config.opts or {})
  end

  if type(output) == "nil" then
    local input_stem = input:match "([^\\/]+)%.toml$"
    if type(input_stem) == "nil" then
      error("input must end with `.toml`, but was " .. input)
    end

    output = input_stem .. ".lua"
  end

  if output:sub(1, 1) ~= "/" then
    output = defaults.output_dir .. "/" .. output
  end

  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  if type(config.real_input) == "nil" then
    real_input = vim.loop.fs_realpath(input)
  end

  return {
    input = input,
    output = output,
    real_input = real_input,
    opts = opts,
  }
end

---@param config Colorscheme | string
function M.compile_colorscheme(config)
  config = M.expand_config(config, opts)

  local cmd_output = vim.fn.system {
    "colorgen-nvim",
    config.input,
    "--single-file",
    "--output",
    config.output,
  }

  if cmd_output:len() > 0 then
    print(cmd_output)
  end

  local colorscheme = config.output:match "([^\\/]+)%.lua$"

  if config.opts.generate and colorscheme == vim.g.colors_name then
    vim.cmd.colorscheme(colorscheme)
  end
end

---@param config Colorscheme | string
---@param run boolean | nil
function M.register_colorscheme(config, run)
  config = M.expand_config(config, opts)
  run = run or false

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = autocmd_group,
    pattern = config.real_input,
    callback = function(_) M.compile_colorscheme(config) end,
  })

  if run then
    M.compile_colorscheme(config)
  end
end

function M.initialize()
  local o = vim.g.autoscheme

  vim.validate {
    colorschemes = { o[1], { "string", "table" }, defaults = { o.defaults, { "table", "nil" } } },
  }

  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  autocmd_group = vim.api.nvim_create_augroup("autoscheme-nvim", { clear = true })

  if type(o[1]) == "string" then
    local config = M.expand_config(o[1])
    M.register_colorscheme(config, opts.on_startup)
  elseif type(o[1]) == "table" then
    for _, config in pairs(o[1]) do
      vim.validate { colorscheme = { config, { "table", "string" } } }
      M.register_colorscheme(config, opts.on_startup)
    end
  end
end

function M.setup(config)
  vim.g.autoscheme = config
  M.initialize()
end

return M
