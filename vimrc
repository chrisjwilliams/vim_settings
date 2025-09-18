" VIM editor settings
" Copyright 2025 Chris Williams, all rights reserved.
" Licenced under GPL version 3.0
"
" Fold commands:
"   zo: open fold
"   zc: close fold
"   zR: open all folds
"   zM: close all folds
"
" GENERAL SETTINGS --------------------------------------------- {{{
set expandtab
set tabstop=4
set shiftwidth=4
set spelllang=en_gb
filetype on

" display a menu for autocompletion of find commands
set wildmenu
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" recursive directory for find
"set path+=**

" }}}
" STATUS LINE -------------------------------------------------------------- " {{{
" left hand side
set statusline=\ %f\ %M\ \ buffer:\ %n\ %q\ %r\ %h
" right hand side
set statusline+=%=ascii:\ %b(0x%B)\ percent:\ %p%%
" }}}
" HIGHLIGHTING AND SYNTAX -------------------------------------- {{{
syntax on

if !hlexists('Todo')
    highlight Todo ctermfg=black ctermbg=yellow
endif
augroup todo_highlighting
    au!
    au Syntax * syntax match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|OPTIMISE)/ containedin=.*Comment,vimCommentTitle
augroup END
highlight def link MyTodo Todo

" make whitespace at end of lines visible
match Todo /\s\+$/

"set matchpairs+=<:>
:au FileType c,cpp,java,html,xml set mps+=<:>


" Highlight cursor line underneath the cursor vertically.
set cursorcolumn


" }}}
" VIMSCRIPT ---------------------------------------------------- {{{

" Enable code folding for vim files
" Use the marker method for folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" switch header/implementation files in C++
function! SwitchSourceHeader()
  let l:local_path = escape(expand("%:p:h:h"), ' ')
  execute "set path+=".l:local_path."**"
  if (expand ("%:e") == "cpp")
    find %:t:r.h
  else
    find %:t:r.cpp
  endif
  execute "set path-=".l:local_path."**"
endfunction

nnoremap ,s :call SwitchSourceHeader()<CR>

" returns a string for the files Author for the current buffer
" Will use git config user.name if available
" otherwise g:Author if set
function! Author()
    if !exists('b:Author')
        let b:Author=trim(system("git config user.name"))
        if !exists('b:Author')
            if exists('g:Author'))
                let b:Author=g.Author
            else
                let b:Author=''
            endif
        endif
    endif
    return b:Author
endfunction

" }}}
" ABBREVIATIONS ------------------------------------------------ {{{
nnoremap \sid :let s = synID(line('.'), col('.'), 1) \| echo synIDattr(s, 'name') . ' -> ' . synIDattr(synIDtrans(s), 'name')<CR>
:inoreabbrev ccopy Copyright  <esc>"=strftime("%Y")<CR>Pa Chris Williams, all rights reserved.
:inoreabbrev /** /**<CR>*<CR>*/<Up>

" template mappings
" HTML templates
nnoremap ,html :-1read ${HOME}/.vim/templates/html/outline.html \| %s/%Y/\=strftime("%Y")/<CR>3jf

" C++ templates
" Will use the file extension of the current buffer to find the template in templates/cpp
" type ,cpp in normal (command) mode
nnoremap ,cpp :let cpp = { 'Author': Author(), 'class_name': expand('%:t:r'), 'namespace' : expand('%:p:h:t') }\|
    \ :let cpp.namespace_open = "namespace " .. cpp.namespace .. " {" \|
    \ :let cpp.namespace_close = "} // namespace " .. cpp.namespace \|
    \ :let cpp.NAMESPACE = substitute(cpp.namespace, '\(\w\+\)', '\U\1\E', '') \|
    \ :let cpp.CLASS_NAME = substitute(cpp.class_name, '\(\w\+\)', '\U\1\E', '') \| -1read ${HOME}/.vim/templates/cpp/%:e.template \| %s/%Y%/\=strftime("%Y")/ \| %s/%\(\w\+\)%/\=get(cpp, submatch(1), '')/g<CR>3jf

" }}}
