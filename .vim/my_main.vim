set sw=4 sts=4 smarttab expandtab
set wildignore=*.o,*.obj,*.a,*.bak,*.exe,*~
set makeprg=jam
set cino=:0p0t0(0
set cindent
set formatoptions=tcqro

let s:script_dir = expand("<sfile>:p:h")

" code formating에 필요한 기능들
if !exists("unuse_code_format") || unuse_code_format == 0
    exe "so ".s:script_dir . "/vim_lib/Align.vim"
    exe "so ".s:script_dir . "/vim_lib/AlignMaps.vim"
    exe "so ".s:script_dir . "/vim_lib/code_format.vim"
endif

"  Gets the directory for the file in the current window
"  Or the current working dir if there isn't one for the window.
function s:windowdir()
  if winbufnr(0) == -1
    return getcwd()
  endif
  return fnamemodify(bufname(winbufnr(0)), ':p:h')
endfunc

" find the file argument and returns the path to it.
" Starting with the current working dir, it walks up the parent folders
" until it finds the file, or it hits the stop dir.
" If it doesn't find it, it returns "Nothing"
function s:Find_in_parent(fln,flsrt,flstp)
  let here = a:flsrt
  while ( strlen( here) > 0 )
    if filereadable( here . "/" . a:fln )
      return here
    endif
    let fr = match(here, "/[^/]*$")
    if fr == -1
      break
    endif
    let here = strpart(here, 0, fr)
    if here == a:flstp
      break
    endif
  endwhile
  return "Nothing"
endfunc

function! ScopeFindDBFile()
    if exists("b:csdbpath")
      if cscope_connection(3, "out", b:csdbpath)
        return
        "it is already loaded. don't try to reload it.
      endif
    endif
    let newcsdbpath = s:Find_in_parent("cscope.out",s:windowdir(),$HOME)
"    echo "Found cscope.out at: " . newcsdbpath
"    echo "Windowdir: " . s:windowdir()
    if newcsdbpath != "Nothing"
      let b:csdbpath = newcsdbpath
      if !cscope_connection(3, "out", b:csdbpath)
        let save_csvb = &csverb
        set nocsverb
        exe "cs add " . b:csdbpath . "/cscope.out " . b:csdbpath
        set csverb
        let &csverb = save_csvb
      endif
    endif
endfunc

function! SvnBlame()
    let curbuf = bufname("%")
    execute 'vnew +r\ !svn\ blame\ ' . curbuf
endfunc 

function! GitBlame()
    let curbuf = bufname("%")
    execute 'vnew +r\ !git\ blame\ ' . curbuf
endfunc 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:alternate_file_name=''
function! AlternateFile(toggle_template)
    let filename_sans_extension = expand("%:t:r")
    let filename_extension = expand("%:e")
    let filename = ''

    if a:toggle_template == 0
        if filename_extension == "c"
            let filename = filename_sans_extension . ".h"
            execute ":find " . filename
        elseif filename_extension == "h"
            let filename = filename_sans_extension . ".c"
            execute ":find " . filename
        elseif filename_extension == "cpp"
            let filename = filename_sans_extension . ".hpp"
            execute ":find " . filename
        elseif filename_extension == "hpp"
            let filename = filename_sans_extension . ".cpp"
            execute ":find " . filename
        endif
    else
        if strlen(s:alternate_file_name) != 0 &&
            \filename_extension == 'template'
            execute ":e ".s:alternate_file_name
            let s:alternate_file_name=''
            return
        endif

        let pat='^ \* Template : '
        let line_num = search(pat,'n')
        if line_num <= 0
            return
        endif
        let s:alternate_file_name=expand("%")
        execute ":e ". substitute(getline(line_num), pat, '','')
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim script 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" :call SubLog("LOG", "DLM")
"function! SubLog(log,name)
"    execute 'silent %s/\<ACF_WARN_IF(\(.\+\),/ACF_LOG_IF(\1, ' . a:log . '_' . a:name . '|LOG_CRITICAL,/g'
"    execute 'silent %s/\<LOG_\(DLM\|ACF\|COMM\|DMSG\|RMSG\|HOOK\|INC\|TCP\|LKSB\|MLD\|RCO\|RECL\|SCNR\|MISC\|FIT\)\>/MOD_\1/g'
"endfunc
