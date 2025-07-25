local M = {}

local term_buf = nil
local term_win = nil

local function create_floating_window()
  local proportion = 0.8
  local width = math.floor(vim.o.columns * proportion)
  local height = math.floor(vim.o.lines * proportion)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  }

  return vim.api.nvim_open_win(0, true, opts)
end

function M.close_terminal_if_open()
  local is_open = term_win and vim.api.nvim_win_is_valid(term_win)
  if is_open then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end

  return is_open
end

function M.toggle_terminal()
  -- If terminal is already open, close it
  if M.close_terminal_if_open() then
    return
  end

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  -- Create floating window and set terminal buffer
  term_win = create_floating_window()
  vim.api.nvim_win_set_buf(term_win, term_buf)

  if vim.bo[term_buf].buftype ~= 'terminal' then
    vim.cmd('terminal')
    term_buf = vim.api.nvim_get_current_buf()
  end

  vim.cmd('startinsert')

  -- Set local keymaps for the terminal
  vim.keymap.set('t', '<C-j>', function()
    M.toggle_terminal()
  end, { buffer = term_buf, desc = 'Toggle terminal' })

  vim.keymap.set('t', '<Esc>', function()
    M.close_terminal_if_open()
  end, { buffer = term_buf, desc = 'Close terminal' })
end

-- Set up the keymap
vim.keymap.set('n', '<C-j>', M.toggle_terminal, { desc = 'Toggle floating terminal' })

-- Optional: Set up terminal-specific settings
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    -- Disable line numbers in terminal
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

return M








