{
  config,
  lib,
  pkgs,
  ...
} @ inputs: {
  home.persistence."/local_state/home/imikoy" = {
    directories = [".local/share/nvim"];
  };
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      gitsigns-nvim
      nvim-web-devicons
      lspkind-nvim
      {
        plugin = gruvbox-nvim;
        type = "lua";
        config = ''
          --
          require("gruvbox").setup()
          vim.cmd("colorscheme gruvbox")
        '';
      }
      editorconfig-nvim
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          --
                 require('Comment').setup()
        '';
      }
      {
        plugin = coq_nvim;
        type = "lua";
        config = ''
          --
          vim.g.coq_settings = {
              ["auto_start"] = 'shut-up',
              ["xdg"] = true,
              ["keymap.recommended"] = false,
          }

          local remap = vim.api.nvim_set_keymap
          remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
          remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
          remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
          remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        #TODO: install lsp servers
        config = ''
          --
          coq = require "coq"
          lsp = require "lspconfig"
          lsp.nixd.setup(coq.lsp_ensure_capabilities())
          lsp.ccls.setup(coq.lsp_ensure_capabilities())
          lsp.pyright.setup(coq.lsp_ensure_capabilities())
          lsp.rust_analyzer.setup(coq.lsp_ensure_capabilities())
          lsp.gopls.setup(coq.lsp_ensure_capabilities())
          vim.diagnostic.config({ virtual_text={prefix = '\\'} })
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
        type = "lua";
        config = ''
          require('telescope').setup{}
          require('telescope').load_extension('harpoon')
        '';
      }
      nvim-treesitter.withAllGrammars
      {
        plugin = nvim-treesitter-context;
        type = "lua";
        config = ''
          --
          require("nvim-treesitter.configs").setup {
              highlight = {enable = true},
              incremental_selection = {enable = true},
              --Conflicts with autopairs
              --indent = {enable = true}}
              indent = {enable = false}}
        '';
      }
      harpoon
      {
        plugin = feline-nvim;
        type = "lua";
        config = ''
          require('feline').setup()
        '';
      }
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = ''require("lspsaga").setup({})'';
      }
      {
        plugin = leap-nvim;
        type = "lua";
        config = ''
          --
          require('leap').add_default_mappings()
          vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
        '';
      }
      {
        plugin = flit-nvim;
        type = "lua";
        config = ''
          --
          require('flit').setup{}
        '';
      }
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''
          --
          require("todo-comments").setup()
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          --
          require("nvim-autopairs").setup{}

          local remap = vim.api.nvim_set_keymap
          local npairs = require('nvim-autopairs')

          npairs.setup({ map_bs = false, map_cr = false })
          _G.MUtils= {}

          MUtils.CR = function()
          if vim.fn.pumvisible() ~= 0 then
              if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
              return npairs.esc('<c-y>')
              else
              return npairs.esc('<c-e>') .. npairs.autopairs_cr()
              end
          else
              return npairs.autopairs_cr()
          end
          end
          remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

          MUtils.BS = function()
          if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
              return npairs.esc('<c-e>') .. npairs.autopairs_bs()
          else
              return npairs.autopairs_bs()
          end
          end
          remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })
        '';
      }
    ];

    extraConfig = ''
      set pastetoggle=<F2>
      nnoremap <SPACE> <Nop>
      let mapleader=" "
      set mouse="a"
      set number
      set relativenumber
      set cursorline
      set hidden
      set noerrorbells
      set colorcolumn=100

      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
      set expandtab
      set smartindent
      set shiftround
      set smarttab
      set autoindent
      set showmatch

      set ignorecase
      set smartcase
      set hlsearch
      set incsearch

      set history=1000
      set undolevels=1000

      set title
      set showcmd
      set wildmenu

      set splitright
      set splitbelow

      set termguicolors
      "colorscheme gruvbox

      set showmatch

      set updatetime=50
      noremap ; :
      noremap < <<
      noremap > >>

      noremap gQ <nop>
      "Coq remaps <C-h> to jump_to_mark from i_<BS>
      "Also, its <C-Space> is overshadowed by tmux
      "leap.nvim remaps s/S, v_x/v_X, which are redundant (cl and cc respectively)
      "flit.nvim remaps t/T and f/F to leap.nvim-powered variants

      noremap <F2> :UndotreeToggle<CR>
      "noremap <F6> :CHADopen<CR>

      nnoremap <leader>ft :Telescope treesitter<CR>
      nnoremap <leader>fb :Telescope buffers<CR>
      nnoremap <leader>ff :Telescope find_files<CR>
      nnoremap <leader>fF :Telescope live_grep<CR>
      nnoremap <leader>fr :Telescope registers<CR>
      nnoremap <leader>pp :Telescope harpoon marks<CR>
      nnoremap <leader>pt :lua require('harpoon.mark').add_file()<CR>
      nnoremap <leader>ps :lua require('harpoon.mark').rm_file()<CR>
      nnoremap <leader>pS :lua require('harpoon.mark').clear_all()<CR>
      "nnoremap <leader>pp :lua require('harpoon.ui').toggle_quick_menu()<CR>

      "the 'unpeck wifi' solution, when folds start getting funky
      noremap <F11> :set foldexpr=nvim_treesitter#foldexpr()<CR>
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
      set nofoldenable

      nnoremap <leader>ru :Lspsaga diagnostic_jump_next<CR>
      nnoremap <leader>rl :Lspsaga diagnostic_jump_prev<CR>
      nnoremap <leader>rr :Lspsaga hover_doc<CR>
      nnoremap <leader>ri :Lspsaga preview_definition<CR>
      nnoremap <leader>ro :Lspsaga rename<CR>
      nnoremap <leader>rn :Lspsaga code_action<CR>
      nnoremap <leader>rf :Lspsaga lsp_finder<CR>

    '';

    extraPackages = with pkgs; [
      nixd
      nixfmt-classic
      ccls
      tree-sitter
      nodePackages.pyright
      rust-analyzer
      cargo
      xclip
    ];
  };
}
