:set bs=2
:set ts=2
:set ruler
:syntax on
:set wm=5
:set tw=80
:set autoindent
:set backup
set matchpairs=(:),[:],{:},<:>
map <F12> :wq <CR>
map <F11> :w <CR>
if has("autocmd")
  autocmd BufNewFile,BufRead *.pl  map <F5> :w<CR>:! perl -wc %<CR>
  autocmd BufNewFile,BufRead *.pm  map <F5> :w<CR>:! perl -wc %<CR>
endif
