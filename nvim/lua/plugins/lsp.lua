return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configuration for standard Pyright
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportAttributeAccessIssue = "none",
                },
              },
            },
          },
        },
        -- Configuration for Basedpyright (in case your LazyVim switched)
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportAttributeAccessIssue = "none",
                },
              },
            },
          },
        },
      },
    },
  },
}
