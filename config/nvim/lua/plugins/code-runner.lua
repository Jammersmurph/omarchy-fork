return {
  {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
    keys = {
      { "<leader>rr", "<cmd>RunCode<CR>", desc = "Run code" },
      { "<leader>rf", "<cmd>RunFile<CR>", desc = "Run file" },
      { "<leader>rp", "<cmd>RunProject<CR>", desc = "Run project" },
      { "<leader>rc", "<cmd>RunClose<CR>", desc = "Close runner" },
    },
    opts = {
      mode = "float",
    },
  },
}
