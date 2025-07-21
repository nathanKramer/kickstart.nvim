
local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function keymap_picker()
  -- Get all keymappings
  local keymaps = {}

  -- Helper function to get keymaps for a specific mode
  local function get_keymaps_for_mode(mode)
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      if map.desc and map.desc ~= "" then
        table.insert(keymaps, {
          mode = mode,
          lhs = map.lhs,
          rhs = map.rhs,
          desc = map.desc,
          noremap = map.noremap,
          silent = map.silent,
          callback = map.callback
        })
      end
    end
  end

  -- Get keymaps for different modes
  get_keymaps_for_mode('n') -- normal mode
  get_keymaps_for_mode('v') -- visual mode
  get_keymaps_for_mode('i') -- insert mode
  get_keymaps_for_mode('x') -- visual block mode

  pickers.new({}, {
    prompt_title = "Keymappings",
    finder = finders.new_table({
      results = keymaps,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("[%s] %s - %s", entry.mode, entry.lhs, entry.desc),
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

        -- Execute the keymap
        if keymap.callback then
          keymap.callback()
        else
          -- Use feedkeys to simulate the keypress
          local keys = vim.api.nvim_replace_termcodes(keymap.lhs, true, false, true)
          vim.api.nvim_feedkeys(keys, 'n', false)
        end
      end)
      return true
    end
  }):find()
end

-- Create the keymap to open the picker
vim.keymap.set('n', '<C-S-P>', keymap_picker, { desc = 'Find and execute keymappings' })

