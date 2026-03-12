return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    local glob = vim.g
    local api = vim.api
    local fn = vim.fn
    local cmd = vim.cmd

    glob.loaded_netrw = 1
    glob.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        icons = {
          glyphs = {
            default = "",
          },
        },
      },
      filters = {
        dotfiles = false,
      },
    })

    api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if fn.isdirectory(fn.argv(0)) == 1 then
          cmd("NvimTreeOpen")
        end
      end,
    })

    api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local tree_wins = {}
        local floating_wins = {}
        local wins = api.nvim_list_wins()
        for _, w in ipairs(wins) do
          local bufname = api.nvim_buf_get_name(api.nvim_win_get_buf(w))
          if bufname:match("NvimTree_") then
            table.insert(tree_wins, w)
          end
          if api.nvim_win_get_config(w).relative ~= "" then
            table.insert(floating_wins, w)
          end
        end
        if #wins - #floating_wins - #tree_wins == 1 then
          for _, w in ipairs(tree_wins) do
            api.nvim_win_close(w, true)
          end
        end
      end,
    })
  end,
}
