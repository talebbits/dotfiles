return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "simrat39/rust-tools.nvim",
      "folke/neodev.nvim",
      "folke/neoconf.nvim",
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local rt = require("rust-tools")

      require("mason-lspconfig").setup({ automatic_installation = true })

      require("neoconf").setup({})
      require("neodev").setup({})

      local servers = {
        sumneko_lua = {
          settings = {
            Lua = {
              telemetery = {
                enabled = false,
              },
            },
          },
        },
        tsserver = {
          -- Only activate tsserver if the project has config for it.
          root_dir = lspconfig.util.root_pattern("tsconfig.json", "jsconfig.json"),
        },
        flow = {
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "flowtype", "flowtypereact" },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        "eslint",
        "html",
        "cssls",
        "pyright",
        "bashls",
        "yamlls",
      }

      local util = vim.lsp.util

      local function get_formatted_diagnostics()
        local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
        lnum = lnum - 1
        -- LSP servers can send diagnostics with `end_col` past the length of the line
        local line_length = #vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, true)[1]
        local diagnostics = vim.tbl_filter(function(d)
          return d.lnum == lnum and math.min(d.col, line_length - 1) <= col and (d.end_col >= col or d.end_lnum > lnum)
        end, vim.diagnostic.get(0, { lnum = lnum }))

        local lines = {}
        local highlights = {}
        -- TODO: Add grouping by source and severity.
        if not vim.tbl_isempty(diagnostics) then
          for i, diagnostic in ipairs(diagnostics) do
            local prefix = string.format("%s[%s]: ", diagnostic.source, diagnostic.code)
            local severity = vim.diagnostic.severity[diagnostic.severity]
            local highlight = "Diagnostic" .. severity:sub(1, 1) .. severity:sub(2):lower()
            -- TODO: Decide how to highlight prefix.
            local prefix_highlight = highlight
            local message_lines = vim.split(diagnostic.message, "\n")
            table.insert(lines, prefix .. message_lines[1])
            table.insert(highlights, { #prefix, highlight, prefix_highlight })
            for j = 2, #message_lines do
              table.insert(lines, string.rep(" ", #prefix) .. message_lines[j])
              table.insert(highlights, { 0, highlight })
            end
          end
        end
        return lines, highlights
      end

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(function(_, result, ctx, opts)
        local lines, highlights = get_formatted_diagnostics()

        if result and result.contents then
          if not vim.tbl_isempty(lines) then
            table.insert(lines, "---")
          end
          vim.list_extend(lines, util.convert_input_to_markdown_lines(result.contents, {}))
        end

        lines = util.trim_empty_lines(lines)

        if vim.tbl_isempty(lines) then
          return
        end

        local float_opts = vim.tbl_extend("keep", opts, {
          border = "rounded",
          focusable = true,
          focus_id = "hover",
          close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
        })

        local bufnr, winnr = util.open_floating_preview(lines, "markdown", float_opts)

        for i, hi in ipairs(highlights) do
          local prefixlen, hiname, prefix_hiname = unpack(hi)
          if prefix_hiname then
            vim.api.nvim_buf_add_highlight(bufnr, -1, prefix_hiname, i - 1, 0, prefixlen)
          end
          vim.api.nvim_buf_add_highlight(bufnr, -1, hiname, i - 1, prefixlen, -1)
        end
      end, {})

      -- Format the given buffer using any registered LSP formatter.
      ---@param bufnr? number
      local function format(bufnr)
        if type(bufnr) == "table" then
          bufnr = bufnr.args or nil
        end
        if type(bufnr) == "string" then
          local ok, result = pcall(tonumber, bufnr)
          bufnr = ok and result or nil
        end
        vim.lsp.buf.format({ timeout_ms = 5000, bufnr = vim.F.if_nil(bufnr, 0) })
      end

      local function lsp_keymaps(_, bufnr)
        local keymap = require("config.keymap").buffer(bufnr)
        keymap.normal.leader({

          ["."] = { vim.lsp.buf.code_action, "Show code actions" },
          ["="] = { format, "Format document" },
          R = { vim.lsp.buf.rename, "Rename" },
          l = {
            name = "LSP",
            f = { format, "Format document" },
            a = { vim.lsp.buf.code_action, "Show code actions" },
            h = { vim.lsp.buf.hover, "Show hover" },
            r = { vim.lsp.buf.rename, "Rename" },
            s = { vim.lsp.buf.signature_help, "Show signature help" },
            S = { ":LspInfo<CR>", "Show LSP status" },
            I = { ":LspInstallInfo<CR>", "Show LSP install info" },
          },
        })

        keymap.normal("K", vim.lsp.buf.hover, "Show hover")

        keymap.normal.register({
          gd = { ":TroubleToggle lsp_definitions<CR>", "Go to definition" },
          gr = { ":TroubleToggle lsp_references<CR>", "Find references" },
          gt = { ":TroubleToggle lsp_type_definitions<CR>", "Go to type" },
          gI = { ":TroubleToggle lsp_implementations<CR>", "Go to implementation" },
        })
      end

      vim.api.nvim_create_user_command("Format", format, { nargs = 0, desc = "Format the current buffer" })

      local LSP_FORMATTING = vim.api.nvim_create_augroup("LspFormatting", {})

      local function lsp_formatting(_, bufnr)
        vim.api.nvim_clear_autocmds({ group = LSP_FORMATTING, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", { group = LSP_FORMATTING, buffer = bufnr, callback = format })
      end

      local function lsp_location(client, bufnr)
        local _, navic = pcall(require, "nvim-navic")
        if navic and client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      local function on_attach(client, bufnr)
        if client.name == "copilot" then
          return
        end
        lsp_location(client, bufnr)
        lsp_formatting(client, bufnr)
        lsp_keymaps(client, bufnr)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local default_opts = { on_attach = on_attach, capabilities = capabilities }

      for server, opts in pairs(servers) do
        if type(server) == "number" then
          server = opts
          opts = {}
        end

        lspconfig[server].setup(vim.tbl_deep_extend("error", default_opts, opts))
      end

      -- Rust tools setup
      rt.setup({
        server = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            -- Hover actions
            vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
          end,
          checkOnSave = {
            allFeatures = true,
            overrideCommand = {
              "cargo",
              "clippy",
              "--workspace",
              "--message-format=json",
              "--all-targets",
              "--all-features",
            },
          },
        },
      })
    end,
  },

  -- Linting
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPost",
    dependencies = { "jayp0521/mason-null-ls.nvim" },
    config = function()
      local null_ls = require("null-ls")

      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
      local code_actions = null_ls.builtins.code_actions
      local completion = null_ls.builtins.completion
      local diagnostics = null_ls.builtins.diagnostics
      local formatting = null_ls.builtins.formatting
      local hover = null_ls.builtins.hover

      null_ls.setup({
        debug = false,
        sources = {
          formatting.prettierd.with({
            extra_filetypes = { "toml", "flowtype", "flowtypereact" },
          }),
          formatting.black.with({ extrargs = { "fast" } }),
          formatting.stylua,
          formatting.google_java_format,
          diagnostics.flake8,
          code_actions.gitsigns,
          code_actions.gitrebase,
          completion.spell,
          hover.dictionary,
        },
      })

      require("mason-null-ls").setup({
        automatic_installation = true,
      })
    end,
  },
}
