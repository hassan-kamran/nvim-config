-- File: plugins/mason.lua
return {
	-- Mason for managing external tools
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
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
				ensure_installed = { "pyright", "eslint" },
				automatic_installation = true,
			})
		end,
	},

	-- Mason-tool-installer for ensuring tools are installed
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Language servers
					"pyright",

					-- Linters and formatters
					"ruff",
					"prettier",
					"eslint_d", -- This is the daemon version which is faster
					"stylua", -- Added stylua for Lua formatting
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},

	-- Conform for formatting with Ruff and Prettier
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "ruff_format" },
					-- Web development formats
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					scss = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					-- Lua formatting
					lua = { "stylua" },
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000, -- Increased timeout
				},
				-- Log level for debugging
				log_level = vim.log.levels.ERROR,
			})

			-- Key mapping for manual formatting
			vim.keymap.set({ "n", "v" }, "<leader>f", function()
				require("conform").format({ async = true })
			end, { desc = "Format current buffer or selection" })
		end,
	},
}
