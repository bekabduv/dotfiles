return {
  {
    "justinhj/battery.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {
      update_rate_seconds = 30,
      show_status_when_no_battery = true,
      show_plugged_icon = true,
      show_unplugged_icon = true,
      show_percent = true,
      vertical_icons = true,
      multiple_battery_selection = 1,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_z, 1, {
        function()
          return require("battery").get_status_line()
        end,
      })
    end,
  },
}
