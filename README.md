# autoscheme.nvim

Neovim Plugin to generate and automatically reload colorschemes using [colorgen-nvim](https://github.com/LunarVim/colorgen-nvim).

## Getting Started

Install colorgen-nvim using `cargo install --branch pr/global-variables --git https://github.com/titaniumtraveler/colorgen-nvim`. \
(This installs a fork with a few more features, that will hopefully be merged soon.)

## Configuration with `lazy.nvim`

```lua
local M = {
  "titaniumtraveler/autoscheme.nvim",
  lazy = false,
  priority = 1000, -- make sure that the colorscheme is actually loaded first
}

function M.config()
  require "autoscheme".setup {
    {
      {
        -- Required, is used as relative path from `opts.input_dir`
        -- unless it is an absolute path (i. e. begins with `/`.)
        input = "<input.toml>",
        -- Optional, if missing, is filled with `opts.output_dir .. "/" .. "<input>.lua`
        output = "<output.lua>",
        -- Optional, same as `defaults`
        opts = { ... },
      },

      -- Alternatively, if you only want to set the input path, you can also use a simple string
      "<input.toml>",
    },
    -- Optional
    defaults = {
        reload        = true, -- reload colorscheme on compile (only if the colorscheme is currently active)
        autogenerate  = true, -- regenerate colorscheme on change (using an autocommand)
        on_initialize = true, -- generate colorschemes on initialize
        input_dir     = vim.fn.stdpath "config",
        output_dir    = require "autoscheme.util".get_package_path() .. "/colors",
    },
  }
end

return M
```

## Manual configuration

Alternatively you can also put your configuration into `vim.g.autoscheme`
and call `require "autoscheme" . initialize()`.

Or to do all of that manually:

```lua
local autoscheme = require "autoscheme"

-- this is required to setup the autocommands correctly!
autoscheme.initialize()

-- this accepts everything the setup function accepts to configure the colorschemes
-- the bool configures whether to directly compile the colorscheme (defaults to false)
autoscheme.register_colorscheme ({
    input  = "<input.toml>",
    output = "<output.lua>",
    opts   = { ... },
  },
  true
)
autoscheme.register_colorscheme "<input.toml>"
```

Or if you only want to compile the colorschemes you can do that too:

```lua
require "autoscheme".compile_colorscheme "<input.toml>"
```

## Windows

While `colorgen-nvim` *does* support windows, this plugin does not,
as it is written with Linux/Unix in mind.

I might fix that at some point, but it is not really a priority for me.
