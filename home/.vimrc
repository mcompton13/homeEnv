set number
set ruler
set showmode
set expandtab 
set autoindent
set smartindent
set visualbell
syntax on
highlight ColLimit ctermbg=7 guibg=7
autocmd BufWinEnter * let w:m1=matchadd('ColLimit', '\%>80v.\+', -1)
autocmd BufWinEnter *.cf,*.xslt,*.xml,*.html call matchdelete(w:m1)
autocmd BufWinEnter *.cf,*.xslt,*.xml,*.html let w:m1=matchadd('ColLimit', '\%>100v.\+', -1)
autocmd WinEnter * let w:m1=matchadd('ColLimit', '\%>80v.\+', -1)
autocmd WinEnter *.cf,*.xslt,*.xml,*.html call matchdelete(w:m1)
autocmd WinEnter *.cf,*.xslt,*.xml,*.html let w:m1=matchadd('ColLimit', '\%>100v.\+', -1)
autocmd FileType * set sw=4 ts=4 sts=4
autocmd FileType javascript,cf,xslt,xml,html set sw=2 ts=2 sts=2
