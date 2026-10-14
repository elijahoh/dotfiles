-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>til", function()
  -- 1. Prevent execution on non-editable buffers (e.g., Neo-tree, Dashboard)
  if not vim.bo.modifiable then
    vim.notify("Current buffer is not modifiable. Switch to a `.md` file first.", vim.log.levels.WARN)
    return
  end

  local template_path = vim.fn.expand("~/obsidianvault/templates/til-template.md")

  -- 2. Verify template existence
  if vim.fn.filereadable(template_path) == 0 then
    vim.notify("Template not found at: " .. template_path, vim.log.levels.ERROR)
    return
  end

  -- 3. Read template into buffer (handles spaces in path if any exist)
  vim.cmd("0read " .. vim.fn.fnameescape(template_path))

  -- 4. Auto-replace pubDate with today's date (YYYY-MM-DD)
  local today = os.date("%Y-%m-%d")
  vim.cmd("%s/pubDate: .*/pubDate: " .. today .. "/g")
end, { desc = "Insert TIL Template" })

-- Automated TIL Creator (<leader>tn)
vim.keymap.set("n", "<leader>tn", function()
  vim.ui.input({ prompt = "New TIL Title: " }, function(title)
    if not title or title == "" then
      return
    end

    -- 1. Convert title to lowercase slug (e.g., "K8s Ingress Fix" -> "k8s-ingress-fix.md")
    local slug = title:lower():gsub("[%s_]+", "-"):gsub("[^%w%-]", "")
    local dir_path = vim.fn.expand("~/projects/exclamation.dev/src/content/til/")
    local file_path = dir_path .. slug .. ".md"

    -- 2. Open the new file in current buffer
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))

    -- 3. Read template and populate YAML metadata
    local template_path = vim.fn.expand("~/obsidianvault/templates/til-template.md")
    if vim.fn.filereadable(template_path) == 1 then
      vim.cmd("0read " .. vim.fn.fnameescape(template_path))

      local today = os.date("%Y-%m-%d")
      vim.cmd("%s/pubDate: .*/pubDate: " .. today .. "/g")
      vim.cmd('%s/title: .*/title: "TIL: ' .. title:gsub("/", "\\/") .. '"/g')

      -- Move cursor to line 12 (body content)
      vim.api.nvim_win_set_cursor(0, { 12, 0 })
    else
      vim.notify("Template missing at: " .. template_path, vim.log.levels.ERROR)
    end
  end)
end, { desc = "Create New TIL Note" })
