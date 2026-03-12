return {
  "catppuccin/nvim",
  name = "catppuccin",
  -- load as first
  priority = 1000,
  config = function()
    local cmd = vim.cmd

    require("catppuccin").setup({
      -- latte, frappe, macchiato, mocha
      flavour = "mocha",
      transparent_background = true
    })

    cmd.colorscheme("catppuccin")
  end,
}
