-- File: plugins/autoformat.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    -- Define formatters
    formatters_by_ft = {
      -- Python
      python = { "ruff_format" },
      
      -- JavaScript/TypeScript
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      
      -- Web
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      
      -- Data formats
      json = { "prettier" },
      yaml = { "prettier" },
      
      -- Documentation
      markdown = { "prettier" },
      
      -- Lua
      lua = { "stylua" },
    },
    
    -- Format on save is crucial for autoformatting
    format_on_save = {
      -- Prevent hang when formatters time out
      timeout_ms = 3000,
      -- Fallback to LSP formatting if available
      lsp_fallback = true,
      -- Process synchronously to ensure formatting completes before saving
      async = false,
    },
    
    -- Configure notify for format issues
    notify_on_error = true,
  },
  config = function(_, opts)
    local conform = require("conform")
    
    -- Setup conform with our options
    conform.setup(opts)
    
    -- Create keymaps for manual formatting
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
