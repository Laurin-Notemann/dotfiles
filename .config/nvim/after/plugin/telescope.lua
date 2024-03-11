local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', function()
  builtin.find_files({
    find_command = {
      "rg",
      "--glob=!**/node_modules/**",
      "--glob=!**/.git/**",
      "--hidden",
      "--files",
    },
    no_ignore = true
  })
end, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
