vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "

-- Options
vim.opt.clipboard      = "unnamedplus"
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.undofile       = true
vim.opt.scrolloff      = 8
vim.opt.updatetime     = 50
vim.opt.swapfile       = false


-- transparent background
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)


local lazy_config = require("configs.lazy")

require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  {
    "nvim-svelte/nvim-svelte-snippets",
    dependencies = "L3MON4D3/LuaSnip",
    opts = {},
  },
{
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "vue", "xml" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod",                                                        lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon.mark").add_file() end },
      { "<C-e>",      function() require("harpoon.ui").toggle_quick_menu() end },
    },
  },
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        open_file = { quit_on_open = true,
        window_picker = {
          enable = false, -- disable the pick prompt when i open the files tree oon split screen
        }
      },

      },
      filters = {
        git_ignored = false
      }
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
  },
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- "xiyaowong/transparent.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-telescope/telescope.nvim",
}, lazy_config)

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require("options")
require("nvchad.autocmds")

-- Snippets
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.filetype_extend("blade", { "html" })
luasnip.filetype_extend("typescriptreact", { "html" })
luasnip.filetype_extend("javascriptreact", { "html" })

-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "svelte" },
})


-- Remove empty unnamed buffers automatically
vim.api.nvim_create_autocmd("BufLeave", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(buf) == "" and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end,
})


-- nvim-cmp
local cmp = require("cmp")
cmp.setup({
  formatting = {
    format = require("tailwindcss-colorizer-cmp").formatter,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
    ["<Tab>"]     = cmp.mapping.select_next_item(),
    ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Treesitter
require("nvim-treesitter.config").setup({
  ensure_installed = { "php", "blade", "html", "css", "javascript", "svelte", "typescript", "tsx", "json" },
  highlight = { enable = true },
})

-- Filetypes
vim.filetype.add({
  extension = { blade = "blade", prisma = "prisma" },
  pattern = { [".*%.blade%.php"] = "blade" },
})

-- Format on save (BufWritePre handles all formatting automatically)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.svelte", "*.ts", "*.tsx", "*.js", "*.jsx", "*.php" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- require("transparent").setup({
-- })

-- Keymaps
vim.schedule(function()
  require("mappings")

  -- Window navigation
  pcall(vim.keymap.del, "n", "<leader>h")
  vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
  vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
  vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
  vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })

  -- Terminals
  vim.keymap.set("n", "<leader>t", function()
    require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
  end, { desc = "Toggle split terminal" })

  vim.keymap.set("n", "<leader>i", function()
    require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
  end, { desc = "Toggle floating terminal" })

  -- Escape exits terminal insert mode
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

  -- Splits
  vim.keymap.set("n", "<leader>s", "<cmd>vsplit<CR>", { desc = "Vertical split" })

  -- Close buffer / close split
  vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>",    { desc = "Close buffer" })
  vim.keymap.set("n", "<leader>q", "<cmd>close<CR>", { desc = "Close split" })

  -- Files
  vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",       { desc = "File tree" })

  -- Save (formatting handled by BufWritePre above, no double format)
  vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })

  -- Undo / Redo
  vim.keymap.set("n", "u",     "u",     { desc = "Undo" })
  vim.keymap.set("n", "<S-u>", "<C-r>", { desc = "Redo" })

  -- Move lines up/down (normal mode)
  vim.keymap.set("n", "<S-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
  vim.keymap.set("n", "<S-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })

  -- Move lines up/down (visual mode)
  vim.keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  vim.keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
end)

