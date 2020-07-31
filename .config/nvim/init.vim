call plug#begin('~/.local/share/nvim/plugged')
Plug 'junegunn/vim-easy-align' 
Plug 'sheerun/vim-polyglot' 
Plug 'HerringtonDarkholme/yats.vim' 
Plug 'tpope/vim-surround'
"Plug 'mhartington/nvim-typescript' 
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'maxmellon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
"Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree' 
Plug 'scrooloose/nerdcommenter' 
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'neovimhaskell/haskell-vim'
Plug 'purescript-contrib/purescript-vim'
Plug 'ctrlpvim/ctrlp.vim' 
Plug 'vim-scripts/ReplaceWithRegister'
call plug#end()

set updatetime=100


" toggle comment with // in normal mode
let g:NERDSpaceDelims = 1
:map // <plug>NERDCommenterToggle

packadd vimball
" provide access to x clipboard
:set clipboard+=unnamedplus
"Ctrl+shift+C copies to main clipboard in visual mode
:vnoremap <C-c> "+y
:vnoremap <C-d> "+d
"Ctrl+shift+v pastes from main clipboard in insert mode, allowing the same
"command to enter visual block mode in normal mode
:inoremap <C-v> <Esc>"+Pa

" inject a space immediately before selected char from normal mode
:nmap <C-Space> i<space><Esc>l
" inject a newline immediately after current line
:nmap <C-n> A<CR><Esc>
" inject a newline immediately before selected char
:nmap <A-C-n> i<CR><Esc>
" inject a newline on the line above the current line
:nmap <A-C-N> O<ESC><DOWN>

"inject haskell pragma syntax
:nmap <leader>l i{-# LANGUAGE  #-}<Esc><<o<Esc>k$4ha

" auto close quotes and parens
":inoremap ` ``<left>
":inoremap " ""<left>
":inoremap ' ''<left>
":inoremap ( ()<left>
":inoremap [ []<left>
":inoremap { {}<left>

" clear search highligting
:map <C-H> :nohls<Enter>


"map <C-l> :call g:ToggleNuMode()<CR>

"edit and refresh vimrc
:command Vimrc :e $MYVIMRC<Enter>
:command Refresh :so $MYVIMRC

" be lazy with the shift key when writing a file or quitting
:command W :w
:command Q :q

":set nu rnu
:set autoread
:set autoindent
:set smartindent
:syntax on
:set nocp
:set number
:set list
:set listchars+=tab:▶·,eol:↲
:set listchars+=space:·
:set listchars+=trail:·
:set hls  
:filetype plugin indent on
:set wildmenu
:set scrolloff=5
:set ignorecase
:set smartcase
:set lbr


" Nerdtree default size and hotkey
:let g:NERDTreeWinSize=20
:nmap <leader>n :NERDTree<Enter>

" On pressing tab, insert 2 spaces
:set expandtab
" show existing tab with 2 spaces width
:set tabstop=2
:set softtabstop=2
" when indenting with '>', use 2 spaces width
:set shiftwidth=2

" auto-reload files when they change
au FocusGained,BufEnter * :silent! checktime
" while the below command is recommended for auto-reloading, it causes issues
" with pscid/ghcid/nodemon
" au FocusLost,WinLeave * :silent! w

