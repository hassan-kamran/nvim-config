-- File: plugins/linting.lua
return {
	-- nvim-lint for running Ruff as a linter (separate from formatting)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile", "BufWritePre" },
		config = function()
			local lint = require("lint")

			-- Make sure linter's diagnostic source is clearly labeled
			lint.linters.ruff.name = "ruff"

			-- Configure linters for different filetypes
			lint.linters_by_ft = {
				python = { "ruff" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
			}

			-- Set up autocommand to run linter on file changes
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					local ft = vim.bo.filetype
					if ft and ft ~= "" then
						lint.try_lint()
					end
				end,
			})

			-- Key mapping to manually trigger linting
			vim.keymap.set("n", "<leader>ll", function()
				lint.try_lint()
				vim.notify("Linting complete - check for warnings/errors", vim.log.levels.INFO)
			end, { desc = "Lint current file" })

			-- Debug command to check if ruff is installed
			vim.api.nvim_create_user_command("RuffCheck", function()
				local ruff_path = vim.fn.exepath("ruff")
				if ruff_path and ruff_path ~= "" then
					vim.notify("Ruff found at: " .. ruff_path, vim.log.levels.INFO)
					-- Try to run ruff version
					local output = vim.fn.system("ruff --version")
					vim.notify("Ruff version: " .. output, vim.log.levels.INFO)
				else
					vim.notify("Ruff executable not found in PATH", vim.log.levels.ERROR)
				end
			end, {})
		end,
	},
}
