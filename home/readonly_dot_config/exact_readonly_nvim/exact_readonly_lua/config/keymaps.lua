local glob = vim.g
local map = vim.keymap.set

glob.mapleader = " "
glob.maplocalleader = "\\"

-- QoL mappings
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- plugins mappings
map("n", "<leader>f", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<cr>", { desc = "Explorer" })
