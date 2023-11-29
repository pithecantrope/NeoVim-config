local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Theme
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local kanagawa = require("kanagawa")
            kanagawa.setup({
                compile = true, -- :KanagawaCompile
            })
            kanagawa.load("wave")
        end,
    },
    -- Lua library
    { "nvim-lua/plenary.nvim", lazy = true },
    -- Blazingly fast file navigation
    {
        "ThePrimeagen/harpoon",
        ---@type function
        keys = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            return {
                { "<C-e>", mark.add_file, desc = "Add file to menu" },
                { "<C-m>", ui.toggle_quick_menu, desc = "Toggle menu" },
                { "<C-t>", function() ui.nav_file(1) end, desc = "Go to 1st file" },
                { "<C-g>", function() ui.nav_file(2) end, desc = "Go to 2nd file" },
                { "<C-h>", function() ui.nav_file(3) end, desc = "Go to 3rd file" },
                { "<C-y>", function() ui.nav_file(4) end, desc = "Go to 4th file" },
            }
        end,
    },
    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        ---@type function
        keys = function()
            local builtin = require("telescope.builtin")
            return {
                { "<leader>ff", builtin.find_files, desc = "Find files by name" },
                { "<leader>fg", builtin.live_grep, desc = "Find files by content" },
                { "<leader>fh", builtin.help_tags, desc = "Find nvim help" },
                { "<leader>fk", builtin.keymaps, desc = "Find keymappings" },
            }
        end,
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        config = function() require("telescope").load_extension("fzf") end,
    },
    -- Icons
    { "nvim-tree/nvim-web-devicons", lazy = true },
    -- Status line
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", opts = {} },
    -- Auto pairs
    {
        "altermo/ultimate-autopair.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
        branch = "v0.6",
        opts = {},
    },
    -- Almighty syntax, context and new text objects
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            {
                "nvim-treesitter/nvim-treesitter-context",
                opts = {
                    mode = "cursor",
                    max_lines = 3,
                },
            },
        },
        opts = {
            auto_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "toml",
                "json",
                "yaml",
                "query",
                "sql",
                "vim",
                "vimdoc",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "python",
                "regex",
                "c",
                "make",
                "doxygen",
                "cpp",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
                    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                    goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
                },
                select = {
                    enable = true,
                    lookahead = true,
                    include_surrounding_whitespace = true,
                    keymaps = {
                        ["ao"] = "@class.outer",
                        ["io"] = "@class.inner",
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@call.outer",
                        ["ic"] = "@call.inner",
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>a"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>A"] = "@parameter.inner",
                    },
                },
            },
        },
        config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
    },
    -- Language Server Protocol support
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = {
                    ui = {
                        border = "rounded",
                        width = 0.5,
                    },
                },
            },
            {
                "williamboman/mason-lspconfig.nvim",
                opts = {
                    ensure_installed = {
                        "lua_ls",
                        "pyright",
                        "clangd",
                    },
                },
            },
            { "folke/neodev.nvim", opts = {} },
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lsp = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            lsp.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            })
            lsp.pyright.setup({ capabilities = capabilities })
            lsp.clangd.setup({ capabilities = capabilities })

            vim.keymap.set(
                "n",
                "<leader>M",
                vim.diagnostic.open_float,
                { desc = "Show more diagnostic info in a floating window" }
            )
            vim.keymap.set("n", "<leader>ld", vim.diagnostic.setloclist, { desc = "Open diagnostics in location list" })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    vim.keymap.set(
                        "n",
                        "<leader>R",
                        vim.lsp.buf.rename,
                        { buffer = ev.buf, desc = "Rename all references to the word" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>C",
                        vim.lsp.buf.code_action,
                        { buffer = ev.buf, desc = "Pick a code action" }
                    )
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, {
                        buffer = ev.buf,
                        desc = "Display hover information about the word",
                    })
                    vim.keymap.set("n", "<leader>K", vim.lsp.buf.signature_help, {
                        buffer = ev.buf,
                        desc = "Display signature information about the word",
                    })
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {
                        buffer = ev.buf,
                        desc = "Jump to the declaration of the word",
                    })
                    vim.keymap.set(
                        "n",
                        "gd",
                        vim.lsp.buf.definition,
                        { buffer = ev.buf, desc = "Jump to the definition of the word" }
                    )
                    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, {
                        buffer = ev.buf,
                        desc = "Jump to the definition of the type of the word",
                    })
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {
                        buffer = ev.buf,
                        desc = "List implementations for the word in the quickfix window",
                    })
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, {
                        buffer = ev.buf,
                        desc = "List references to the word in the quickfix window",
                    })
                end,
            })

            vim.fn.sign_define("DiagnosticSignError", {
                text = "",
                texthl = "DiagnosticSignError",
                numhl = "DiagnosticSignError",
            })
            vim.fn.sign_define("DiagnosticSignWarn", {
                text = "",
                texthl = "DiagnosticSignWarn",
                numhl = "DiagnosticSignWarn",
            })
            vim.fn.sign_define("DiagnosticSignHint", {
                text = "",
                texthl = "DiagnosticSignHint",
                numhl = "DiagnosticSignHint",
            })
            vim.fn.sign_define("DiagnosticSignInfo", {
                text = "",
                texthl = "DiagnosticSignInfo",
                numhl = "DiagnosticSignInfo",
            })
        end,
    },
    -- Powerful completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            -- AI
            {
                "Exafunction/codeium.nvim",
                commit = "822e762", -- HACK:The last one doesn't seem to work.
                opts = {},
            },
            -- Pictograms
            "onsails/lspkind.nvim",
        },
        opts = function()
            local cmp = require("cmp")

            return {
                snippet = {
                    expand = function(args) require("luasnip").lsp_expand(args.body) end,
                },
                window = {
                    completion = {
                        border = "rounded",
                        winhighlight = "NormalFloat:FloatBorder,CursorLine:Visual,Search:None",
                        col_offset = -3,
                        side_padding = 1,
                        scrollbar = false,
                    },
                    documentation = {
                        border = "rounded",
                        scrollbar = false,
                        winhighlight = "NormalFloat:FloatBorder,CursorLine:Visual,Search:None",
                    },
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                mapping = {
                    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = require("lspkind").cmp_format({
                        mode = "symbol",
                        maxwidth = 40,
                        ellipsis_char = "...",
                        symbol_map = {
                            Codeium = "",
                            Module = "",
                            Operator = "",
                            Property = "",
                            TypeParameter = "T",
                        },
                    }),
                },
                sources = cmp.config.sources({
                    { name = "codeium" },
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }),
            }
        end,
    },
    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        lazy = true,
        dependencies = {
            "rafamadriz/friendly-snippets",
            config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
        },
        config = function()
            local ls = require("luasnip")
            vim.keymap.set({ "i" }, "<C-l>", function() ls.expand() end, { silent = true, desc = "Expand snippet" })
            vim.keymap.set(
                { "i", "s" },
                "<C-j>",
                function() ls.jump(1) end,
                { silent = true, desc = "Jump forward snippet" }
            )
            vim.keymap.set(
                { "i", "s" },
                "<C-k>",
                function() ls.jump(-1) end,
                { silent = true, desc = "Jump backward snippet" }
            )
        end,
    },
    -- Commenting
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gc", mode = { "n", "x" }, desc = "Line-comment toggle" },
            { "gb", mode = { "n", "x" }, desc = "Block-comment toggle" },
            { "gcc", desc = "Line-comment toggle line" },
            { "gbc", desc = "Block-comment toggle line" },
            { "gcO", desc = "Add comment on the line above" },
            { "gco", desc = "Add comment on the line below" },
            { "gcA", desc = "Add comment at the end of line" },
        },
        opts = {},
    },
    -- Better comments
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
        config = function(_, opts)
            local todo = require("todo-comments")
            todo.setup(opts)
            vim.keymap.set("n", "<leader>lt", "<cmd>TodoLocList<CR>", { desc = "Open todos in location list" })
        end,
    },
    -- Format runner
    {
        {
            "stevearc/conform.nvim",
            event = "BufWritePre",
            opts = {
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "black" },
                    c = { "clangformat" },
                    cpp = { "clangformat" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            },
        },
    },
    -- Annotation generator
    {
        "danymat/neogen",
        keys = {
            { "ga", "<cmd>Neogen<CR>", desc = "Generate annotation" },
        },
        opts = {
            snippet_engine = "luasnip",
        },
    },
    -- Navigation
    {
        "stevearc/aerial.nvim",
        opts = {},
        keys = {
            { "<leader>N", "<cmd>AerialOpen<cr>", desc = "Open navigation" },
        },
    },
})
