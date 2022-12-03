{pkgs, lib, ...}:
let
baseConfig = builtins.readFile ../dotfiles/nvim/base.vim;
bindsConfig = builtins.readFile ../dotfiles/nvim/binds.vim;

#TODO: configure binds, add treeclimber, understand lspsaga
# and begin learning all the features
in
{
    home.persistence."/state/home/imikoy" = {
        directories = [
            ".local/share/nvim"
        ];
    };
    programs.neovim = {
        enable = true;
        withNodeJs = true;
        withPython3 = true;
        plugins = [] ++ (with pkgs.vimPlugins; [
            plenary-nvim
            gruvbox
            gitsigns-nvim
            nvim-web-devicons
            lspkind-nvim
            {
            plugin = chad;
            config = "let g:chadtree_settings = { \'xdg\': v:true }";
            }
            {
            plugin = coq_nvim;
            config = "let g:coq_settings = { \'xdg\' : v:true ,  \"auto_start\": \"shut-up\"}";
            }
#Place manual completion on a different key. Look into snippets.
            {
            plugin = nvim-lspconfig;
            config = ''
            lua coq = require "coq"
            lua lsp = require "lspconfig"
            lua lsp.rnix.setup(coq.lsp_ensure_capabilities())
            lua lsp.ccls.setup(coq.lsp_ensure_capabilities())
            lua vim.diagnostic.config({ virtual_text={prefix = '\\'} })
            '';
            }
            coq-artifacts
            coq-thirdparty
            {
            plugin = undotree;
                config = ''
                    let g:undotree_WindowLayout=2
                    let g:undotree_ShortIndicators=1
                    '';
            }
            {
            plugin = telescope-nvim;
                config = "lua require('telescope').setup{}";
            }
            #telescope-zoxide
            #telescope-fzf-native-nvim
            #telescope-project-nvim
            nvim-treesitter.withAllGrammars

            {
            plugin = nvim-treesitter-context;
                config = "lua require(\"nvim-treesitter.configs\").setup {highlight = {enable = true}, incremental_selection = {enable = true}, indent = {enable = true}}";
            }
            harpoon
            {
            plugin = feline-nvim;
                config = ''
                    set termguicolors
                    lua require('feline').setup()
                    '';
            }
#Maybe look into configuring it
            {
            plugin = lspsaga-nvim;
                config = "lua require(\"lspsaga\").init_lsp_saga({})";
            }
#Need something like rust or c++ code to see this in action
        ]);

                extraConfig = baseConfig + bindsConfig + ''
                '';
                extraPackages = with pkgs;[
                    rnix-lsp
                        ccls
                        tree-sitter
                ];
    };
}
