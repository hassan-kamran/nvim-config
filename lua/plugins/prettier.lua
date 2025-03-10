-- File: plugins/prettier.lua
return {
  -- Configure conform.nvim to use prettier for formatting
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      
      -- Add prettier formatter for web development file types
      opts.formatters_by_ft["html"] = { "prettier" }
      opts.formatters_by_ft["css"] = { "prettier" }
      opts.formatters_by_ft["scss"] = { "prettier" }
      opts.formatters_by_ft["javascript"] = { "prettier" }
      opts.formatters_by_ft["javascriptreact"] = { "prettier" }
      opts.formatters_by_ft["typescript"] = { "prettier" }
      opts.formatters_by_ft["typescriptreact"] = { "prettier" }
      opts.formatters_by_ft["json"] = { "prettier" }
      opts.formatters_by_ft["markdown"] = { "prettier" }
      
      -- Format on save configuration
      opts.format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
        async = false,
      }
      
      return opts
    end,
  },

  -- Ensure prettier is installed via Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      
      -- Make sure prettier is in the list of tools to install
      if not vim.tbl_contains(opts.ensure_installed, "prettier") then
        table.insert(opts.ensure_installed, "prettier")
      end
      
      return opts
    end,
  },
}
