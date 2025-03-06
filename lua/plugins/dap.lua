-- File: plugins/debug.lua
return {
  -- Core DAP (Debug Adapter Protocol) plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- nvim-nio is required for nvim-dap-ui
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require('dap')
      
      -- Configure Python adapter
      dap.adapters.python = {
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
      }
      
      -- Configure Python configurations
      dap.configurations.python = {
        {
          -- The first configuration will be the default one used
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = "${file}", -- This will use the file you're editing
          pythonPath = function()
            -- Use the Python from your environment
            local venv_path = os.getenv('VIRTUAL_ENV')
            if venv_path then
              return venv_path .. '/bin/python'
            else
              return '/usr/bin/python3' -- Fallback to system Python
            end
          end,
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch with arguments',
          program = "${file}",
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
          pythonPath = function()
            local venv_path = os.getenv('VIRTUAL_ENV')
            if venv_path then
              return venv_path .. '/bin/python'
            else
              return '/usr/bin/python3'
            end
          end,
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach remote',
          connect = function()
            local host = vim.fn.input('Host [127.0.0.1]: ')
            host = host ~= "" and host or "127.0.0.1"
            local port = tonumber(vim.fn.input('Port [5678]: '))
            port = port ~= "" and port or 5678
            return { host = host, port = port }
          end,
        },
      }
      
      -- Define signs for breakpoints
      vim.fn.sign_define('DapBreakpoint', {text='●', texthl='DiagnosticSignError', linehl='', numhl=''})
      vim.fn.sign_define('DapBreakpointCondition', {text='◆', texthl='DiagnosticSignError', linehl='', numhl=''})
      vim.fn.sign_define('DapLogPoint', {text='◆', texthl='DiagnosticSignInfo', linehl='', numhl=''})
      vim.fn.sign_define('DapStopped', {text='▶', texthl='DiagnosticSignWarn', linehl='DapStopped', numhl='DapStopped'})
      vim.fn.sign_define('DapBreakpointRejected', {text='●', texthl='DiagnosticSignHint', linehl='', numhl=''})
      
      -- Key mappings for debugging
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>dl', function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end, { desc = 'Debug: Set Log Point' })
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
      vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'Debug: Terminate' })
    end,
  },
  
  -- DAP UI components
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      
      -- Configure DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position.
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = "rounded", -- Border style. Can be "single", "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
        }
      })
      
      -- Automatically open and close dapui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      
      -- Toggle DAP UI
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
    end,
  },
  
  -- Python-specific DAP extensions
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require('dap-python').setup(path)
      
      -- Test mappings
      vim.keymap.set('n', '<leader>dtm', function()
        require('dap-python').test_method()
      end, { desc = 'Debug: Test Method' })
      
      vim.keymap.set('n', '<leader>dtc', function()
        require('dap-python').test_class()
      end, { desc = 'Debug: Test Class' })
      
      vim.keymap.set('n', '<leader>dts', function()
        require('dap-python').debug_selection()
      end, { desc = 'Debug: Debug Selection' })
    end,
  },
  
  -- Visual debugging experience enhancements
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,                     -- enable this plugin
        enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle
        highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged
        highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables
        show_stop_reason = true,            -- show stop reason when stopped for exceptions
        commented = false,                  -- prefix virtual text with comment string
        only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
        all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
        --- A callback that determines how a variable is displayed or whether it should be displayed at all
        --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
        --- @param buf number
        --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
        --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
        --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
        --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        
        -- experimental features:
        all_frames = false,                 -- show virtual text for all stack frames not only current
        virt_lines = false,                 -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil             -- position the virtual text at a fixed window column (starting from the first text column) ,
                                           -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
      })
    end,
  },
  
  -- Telescope integration for DAP
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('telescope').load_extension('dap')
      
      -- Telescope DAP commands
      vim.keymap.set('n', '<leader>dcc', function() require('telescope').extensions.dap.commands({}) end, { desc = 'Debug: Commands' })
      vim.keymap.set('n', '<leader>dco', function() require('telescope').extensions.dap.configurations({}) end, { desc = 'Debug: Configurations' })
      vim.keymap.set('n', '<leader>dlb', function() require('telescope').extensions.dap.list_breakpoints({}) end, { desc = 'Debug: List Breakpoints' })
      vim.keymap.set('n', '<leader>dv', function() require('telescope').extensions.dap.variables({}) end, { desc = 'Debug: Variables' })
      vim.keymap.set('n', '<leader>df', function() require('telescope').extensions.dap.frames({}) end, { desc = 'Debug: Frames' })
    end,
  },
  
  -- Ensure that debugpy is installed
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "debugpy",  -- Python debugger
      },
      auto_update = true,
    },
  },
}
