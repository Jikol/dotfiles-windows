augroup RestoreCursorShapeOnExit
    autocmd!
    autocmd VimLeave * set guicursor=a:ver20,a:blinkwait700-blinkoff400-blinkon250
augroup END

set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

set mouse=a

set notermguicolors

set clipboard=unnamedplus
