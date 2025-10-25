local work_dir = vim.loop.os_homedir() .. "/work/nvim"
pcall(dofile, work_dir .. "/config.lua")

