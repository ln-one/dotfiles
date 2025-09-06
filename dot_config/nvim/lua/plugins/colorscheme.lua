return {
  -- 完全禁用 LazyVim 的默认 colorscheme 插件
  { "folke/tokyonight.nvim", enabled = false },
  
  -- auto-dark-mode 插件，自动切换亮暗色主题
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1500, -- 确保在 colorscheme 之前加载
    config = function()
      local auto_dark_mode = require("auto-dark-mode")
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option_value("background", "dark", {})
          vim.cmd.colorscheme("catppuccin-mocha")
        end,
        set_light_mode = function()
          vim.api.nvim_set_option_value("background", "light", {})
          vim.cmd.colorscheme("catppuccin-latte")
        end,
      })
    end,
  },
  
  -- 重新定义 catppuccin 插件
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto", -- 自动选择 flavour
        transparent_background = true,
        integrations = {
          blink_cmp = true,
          gitsigns = true,
          treesitter = true,
          notify = true,
          mini = {
            enabled = true,
          },
          telescope = {
            enabled = true,
          },
          which_key = true,
          snacks = true,
          bufferline = true,
        },
      })
    end,
  },
}