return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        section_separators = "",
        component_separators = "",
        disabled_filetypes = {
          statusline = { "NvimTree" }
        }
      }
    })
  end,
}
