-- File: plugins/mason.lua
return {
  -- Mason for managing external tools
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-lspconfig for automatic LSP setup
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },
        automatic_installation = true,
      })
    end,
  },

  -- Mason-tool-installer for ensuring Ruff is installed
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "pyright",
          "ruff",
        },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },

  -- nvim-lint for running Ruff as a linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        python = { "ruff" },
      }
      
      -- Set up autocommand to run linter on file changes
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
      
      -- Key mapping to manually trigger linting
      vim.keymap.set("n", "<leader>l", function()
        require("lint").try_lint()
      end, { desc = "Lint current file" })
    end,
  },

  -- Conform for formatting with Ruff
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format" }, -- Use Ruff for formatting
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      
      -- Key mapping for manual formatting
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true })
      end, { desc = "Format current buffer" })
    end,
  },
}
