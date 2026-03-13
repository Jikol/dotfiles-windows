local glob = vim.g
local map = vim.keymap.set

glob.mapleader = " "
glob.maplocalleader = "\\"

-- plugins mappings
map("n", "<leader>f", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<cr>", { desc = "Explorer" })
