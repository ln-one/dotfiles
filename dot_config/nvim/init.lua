-- 设置安全的默认colorscheme，防止tokyonight错误
vim.cmd("colorscheme default")
vim.o.background = "dark"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.init")
