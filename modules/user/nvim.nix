select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#Neovim configuration meant to be used for one-off file viewing and edits.
#All major work is done through Emacs, vim is delegated to be the fast-to-access editor.
#Therefore this config is meant to be:
#1. Fast to load
#2. Robust (coq no more)
#3. Have basic LSP capabilities
#4. Have no multifile or project-oriented configuration
let
  cfg = config._hlk_auto.nvim;
  options._hlk_auto.nvim.default.enable = lib.mkEnableOption "default Neovim configuration";
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        programs.nixvim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          colorscheme = "gruvbox-baby";
          colorschemes.gruvbox-baby = {
            enable = true;
            settings = {
              background_color = "dark";
            };
          };
          clipboard.providers.wl-copy.enable = lib.mkIf (
            config._hlk_auto.graphical.desktopVariant == "wayland"
          ) true;
          globals = {
            mapleader = " ";
          };
          opts = {
            mouse = "a";
            number = true;
            relativenumber = true;
            cursorline = true;
            hidden = true;
            errorbells = false;
            colorcolumn = "80";
            tabstop = 2;
            softtabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            smartindent = true;
            shiftround = true;
            smarttab = true;
            autoindent = true;
            showmatch = true;
            ignorecase = true;
            smartcase = true;
            hlsearch = true;
            incsearch = true;
            history = 1000;
            undolevels = 1000;
            title = true;
            showcmd = true;
            wildmenu = true;
            splitright = true;
            splitbelow = true;
            termguicolors = true;
            updatetime = 50;
            foldmethod = "expr";
            foldexpr = "nvim_treesitter#foldexpr()";
            foldenable = false;
          };
          keymaps = [
            {
              action = ":UndotreeToggle<CR>";
              key = "<F2>";
              mode = [
                "n"
                "v"
                "o"
              ];
            }
          ];
          #TODO: autostart them when visiting their respective files
          #lsp enable
          lsp.servers = {
            ccls = {
              enable = true;
              config.filetypes = [
                "c"
                "cpp"
                "h"
                "hpp"
              ];
            };
            sqls = {
              enable = true;
              config.filetypes = [
                "sql"
              ];
            };
            ruff = {
              enable = true;
              config.filetypes = [
                "py"
              ];
            };
            nixd = {
              enable = true;
              config.filetypes = [
                "nix"
              ];
            };
            rust_analyzer = {
              enable = true;
              config.filetypes = [
                "rs"
              ];
            };
          };
          # files = {};
          extraPackages = with pkgs; [
            nixd
            ccls
            ruff
            rust-analyzer
            sqls
          ];
          dependencies = {
            tree-sitter.enable = true;
          };
          plugins = {
            #Modes
            #TODO: cannot be loaded rn
            # csvview = {
            #   enable = true;
            #   autoLoad = false;
            # };
            undotree = {
              enable = true;
              settings = {
                WindowLayout = 2;
                ShortIndicators = 1;
              };
            };
            #LSP completion, diagnostics, treesitter highlights
            blink-indent.enable = true;
            blink-cmp.enable = true;
            # lspconfig.enable = true;
            lsp.enable = true;
            tiny-inline-diagnostic.enable = true;
            treesitter = {
              enable = true;
              indent.enable = true;
              folding.enable = true;
            };
            #Icons, visuals
            lspkind.enable = true;
            gitsigns.enable = true;
            lualine.enable = true;
            todo-comments.enable = true;
            #Editing
            comment.enable = true;
            #TODO: replicate this
            #         require('leap').add_default_mappings()
            #         vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
            #TODO: require('leap').opts.vim_opts['go.ignorecase'] = false
            leap.enable = true;
            flit.enable = true;
            autopairs.enable = true;
          };
        };
      }
    #nixos
    else
      {
        environment.persistence."/local_state".users.${userName} = {
          directories = [ ".local/share/nvim" ];
        };
      };
}
