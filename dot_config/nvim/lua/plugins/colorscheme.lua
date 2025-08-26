return {
  -- 完全禁用 LazyVim 的默认 colorscheme 插件
  { "folke/tokyonight.nvim", enabled = false },
  
  -- 重新定义 catppuccin 插件
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
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
      
      -- 延迟设置 colorscheme 避免冲突
      vim.schedule(function()
        vim.cmd.colorscheme("catppuccin-macchiato")
      end)
    end,
  },
}