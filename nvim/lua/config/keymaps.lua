-- Adapted from: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local Util = require("util")

-- better up/down
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
vim.keymap.set("n", "<A-j>", ":m .+1<cr>==", { desc = "Move down", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down", silent = true })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<cr>==gi", { desc = "Move down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<cr>==", { desc = "Move up", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up", silent = true })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<cr>==gi", { desc = "Move up", silent = true })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "b[", "<cmd>bprevious<cr>", { desc = "Previous" })
vim.keymap.set("n", "b]", "<cmd>bnext<cr>", { desc = "Next" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
vim.keymap.set(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- lazy
vim.keymap.set("n", "<leader>L", "<cmd>:Lazy<cr>", { desc = "Lazy" })

-- new file
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Open Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open Quickfix List" })

-- stylua: ignore start

-- toggle options
vim.keymap.set("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle Spelling" })
vim.keymap.set("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
vim.keymap.set("n", "<leader>ul", function() Util.toggle("relativenumber", true) Util.toggle("number") end, { desc = "Toggle Line Numbers" })
vim.keymap.set("n", "<leader>ud", Util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
vim.keymap.set("n", "<leader>uc", function() Util.toggle("conceallevel", false, {0, conceallevel}) end, { desc = "Toggle Conceal" })

-- quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous" })

-- Normal --
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "gp", "`[v`]", { desc = "Switch to VISUAL using the last changed or yanked text" })

-- Visual --
vim.keymap.set("x", "p", '"_dP', { desc = "Paste over selection (without yanking)" })
vim.keymap.set("n", "<A-l>", ">>", { desc = "Indent right" })
vim.keymap.set("x", "<A-l>", ">gv", { desc = "Indent right" })
vim.keymap.set("n", "<A-h>", "<<", { desc = "Indent left" })
vim.keymap.set("x", "<A-h>", "<gv", { desc = "Indent left" })

-- TODO: Add some bindings for doing diff stuff, e.g.:
-- :windo diffthis -- diff buffers in all windows
-- :windo diffoff -- turn off diffing for all windows
-- :diffoff! -- alternative version of above?
-- :windo diffupdate -- update diffs for all windows

-- :[range]diffget [buf] -- same as [count]do
-- :[range]diffput [buf] -- same as [count]dp

-- :vert diffsplit %~ -- diff current buffer with previous version
-- :vert diffpatch /path/to/patch -- diff current buffer with patch from file

-- Add a way to change the diff algorithm.
-- Currently supported algorithms are:
-- myers      the default algorithm
-- minimal    spend extra time to generate the smallest possible diff
-- patience   patience diff algorithm
-- histogram  histogram diff algorithm
-- vim.opt.diffopt:append(algorithm:{text})

-- Buffer management
vim.keymap.set("n", "<leader><cr>", "<cmd>update!<CR>", { desc = "Save, if changed" })
vim.keymap.set("n", "<leader>w", "<cmd>write!<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>W", "<cmd>noautocmd write!<CR>", { desc = "Save (no autocmd)" })
vim.keymap.set("n", "<leader>bw", "<leader>w", { remap = true, desc = "Save" })
vim.keymap.set("n", "<leader>bW", "<leader>W", { remap = true, desc = "Save (no autocmd)" })
vim.keymap.set("n", "<leader>bu", "<leader><cr>", { remap = true, desc = "Save, if changed" })
vim.keymap.set("n", "<leader>ba", "<cmd>wa!<CR>", { desc = "Write all buffers" })
vim.keymap.set("n", "<leader>bC", "<cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers" })
vim.keymap.set("n", "<leader>bs", function()
  local fname = vim.fn.input({ prompt = "Save as: ", default = vim.fn.bufname(), completion = "file" })
  if fname ~= "" then
    vim.cmd("<cmd>saveas! " .. fname)
  end
end, { desc = "Save current buffer as" })

vim.keymap.set("n", "<leader>b%", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>f%", "<cmd>source %<CR>", { desc = "Source current file" })

-- Mason
vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Mason" })


local function toggle_profile()
  if vim.v.profiling == 1 then
    vim.cmd [[ profile pause | profile dump | noautocmd qall! ]]
  else
    vim.cmd [[ profile start profile.log | profile func * | profile file * ]]
  end
end

vim.keymap.set({"n", "i"}, "<C-p>", toggle_profile, { desc = "Toggle profile" })
