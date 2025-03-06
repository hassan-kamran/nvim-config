return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "Mocha",
  },
  config = function()
    require("catppuccin").setup({
      flavour = "Mocha",
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
