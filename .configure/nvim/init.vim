call plug#begin('~/.local/share/nvim/plugged')
Plug 'junegunn/vim-easy-align' 
Plug 'sheerun/vim-polyglot' 
Plug 'vmchale/dhall-vim'
" Plug 'HerringtonDarkholme/yats.vim' 
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
"Plug 'mhartington/nvim-typescript' 
" Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'maxmellon/vim-jsx-pretty'
" Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/nerdtree' 
Plug 'scrooloose/nerdcommenter' 
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dyng/ctrlsf.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'neovimhaskell/haskell-vim'
Plug 'purescript-contrib/purescript-vim'
Plug 'gioele/vim-autoswap'
Plug 'rhysd/conflict-marker.vim'
Plug 'itchyny/lightline.vim'
Plug 'easymotion/vim-easymotion'
Plug 'ap/vim-css-color'
Plug 'gcmt/taboo.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'farmergreg/vim-lastplace'
Plug 'vimwiki/vimwiki'
Plug '~/Projects/vimscript/potion'
Plug 'liuchengxu/vim-which-key'

"my plugins:
" Plug 'benjmhart/vim-instantinstance'
Plug '~/Projects/vim-instantinstance'

call plug#end()

nmap <Leader>r  <Plug>ReplaceWithRegisterOperator
nmap <Leader>rr <Plug>ReplaceWithRegisterLine
xmap <Leader>r  <Plug>ReplaceWithRegisterVisual

" refresh plugins
:nnoremap <leader>pi :PlugInstall

" leader is spacebar
let mapleader = " " 
let maplocalleader = ","

" open vimconfig in a split
"edit and refresh vimrc
:command! Vimrc :e $MYVIMRC
:command! Refresh :so $MYVIMRC
" Edit Vimrc <- nmemnonic
:nnoremap <leader>ev :split $MYVIMRC<cr>
" Refresh Vimrc
:nnoremap <leader>rv :source $MYVIMRC<cr>

" some example abbreviations
:iabbrev waht what
:iabbrev tehn then

" personalized convenience abbreviations
" todo - consider putting these in the browser
:iabbrev @@ benjmhart@gmail.com


" show a  bit of ascii art at the bottom during startup
:echo ">^.^<"

" indents will round to even 2 spaces
:set shiftround

" indentation behaviour 
:filetype plugin indent on
:set autoindent
:set nocindent
:set nosmartindent
" On pressing tab, insert 2 spaces
:set expandtab
" show existing tab with 2 spaces width
:set tabstop=2
:set softtabstop=2
" when indenting with '>', use 2 spaces width
:set shiftwidth=2
" shift line down and up with - and _ respectively
:nnoremap - ddp
:nnoremap _ ddkP


" leader-w is write/save
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>u <C-u>
nnoremap <Leader>d <C-d>


" reduce wait time when exiting a mode
set updatetime=100

" Signify config (git gutter)
:highlight SignifySignAdd    ctermfg=34  ctermbg=53 guifg=#00ff00 cterm=NONE gui=NONE
:highlight SignifySignDelete ctermfg=red ctermbg=green guifg=#ff0000 cterm=NONE gui=NONE
:highlight SignifySignChange ctermfg=34 ctermbg=53 gui=NONE


" adds a horizontal line where the cursor is
set cursorline

"easy vim source
nnoremap <leader>sop :source %<cr>

" toggle comment with // in normal mode
let g:NERDSpaceDelims = 1
:map // <plug>NERDCommenterToggle

" enable vimball extensions (mainly the double line number extension)
packadd vimball

" provide access to x clipboard
:set clipboard+=unnamedplus

" Ctrl+shift+C copies to main clipboard in visual mode
:vnoremap <C-c> "+y
:vnoremap <C-d> "+d

" Ctrl+shift+v pastes from main clipboard in insert mode, allowing the same
" command to enter visual block mode in normal mode
:inoremap <C-v> <Esc>"+Pa

" inject a space immediately before selected char from normal mode
:nnoremap <C-Space> i<space><Esc>l
" inject a newline immediately after current line
:nnoremap <C-n> A<CR><Esc>
" inject a newline immediately before selected char
:nnoremap <A-C-n> i<CR><Esc>
" inject a newline on the line above the current line
:nnoremap <A-C-N> O<ESC><DOWN>

" spam the last macro with Ctrl+.
:nnoremap <C-.> @@

" Neovim Terminal mode mappings for exiting insert mode and window mappings
" for moving in and out of the terminal
:tnoremap <Esc> <C-\><C-n>
:tnoremap <M-h> <c-\><c-n><c-w>h
:tnoremap <M-j> <c-\><c-n><c-w>j
:tnoremap <M-k> <c-\><c-n><c-w>k
:tnoremap <M-l> <c-\><c-n><c-w>l
" Insert mode:
:inoremap <M-h> <Esc><c-w>h
:inoremap <M-j> <Esc><c-w>j
:inoremap <M-k> <Esc><c-w>k
:inoremap <M-l> <Esc><c-w>l
" Visual mode:
:vnoremap <M-h> <Esc><c-w>h
:vnoremap <M-j> <Esc><c-w>j
:vnoremap <M-k> <Esc><c-w>k
:vnoremap <M-l> <Esc><c-w>l
" Normal mode:
:nnoremap <M-h> <c-w>h
:nnoremap <M-j> <c-w>j
:nnoremap <M-k> <c-w>k
:nnoremap <M-l> <c-w>l
" autofill/autocomplete mappings
:inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
:inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
:inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "j"
:inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "k"
" make sure tab usage adds tabs
:inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "  " 

" Ctrl-tab in insert mode removes a tab
:inoremap <C-Tab> <ESC><<i
" tab key behaviour in normal mode
:nnoremap <Tab> >>
:nnoremap <M-Tab> <<

"
" ctrl-c  - (C)omma add a comma to end of line and jump to next
" otherwise it would be something silly like telling you how to exit
:nnoremap <C-c> A,<Esc>j^
" alt-c - (Comma) add newline at comma
" :nnoremap <M-c> f,a<cr><Esc>l
" add a newline before commas, for comma-leading style
" use for tearing down a single line into proper spacing
:nnoremap <M-c> t,a<cr><Esc>^

"normal mode movement helpers
:nnoremap Y y$ 
:nnoremap H ^
:nnoremap L $
" exit insert mode by typing jk
:inoremap jk <esc>  
:inoremap kj <esc>  
" tab movement
:nnoremap Gt 1gt
:nnoremap GT 1gT

" ctrl + a appends to word
:nnoremap <C-a> ea 
"mouse stuff
" :set mouse=a

" be lazy with the shift key when writing a file or quitting
:command! W :w
:command! Q :q

" checks for file changes  and updates the buffer
:set autoread

" enable syntax if possible
if has ('syntax') && !exists('g:syntax_on')
  syntax enable
endif

"allow backspace over anything in normal mode
set backspace=indent,eol,start

" turns off annoying compatibility mode with v/vi
:set nocp

" turns on line numbers
" use :RN to show both relative line numbers and concrete at the same time
:set number

" controls whitespace rendering
:set list
:set listchars+=tab:▶·,eol:↲
:set listchars+=space:·
:set listchars+=trail:·
:set listchars+=extends:>
:set listchars+=precedes:<
:set listchars+=nbsp:+

" set color for listchars
hi CustomWhiteSpace ctermfg=255
:syntax match CustomWhiteSpace "\s\+"

" allow search highlighting
:set hls  
" clear search highligting
:noremap <C-H> :nohls<Enter>
" control case-sensitivity when searching
:set ignorecase

:set smartcase

" show menu options as you write commands
:set wildmenu

" sets the maximum rows between cursor and screen bottom when moving
:set scrolloff=15

" controls line-breaking and word-wrapping
:set wrap
:set lbr


" Nerdtree default size and hotkey, minimal ui
:let g:NERDTreeWinSize=19
:nmap <leader>n :NERDTree<Enter>
:let NERDTreeMinimalUI = 1
:let NERDTreeDirArrows = 1

" quickfix list management
" :nnoremap <leader><C-o> :copen 5<cr>
" :nnoremap <leader><C-j> :cnext<cr>
" :nnoremap <leader><C-k> :cprevious<cr>

" auto-reload files when they change
au FocusGained,BufEnter * :silent! checktime
" while the below command is recommended for auto-reloading, it causes issues
" with pscid/ghcid/nodemon
" au FocusLost,WinLeave * :silent! w

" control key timeout to avoid delays exiting insert mode
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=50
endif

" always show status
set laststatus=2

" show when a column exceeds 80 char
:set colorcolumn=81
:set ruler

" apparently this makes the ruler only show when it gets crossed
" highlight ColorColumn ctermbg=red
" call matchadd('ColorColumn', '\%81v', 100)

" completely unfold with za by default, zA unfolds one level
:nnoremap za zA
:nnoremap zA za
" disable code folding
:set nofoldenable

" utf8 encode
if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

" enables session memory
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options
set viewoptions-=options
" multi-session undo tied to file
:set undofile

" insert characters, used for fance comment blocks
function RepeatChar()
  let times  = input("Count: ")
  let char   = input("Char :" )
  exe ":normal a" . repeat(char, times)
endfunction

"EasyAlign shortcut for regex 
vnoremap <leader>ea :Ea<CR><C-x>

"leader - adds an 80 char line break
nnoremap <leader>- :call RepeatChar()<CR>80<CR>-<CR>

" leader-r calls a function which repeats chars
nnoremap <leader>rc :call RepeatChar()<CR>

" leader-d injects a date
noremap <leader>D :put =strftime('%d-%m-%y')<CR>

" leader-gb is git blame
noremap <leader>gb :Gblame

" terminal cursor visibility guarantee
:hi! TermCursorNC ctermfg=15 guifg=#fdf6e3 ctermbg=14 guibg=#93a1a1 cterm=NONE gui=NONE

" insert seamless undo
:inoremap <c-u> <esc>ui

" ctrl-p use cwd not file-relative search
let g:ctrlp_working_path_mode = 'rw'
" ctrl-p use regexp mode by default
let g:ctrlp_regexp = 1

function! LightLineFileName()
  " todo: trim to show ....40 ish chars?
  return expand('%')
endfunction 

" lightline show full filename from cwd if possible
let g:lightline = {
      \ 'component_function': {
      \   'filename': 'LightLineFileName'
      \ },
      \ }

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=indent
augroup END

augroup filetype_haskell
    autocmd!
    autocmd FileType haskell setlocal foldmethod=indent
augroup END

augroup filetype_purescript
    autocmd!
    autocmd FileType purescript setlocal foldmethod=indent
augroup END

function HardMode()
  :noremap <Up> <nop>
  :noremap <Down> <nop>
  :noremap <Left> <nop>
  :noremap <Right> <nop>
  :noremap <PageUp> <nop>
  :noremap <PageDown> <nop>
  :inoremap <Up> <nop>
  :inoremap <Down> <nop>
endfunction

"enable hardmode by default
:augroup hardmode
    :autocmd!
    :autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
:augroup END
" :autocmd BufNewFile * :write
" vautocmd BufWritePre *.html :normal gg=G

" high-legibility tab color hacks
:hi TabLineFill ctermfg=Black ctermbg=DarkGreen
:hi TabLine ctermfg=Black ctermbg=LightYellow
:hi TabLineSel ctermfg=DarkRed ctermbg=LightYellow


function CommonTabs()
  :TabooOpen(nau)
  :edit ~/Projects/juspay/nau/
  :TabooOpen(gw)
  :edit ~/Projects/juspay/euler-api-gateway/
  :TabooOpen(Liqwid)
  :edit ~/Projects/liqwid/
  :TabooOpen(vimwiki)
  :edit ~/vimwiki/index.wiki
  :TabooOpen(vimscript)
  :edit ~/.configure/nvim/init.vim
  :TabooOpen(stonks)
  :edit ~/Projects/stonks/
  :normal Gt
  :tabclose

endfunction

nnoremap <leader>vwr :!vimwikirefresh<cr>
nnoremap <leader>zsh :e ~/.zshrc<cr>

nnoremap <leader>ct :call CommonTabs()<cr>



" TODO - find out why/where ctrl-i got remapped
" forces ctrl-i to in/out jump navigation
nnoremap <c-i> <c-i>
