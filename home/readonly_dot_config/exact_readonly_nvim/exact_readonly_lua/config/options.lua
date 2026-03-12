local opt = vim.opt
local api = vim.api
local schdl = vim.schedule

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"

api.nvim_create_augroup("RestoreCursorShapeOnExit", { clear = true })
api.nvim_create_autocmd("VimLeave", {
  group = "RestoreCursorShapeOnExit",
  command = "set guicursor=a:ver20,a:blinkwait700-blinkoff400-blinkon250",
})

schdl(function()
  opt.clipboard = "unnamedplus"
end)
