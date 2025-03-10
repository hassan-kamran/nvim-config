-- File: plugins/diagnostic-helper.lua
return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				position = "bottom", -- position of the list: "bottom", "top", "left", "right"
				height = 10, -- height of the trouble list when position is "top" or "bottom"
				width = 50, -- width of the list when position is "left" or "right"
				icons = true, -- use devicons for filenames if available
				mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
				fold_open = "", -- icon used for open folds
				fold_closed = "", -- icon used for closed folds
				group = true, -- group results by file
				padding = true, -- add an extra new line on top and bottom
				action_keys = { -- key mappings for actions in the trouble list
					close = "q", -- close the list
					cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
					refresh = "r", -- manually refresh
					jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
					open_split = { "<c-x>" }, -- open buffer in new split
					open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
					open_tab = { "<c-t>" }, -- open buffer in new tab
					jump_close = { "o" }, -- jump to the diagnostic and close the list
					toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
					toggle_preview = "P", -- toggle auto_preview
					hover = "K", -- opens a small popup with the full multiline message
					preview = "p", -- preview the diagnostic location
					close_folds = { "zM", "zm" }, -- close all folds
					open_folds = { "zR", "zr" }, -- open all folds
					toggle_fold = { "zA", "za" }, -- toggle fold of current file
					previous = "k", -- previous item
					next = "j", -- next item
				},
				indent_lines = true, -- add an indent guide below the fold icons
				auto_open = false, -- automatically open the list when you have diagnostics
				auto_close = false, -- automatically close the list when you have no diagnostics
				auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
				auto_fold = false, -- automatically fold a file trouble list at creation
				auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
				signs = {
					-- icons / text used for a diagnostic
					error = "",
					warning = "",
					hint = "",
					information = "",
					other = "﫠",
				},
				use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
			})

			-- Key bindings to open trouble
			vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
			vim.keymap.set(
				"n",
				"<leader>xw",
				"<cmd>TroubleToggle workspace_diagnostics<cr>",
				{ silent = true, noremap = true }
			)
			vim.keymap.set(
				"n",
				"<leader>xd",
				"<cmd>TroubleToggle document_diagnostics<cr>",
				{ silent = true, noremap = true }
			)
			vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
			vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })

			-- Modify diagnostic display to show source
			vim.diagnostic.config({
				virtual_text = {
					source = "always", -- Show source in diagnostics
					prefix = "●", -- Symbol to use at beginning of diagnostics
				},
				float = {
					source = "always", -- Show source in floating window
					border = "rounded",
					header = "",
					prefix = "",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- Add command to display all diagnostics with sources
			vim.api.nvim_create_user_command("DiagnosticSources", function()
				local diagnostics = vim.diagnostic.get(0)
				local formatted = {}

				for _, diagnostic in ipairs(diagnostics) do
					local source = diagnostic.source or "unknown"
					local message = diagnostic.message
					local severity = vim.diagnostic.severity[diagnostic.severity]

					table.insert(formatted, string.format("[%s] %s: %s", severity, source, message))
				end

				-- Sort by severity
				table.sort(formatted)

				if #formatted > 0 then
					vim.notify(table.concat(formatted, "\n"), vim.log.levels.INFO, {
						title = "Diagnostics with Sources",
						timeout = 10000,
					})
				else
					vim.notify("No diagnostics found", vim.log.levels.INFO)
				end
			end, {})
		end,
	},
}
