return {
  dir = "/home/nathankramer/Projects/nathanKramer/programming-language-2/luna/editor-support/nvim",
  name = "luna-syntax",
  ft = "luna",
  config = function()
    -- Optional: Luna-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "luna",
      callback = function()
        vim.opt_local.commentstring = "// %s"
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
      end,
    })
  end,
}
