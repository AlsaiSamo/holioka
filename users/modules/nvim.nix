{pkgs, lib, ...}:
let
baseConfig = builtins.readFile ../dotfiles/nvim/base.vim;
pluginConfig = builtins.readFile ../dotfiles/nvim/plugin_config.vim;
bindsConfig = builtins.readFile ../dotfiles/nvim/binds.vim;
in
{
    home.persistence."/state/home/imikoy" = {
        directories = [
            ".local/share/nvim"
        ];
    };
    programs.neovim = {
        enable = true;
        plugins = [] ++ (with pkgs.vimPlugins; [
        #coq_nvim
            gruvbox
                vim-airline
                nvim-web-devicons
                lspkind-nvim

                plenary-nvim
                telescope-nvim
                telescope-zoxide
                telescope-fzf-native-nvim
                nvim-treesitter
                nvim-lspconfig
                undotree
                vifm-vim

#TODO package and install chadtree? And coq artifacts

#lspsaga?
#and also detect whether I have plugged in my keeb
        ]);
        extraConfig = baseConfig + pluginConfig + bindsConfig;
    };
}
