-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Global plugin variables
vim.g.snacks_animate = false
vim.g.lazyvim_check_order = false

-- Core editor options
vim.opt.ignorecase = true
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.scrolloff = 8

-- Disable unnamedplus so Neovim uses fast internal registers for local y and p
vim.opt.clipboard = ""

-- Indentation defaults (2 spaces)
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Broadcast all local yanks outward to Windows clipboard via OSC 52
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("OSC52Yank", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" then
      require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
    end
  end,
})

-- Security: Prevent caching sensitive files (registers, swap, undo history)
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("SecureSensitiveBuffers", { clear = true }),
  pattern = { ".env*", "*secret*", "*.pem", "*/.ssh/id_*" },
  callback = function()
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt.shada = ""
  end,
})
