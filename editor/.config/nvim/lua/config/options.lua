-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Désactiver la conversion des tabs en espaces
vim.opt.expandtab = false -- insère des tabs (\t) au lieu d'espaces

-- Largeur d’un tab en affichage
vim.opt.tabstop = 4 -- 1 tab = 4 colonnes

-- Largeur utilisée pour >> et <<
vim.opt.shiftwidth = 4 -- indent/dedent = 4

-- Nombre de colonnes pour tabulation "soft" (ex: en insert mode)
vim.opt.softtabstop = 4
