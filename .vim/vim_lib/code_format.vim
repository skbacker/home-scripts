
function! MassageDefs() range
  let lno = a:firstline
  while lno < a:lastline - 1 
    execute lno . "," . lno . 's/[ \t]*\\\?$//'
    let linetext=getline(lno)
    let len=strlen(linetext)
    while len < 79
        let linetext = linetext . ' '
        let len = len + 1
    endwhile
    let linetext = linetext . '\'
    call setline(lno, linetext)
    let lno = lno + 1
  endwhile
endfunction

function! UnMassageDefs() range
  let lno = a:firstline
  while lno <= a:lastline
    execute lno . "," . lno . 's/[ \t]*\\\?$//'
    let lno = lno + 1
  endwhile
endfunction

function! CommentAtEOL()
  let linetext=getline(".")
  let tabspace=""
  let i = 0
  while i < &sts
    let tabspace = tabspace . ' '
    let i = i + 1
  endwhile
  let linetext = substitute(linetext, "\t", tabspace, "g")
  let len = strlen(linetext)
  if len == 0
    let linetext = "/*  */"
  else
    while len < 40
      let len = len + 1
      let linetext = linetext . ' '
    endwhile
    let linetext = linetext . ' /*  */'
  endif
  call setline(line("."), linetext)
endfunction

" tab, space handling
function! RemoveTab()
    if search("\t") <= 0 | return | endif
    echo "File has TAB character, expand it? "
    if "y" == nr2char(getchar())
        execute "set tabstop=4"
        execute ":retab!"
        execute "set tabstop=8"
    endif
    normal gg
endfunction

function! RemoveTrailingSpaces()
    let cur_col = col(".")
    let cur_line = line(".")
    normal H 
    let screen_top_line = line(".")
    execute "normal " . cur_line . "G"

    let re_trailing_spaces = '[ \t][ \t]*$'
    normal gg
    while search(re_trailing_spaces) > 0
        execute "s/" . re_trailing_spaces . "//g"
    endwhile

    execute "normal " . screen_top_line . "G" 
    normal zt
    execute "normal " . cur_line . "G"
    execute "normal " . cur_col . "|"
endfunction



"현재 커서위치에서, structName을 기초로 ifndef-typedef-endif 추가
function! InsertTypeDef(structName)
    let capName=toupper(a:structName)
    exe "normal " . "0Di#ifndef _".capName."_T\n"
    exe "normal " . "0Di#define _".capName."_T\n"
    exe "normal " . "0Ditypedef struct ".a:structName."_s ".a:structName."_t;\n"
    exe "normal " . "0Di#endif\n\e"
endfunction

"현재 커서위치에서 structName을 기초로 struct{} 추가
function! InsertStruct(structName)
    exe "normal " . "0Distruct ".a:structName."_s {\n"
    exe "normal " . "0Di};\e"
endfunction

"line_no로 이동하여, 아래 내용을 입력
"/************
" * comment
" ************/
function! InsertComment(line_no,comment)
    call cursor(a:line_no,0)
    exe "normal " . "0Di/*\e78a*\eo\e"
    exe "normal " . "0Di *"a:comment"\n\e"
    exe "normal " . "0Di *\e77a*\e$a/\e"
endfunction


" /*COMMENT ------------------*/
function! InsertLineCommentBefore(line_no,comment)
    call cursor(a:line_no,0)
    let hcnt = 80 - strlen(a:comment) - 5
    let before_tw = &textwidth
    exe "set textwidth=90"
    exe "normal " . "0Di/*".a:comment." \e".hcnt."a-\e$a*/\e"
    exe "set textwidth=".before_tw
endfunction

" /*--------------------------COMMENT*/
function! InsertLineCommentAfter(line_no,comment)
    call cursor(a:line_no,0)
    let hcnt = 80 - strlen(a:comment) - 5
    let before_tw = &textwidth
    exe "set textwidth=90"
    exe "normal " . "0Di/*\e".hcnt."a-\e$a ".a:comment."*/\e"
    exe "set textwidth=".before_tw
endfunction

"
"visual block으로 설정된 범위 위 아래로, string를 삽입한다
" str1
" ... selected block ...
" ... selected block ...
" str2
function! InsertBlockString(str1,str2) range
    call append(a:lastline, a:str2)
    call append(a:firstline -1, a:str1)
    call cursor(a:firstline,0)
endfunction

" 아래와 같은 패턴 중간 block에서 이 함수를 부를 경우, str1, str2 라인을 지워준다
" 어느하나라도 존재하지 않는 경우 지우지 않는다
"str1
"   In the Middle of Pattern 
"str2
function! RemoveBlockString(str1,str2)
    let nr_cur=line(".") 

    let nr_e = searchpair(a:str1,"",a:str2,"W")
    let nr_s = searchpair(a:str1,"",a:str2,"bW")

    "pair로 pattern이 존재하지 않으면 그냥 return
    if nr_e == 0 || nr_s == 0
        return
    endif

    call cursor(nr_e,0)
    exe "normal dd"
    call cursor(nr_s,0)
    exe "normal dd"
    
    call cursor(nr_cur,0)
endfunction


"현재 위치 부터 연속된 라인이 패턴에 맞을때 패턴에 맞는 마지막 라인찾기
"forward가 > 0 이면 아래쪽으로, < 0 이면 위쪽으로 찾는다
function! FindLastContinuousLinePatternMatch(pattern,forward)
    if a:forward > 0
        let direction = 1
    else
        let direction = -1
    endif

    while 1
        let next_nr = line(".") + direction
        if match(getline(next_nr), a:pattern) != -1
            call cursor(next_nr,0)
            continue
        else
            break
        endif
    endwhile
endfunction

"현재 위치 부터 연속된 라인이 패턴에 맞을때 패턴에 맞지 않는 마지막 라인찾기
"forward가 > 0 이면 아래쪽으로, < 0 이면 위쪽으로 찾는다
function! FindLastContinuousLinePatternMisMatch(pattern,forward)
    if a:forward < 0
        let direction = -1
    else
        let direction = 1
    endif

    while 1
        let next_nr = line(".") + direction
        if match(getline(next_nr), a:pattern) == -1
            call cursor(next_nr,0)
            continue
        else
            break
        endif
    endwhile
endfunction

"같은 패턴을 가진 line을 찾아 선택. 
"커서는 pattern 시작부 처음,중간,끝에  있어야 함
"#include...
"#include...
"#include...
"혹은
"    abc_t
"    def_t
"등등
function! SelectLineOfSamePattern(pattern)
    "move to last pattern
    call FindLastContinuousLinePatternMatch(a:pattern, 1)

    exe "normal v"

    "select to first pattern
    call FindLastContinuousLinePatternMatch(a:pattern, -1)
endfunction


"현재 위치에서, 위로 #include가 있는 위치를 찾고,
"사용자 입력으로 header file이름과, comment를 받아 코드완성
"만약 Comment를 입력하지 않으면, 자동으로 header파일이름_t가 들어간다
"마커로, 직전에 편집하던 위치를 x로 잡아 놓았기 때문에, mx
" 헤더파일 입력을 마치고, 'x를 통해서 원래 위치로 복귀가능하다
function! InsertIncludeHeader(comment)
    exe "normal mx"

    exe "normal gg"
    if search('^#include','W') == 0
        return
    endif

    "다음 줄 검사
    call FindLastContinuousLinePatternMatch('^#include', 1)

    while 1
        let hdr = input("header file name? ")
        if strlen(hdr) != 0
            break
        endif
    endwhile

    if strlen(a:comment) == 0
        let comm = input("comment? ")
    else
        let comm = a:comment
    endif

    if strlen(comm) == 0
        let comm = hdr."_t"
    endif

    call append(".", "#include \"".hdr.".h\" /*".comm."*/")

    exe "normal j08w"
endfunction

"str1,str2가 pair로 존재하는지 점검하고, str1,str2패턴을 지운다
function! RemoveMatchPattern(str1, str2)
    let nr_cur=line(".")

    let nr_s = searchpair(a:str1,"",a:str2,"b")
    let col_s = col(".")-1
    let nr_e = searchpair(a:str1,"",a:str2,"")
    let col_e = col(".")-1

    if nr_e <= 0 || nr_s <= 0
        return
    endif

    call cursor(nr_e, col_e)
    let xlen=strlen(matchstr(getline("."),a:str2,col_e))
    call cursor(nr_e, col_e+1)
    exe "normal ".xlen."x"


    call cursor(nr_s, col_s)
    let xlen=strlen(matchstr(getline("."),a:str1,col_s))
    call cursor(nr_s, col_s+1)
    exe "normal ".xlen."x"
endfunction


"사용자로 부터 패턴-pair를 입력받아 지운다
function! RemoveFromUserInput()
    let str1 = input("block marker string1? ")
    let str2 = input("block marker string2? ")

    call RemoveMatchPattern(str1,str2)
endfunction


"upper scope로 이동
"옮기기 전 위치는 x로 bookmark
function! MoveToUpperScope()
    exe "normal mx"
    exe "normal [{"
endfunction


"upper scope에 name이름을 가진 변수를 선언한다
function! InsertDeclaration(name)
    call MoveToUpperScope()
    "
    "다음 줄 검사
    call FindLastContinuousLinePatternMisMatch('^[ \t]*[a-zA-Z]', 1)

    while 1
        let tn = input("Enter type? ")
        if strlen(tn) != 0
            break
        endif
    endwhile

    if strlen(a:name) == 0
        let vn = input("Enter var name? ")
    else
        let vn = a:name
    endif

    let sp=" "
    if strpart(tn, strlen(tn)-1, 1) == "*"
        let sp = ""
    endif
    exe "normal o".tn.sp.vn.";\e"
endfunction

" string에서 입력으로 주어진 character를 seperator로 하여
" 해당 token 값을 return
" @param    input_string    원본 string
" @param    token           seperator로 사용할 문자
" @param    index           몇번째 인자인가? 1부터 시작
" @return   해당 토큰이 없으면 empty string
" @warning  줄끝은 seperator에 포함되지 않음
function! GetTokenizedString(input_string, seperator, index)
    if (a:index <= 0)
        return ""
    endif

    let prev_idx = 0
    let next_idx = -1
    let cnt = 0
    while 1
        let idx = stridx(a:input_string, a:seperator, prev_idx)
        if (idx < 0) 
            return ""
        endif

        let next_idx = idx
        let cnt = cnt + 1

        if (cnt >= a:index)
            break
        endif

        let prev_idx = next_idx + 1
    endwhile

    return strpart(a:input_string, prev_idx, next_idx - prev_idx)
endfunction

"커서가 위치한 단어가 foo_bar_[ste]로 끝나는 struct이름일 경우 foo_bar_[ste]로 변환
function! ConvertCwordToTbType()
    let word=expand('<cword>')
    if match(word,'_[steu]$') == -1
        return
    endif

    return substitute(word,'_[steu]$','_[steu]','')
endfunction

