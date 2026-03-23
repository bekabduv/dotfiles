return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- The '*' means these keymaps apply globally to ALL LSP servers (like Pyright)
        ["*"] = {
          keys = {
            -- Disable the <C-k> signature help mapping in insert mode
            { "<c-k>", false, mode = "i" },

            -- Optional: If you still want signature help, map it to <C-j> instead
            { "<c-j>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
          },
        },
      },
    },
  },
}
