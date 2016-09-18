"vim이 내부적으로 LANG 환경 변수를 보기 때문에 LANG 환경 변수를 ko_KR.EUC-KR로
"설정했다면 encoding 설정은 무의미 하다.
"euc-kr은 korea과 같다.
"set encoding=euc-kr
"vim에서 파일을 새로 생성한 경우 사용되는 encoding
"set fileencoding=euc-kr
" 기본 character는 utf-8이다.

syntax on

set encoding=utf-8
set fileencoding=utf-8

set background=dark
set incsearch
set ruler
set hlsearch
set showmatch
set winwidth=80
set textwidth=80
set makeprg=make\ -j16
"set number
"set paste

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tags and file search options
" ./tags: current file이 있는 directory부터 parent들을 따라가면서 tags 파일 서치
" tags: current directory부터 parent들을 따라가면서 tags 파일 서치
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tags=./tags,tags

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" my_main.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
so $HOME/.vim/my_main.vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Programming
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" multi-line macro backslash align (code_format.vim)
autocmd FileType c,cpp,yacc,lex map <buffer> ;am :call MassageDefs()<CR>
autocmd FileType c,cpp,yacc,lex map <buffer> ;au :call UnMassageDefs()<CR>
autocmd FileType c,cpp,yacc,lex map <buffer> ;at :call AlternateFile(0)<CR>

autocmd BufWritePre *.[chly],*.[ch]pp call RemoveTrailingSpaces()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Align
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" alignments : declarations/assignments
autocmd BufEnter *.[chly] map <buffer> ;ad <Leader>adec
autocmd BufEnter *.[chly] map <buffer> ;a= :Align =<CR>
autocmd BufEnter *.[chly] map <buffer> ;ac <Leader>ascom
autocmd BufEnter *.[chly] map <buffer> ;ab <Leader>abox

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cscope 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" for making the vim window split horizontally, use <C-@> (CTRL + SPACE)
" for making the vim window split vertically, use <C-@><C-@>
"
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
"   'd'   called: find functions that function under cursor calls
"
"nmap ;js :vert scs find s <C-R>=expand("<cword>")<CR><CR>:cw<CR>
"nmap ;jg :vert scs find g <C-R>=expand("<cword>")<CR><CR>:cw<CR>
"nmap ;jc :vert scs find c <C-R>=expand("<cword>")<CR><CR>:cw<CR>
"nmap ;jt :vert scs find t <C-R>=expand("<cword>")<CR><CR>:cw<CR>
"nmap ;je :vert scs find e <C-R>=expand("<cword>")<CR><CR>:cw<CR>
"nmap ;jf :vert scs find f <C-R>=expand("<cfile>")<CR><CR>:cw<CR>
"nmap ;ji :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:cw<CR>
"nmap ;jd :vert scs find d <C-R>=expand("<cword>")<CR><CR>:cw<CR>

nmap <F5> :cs find s <C-R>=expand("<cword>")<CR><CR>:cw<CR>
nmap <F6> :cn<CR>
nmap <F7> :cp<CR>

autocmd Filetype c,cpp call ScopeFindDBFile()

" use quickfix through :cw
if has("cscope")
        set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
        " for using Ctrl+T(removing "tagstack is empty")
	set nocscopetag
	"make quick window to right
	set splitright
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOY Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map ;jj :bn<CR>
map ;kk :bp<CR>
map ;qq :q<CR>
map ;qqq :qa<CR>
nmap ;bl :call SvnBlame()<CR>
nmap ;gl :call GitBlame()<CR>

" textwidth(e.g. 80)을 넘어가는 글자들의 배경색 변경
"autocmd BufEnter *.[chly] if &textwidth > 0 | exec 'match Todo /\%>' . &textwidth . 'v.\+/' | endif

" 뭘하는 걸까?
"autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" set number highlight
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" for Linux kernel
set makeprg=gmake
set path+=$HOME/repo/linux/**
set tags+=$HOME/repo/linux/tags

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim script 참고 예제들(function 예제들은 my_main.vim에 존재)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" highlight 추가하기
"autocmd BufEnter *.[chly]
"    \ syntax match acfCheck /ACF_CHECK[^(]*(\([^;]\|\n\)*);/" recommended color
"hi link acfCheck cDefine
