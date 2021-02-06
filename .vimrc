set t_Co=256
" Vim-plug Package Manager
call plug#begin('~/.vim/plugged')

Plug 'thaerkh/vim-workspace'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'aserebryakov/vim-todo-lists'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-syntastic/syntastic'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'learntocode1024/vim-afterglow-ramastered'
Plug 'puremourning/vimspector'

call plug#end()

" Editor Settings
set cmdheight=2
set number
set relativenumber
set ai

" Soft Tabs
set tabstop=8
set shiftwidth=2
set softtabstop=2
set expandtab

" visual-multi Key Bind
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<C-d>'           " replace C-n
let g:VM_maps['Find Subword Under'] = '<C-d>'           " replace visual C-n

" Coc.nvim Settings
" Use <TAB> for completion
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
" Show Signature
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" keyBind
" nnoremap  :qa<CR>
nnoremap <Home> :tabfirst<CR>
nnoremap <End> :tablast<CR>
nnoremap <PageDown> :tabnext<CR>
nnoremap <PageUp> :tabprevious<CR>
nnoremap <C-n> :tabnew<Space>

" UI Settings
" " Airline
" let g:airline_theme='monochrome'
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#branch#enabled = 1
" lightline
set laststatus=2
let g:lightline = {
  \   'colorscheme': 'Dracula',
  \   'active': {
  \     'left':[ [ 'mode', 'paste' ],
  \              [ 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus' ]
  \     ]
  \   },
	\   'component': {
	\     'lineinfo': ' %3l:%-2v',
	\   },
  \   'component_function': {
  \     'gitbranch': 'fugitive#head',
  \     'cocstatus': 'coc#status',
  \   }
  \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

let g:lightline.separator = {
	\   'left': '', 'right': ''
  \}
let g:lightline.subseparator = {
	\   'left': '', 'right': '' 
  \}
" Color Scheme/Highlighting
let g:lsp_cxx_hl_use_text_props = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
colorscheme afterglow

" Auto Cursor Style
if has("autocmd")
  au VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
  au InsertEnter,InsertChange *
    \ if v:insertmode == 'i' |
    \   silent execute '!echo -ne "\e[6 q"' | redraw! |
    \ elseif v:insertmode == 'r' |
    \   silent execute '!echo -ne "\e[4 q"' | redraw! |
    \ endif
  au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
endif

" Cpp Support
" g++ compile and run
autocmd FileType cpp nnoremap <Buffer> <C-b> :w<bar>!g++ -o $proj_root/debug/%:r %
autocmd FileType cpp nnoremap <Buffer> <C-b> :w<bar>!g++ -o $proj_root/debug/%:r % && $proj_root/debug/%:r<CR>

" Debugger
let g:vimspector_enable_mappings='HUMAN'

" Cpp lint

" Code Snippets
