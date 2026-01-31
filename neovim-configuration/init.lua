-- ~/.config/nvim/init.lua

--------------------------------------------------------------------------------
-- 0. Lazy.nvim Bootstrap (REQUIRED FOR PLUGIN MANAGEMENT)
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- 1. Global Options and Basic Settings
--------------------------------------------------------------------------------
vim.g.mapleader = " " -- Set leader key to space

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.scrolloff = 8         -- Lines of context around cursor
vim.opt.wrap = false          -- Disable line wrapping
vim.opt.tabstop = 4           -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4        -- Number of spaces for indent operations
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.incsearch = true      -- Live search
vim.opt.ignorecase = true     -- Ignore case in searches
vim.opt.smartcase = true      -- Smart case search (case-sensitive if uppercase is used)
vim.opt.termguicolors = true  -- Enable true color support
vim.opt.undofile = true       -- Persistent undo
vim.opt.updatetime = 300      -- Faster completion popups
vim.opt.signcolumn = "yes"    -- Always show the sign column


--------------------------------------------------------------------------------
-- 2. Plugin Definitions (via Lazy.nvim)
--------------------------------------------------------------------------------
require("lazy").setup({
    -- Theme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*", -- recommended for stability
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true, -- Show dotfiles
                },
            })
            -- Map <leader>e to toggle NvimTree
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
        end,
    },

    -- Tree-sitter for advanced syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate", -- Command to run after installation to download parsers
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "bash", "c", "cpp", "go", "lua", "json", "yaml", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
                autotag = { enable = true }, -- For HTML/XML
            })
            -- Optional: Add keymap for TSUpdate to manually update parsers
            vim.keymap.set("n", "<leader>tu", ":TSUpdate<CR>", { desc = "Update Treesitter Parsers" })
        end,
    },
    
    -- Status Line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- For icons in status line
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "catppuccin", -- Use the Catppuccin theme for Lualine
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" }, -- Diagnostics will show up if LSP is added later
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Git Integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "󰍵" },
                    topdelete = { text = "󰍵" },
                    changedelete = { text = "▎" },
                },
                on_attach = function(bufnr)
                    local gs = require("gitsigns")
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                    end
                    map("n", "]h", function() gs.next_hunk() end, "Next Git hunk")
                    map("n", "[h", function() gs.prev_hunk() end, "Previous Git hunk")
                    map({ "n", "v" }, "<leader>ghs", ":GitsignsStageHunk<CR>", "Stage Git hunk")
                    map({ "n", "v" }, "<leader>ghr", ":GitsignsResetHunk<CR>", "Reset Git hunk")
                    map("n", "<leader>gp", gs.preview_hunk, "Preview Git hunk")
                    map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Git blame line")
                    map("n", "<leader>gbr", ":GitsignsBlameToggle<CR>", "Toggle Git blame")
                    map("n", "<leader>gbl", ":GitsignsToggleLineBlame<CR>", "Toggle Git line blame")
                end,
            })
        end,
    },

    -- Commenting
    {
        "numToStr/Comment.nvim",
        opts = {}, -- Use default options
        lazy = false,
    },

    -- Auto-resize splits
    {
        "nvim-tree/nvim-tree.lua", -- A dependency of NvimTree, can reuse if already listed
        name = "winresizer", -- give it a distinct name if reusing to avoid confusion
        config = function()
            vim.api.nvim_create_autocmd("VimResized", {
                group = vim.api.nvim_create_augroup("AutoResizeSplits", { clear = true }),
                command = "wincmd =",
                desc = "Resize windows proportionally on VimResize",
            })
        end,
    },

    -- Remove trailing whitespace on save
    {
        "nvim-tree/nvim-tree.lua", -- Another dependency reuse placeholder
        name = "trailing_whitespace_autocmd", -- Distinct name
        config = function()
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("NoTrailingWhitespace", { clear = true }),
                pattern = { "*.py", "*.sh", "*.lua", "*.md", "*.txt", "*.c", "*.cpp", "*.go" },
                command = [[%s/\s\+$//e]],
                desc = "Remove trailing whitespace before saving",
            })
        end,
    },

    -- Auto create directories for new files
    {
        "nvim-tree/nvim-tree.lua", -- Another dependency reuse placeholder
        name = "auto_create_dir_autocmd", -- Distinct name
        config = function()
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("AutoCreateDir", { clear = true }),
                callback = function(args)
                    local dir = vim.fn.fnamemodify(args.file, ":h")
                    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
                        vim.fn.mkdir(dir, "p")
                    end
                end,
            })
        end,
    },

}, {}) -- End of lazy.nvim setup call and empty config table
