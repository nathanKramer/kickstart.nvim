
local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function keymap_picker()
  local keymaps = {}

  -- Built-in fold and other common mappings that don't show up in keymap tables
  local builtin_mappings = {
    -- Fold mappings
    { mode = 'n', lhs = 'zf', desc = 'Create fold' },
    { mode = 'n', lhs = 'zF', desc = 'Create fold to end of file' },
    { mode = 'n', lhs = 'zd', desc = 'Delete fold under cursor' },
    { mode = 'n', lhs = 'zD', desc = 'Delete all folds under cursor' },
    { mode = 'n', lhs = 'zE', desc = 'Eliminate all folds' },
    { mode = 'n', lhs = 'zo', desc = 'Open fold under cursor' },
    { mode = 'n', lhs = 'zO', desc = 'Open all folds under cursor' },
    { mode = 'n', lhs = 'zc', desc = 'Close fold under cursor' },
    { mode = 'n', lhs = 'zC', desc = 'Close all folds under cursor' },
    { mode = 'n', lhs = 'za', desc = 'Toggle fold under cursor' },
    { mode = 'n', lhs = 'zA', desc = 'Toggle all folds under cursor' },
    { mode = 'n', lhs = 'zv', desc = 'Open just enough folds to view cursor' },
    { mode = 'n', lhs = 'zx', desc = 'Update folds' },
    { mode = 'n', lhs = 'zX', desc = 'Undo manually opened/closed folds' },
    { mode = 'n', lhs = 'zm', desc = 'Fold more' },
    { mode = 'n', lhs = 'zM', desc = 'Close all folds' },
    { mode = 'n', lhs = 'zr', desc = 'Fold less' },
    { mode = 'n', lhs = 'zR', desc = 'Open all folds' },
    { mode = 'n', lhs = 'zn', desc = 'Fold none' },
    { mode = 'n', lhs = 'zN', desc = 'Fold normal' },
    { mode = 'n', lhs = 'zi', desc = 'Invert foldenable' },
    { mode = 'n', lhs = 'zj', desc = 'Move to next fold' },
    { mode = 'n', lhs = 'zk', desc = 'Move to previous fold' },
  }

  for _, mapping in ipairs(builtin_mappings) do
    table.insert(keymaps, {
      mode = mapping.mode,
      lhs = mapping.lhs,
      rhs = mapping.lhs, -- For built-ins, rhs is same as lhs
      desc = mapping.desc,
      builtin = true
    })
  end

  -- Helper function to get actual keymaps
  local function get_keymaps_for_mode(mode, buf)
    local maps
    if buf then
      maps = vim.api.nvim_buf_get_keymap(buf, mode)
    else
      maps = vim.api.nvim_get_keymap(mode)
    end

    for _, map in ipairs(maps) do
      local desc = map.desc and map.desc ~= "" and map.desc or
                   (map.rhs and map.rhs ~= "" and ("-> " .. map.rhs) or "Custom mapping")

      table.insert(keymaps, {
        mode = mode,
        lhs = map.lhs,
        rhs = map.rhs,
        desc = desc,
        noremap = map.noremap,
        silent = map.silent,
        callback = map.callback,
        buffer = buf and true or false,
        builtin = false
      })
    end
  end

  local modes = {'n', 'v', 'i', 'x', 'o', 's', 'c', 't'}

  -- Get global keymaps
  for _, mode in ipairs(modes) do
    get_keymaps_for_mode(mode)
  end

  -- Get buffer-local keymaps for current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  for _, mode in ipairs(modes) do
    get_keymaps_for_mode(mode, current_buf)
  end

  -- Sort keymaps by mode, then description
  table.sort(keymaps, function(a, b)
    if a.mode == b.mode then
      return a.desc:lower() < b.desc:lower()
    else
      return a.mode < b.mode
    end
  end)

  pickers.new({}, {
    prompt_title = "Keymappings",
    finder = finders.new_table({
      results = keymaps,
      entry_maker = function(entry)
        local buffer_indicator = entry.buffer and "[buf] " or ""
        local builtin_indicator = entry.builtin and "[builtin] " or ""
        return {
          value = entry,
          display = string.format("%s%s[%s] %s - %s",
            buffer_indicator, builtin_indicator, entry.mode, entry.lhs, entry.desc),
          ordinal = entry.desc .. " " .. entry.lhs
        }
      end
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local keymap = selection.value

        if keymap.callback then
          keymap.callback()
        else
          local keys = vim.api.nvim_replace_termcodes(keymap.lhs, true, false, true)
          vim.api.nvim_feedkeys(keys, keymap.mode, false)
        end
      end)
      return true
    end
  }):find()
end

-- Create the keymap to open the picker
vim.keymap.set('n', '<C-S-P>', keymap_picker, { desc = 'Command Palette' })

