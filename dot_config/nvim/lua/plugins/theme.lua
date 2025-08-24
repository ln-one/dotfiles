return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    config = function()
      require("auto-dark-mode").setup({
        set_dark_mode = function()
          vim.cmd([[colorscheme catppuccin-mocha]])
        end,
        set_light_mode = function()
          vim.cmd([[colorscheme catppuccin-latte]])
        end,
      })
    end,
  },
}
