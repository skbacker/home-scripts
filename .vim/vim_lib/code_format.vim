
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



"���� Ŀ����ġ����, structName�� ���ʷ� ifndef-typedef-endif �߰�
function! InsertTypeDef(structName)
    let capName=toupper(a:structName)
    exe "normal " . "0Di#ifndef _".capName."_T\n"
    exe "normal " . "0Di#define _".capName."_T\n"
    exe "normal " . "0Ditypedef struct ".a:structName."_s ".a:structName."_t;\n"
    exe "normal " . "0Di#endif\n\e"
endfunction

"���� Ŀ����ġ���� structName�� ���ʷ� struct{} �߰�
function! InsertStruct(structName)
    exe "normal " . "0Distruct ".a:structName."_s {\n"
    exe "normal " . "0Di};\e"
endfunction

"line_no�� �̵��Ͽ�, �Ʒ� ������ �Է�
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
"visual block���� ������ ���� �� �Ʒ���, string�� �����Ѵ�
" str1
" ... selected block ...
" ... selected block ...
" str2
function! InsertBlockString(str1,str2) range
    call append(a:lastline, a:str2)
    call append(a:firstline -1, a:str1)
    call cursor(a:firstline,0)
endfunction

" �Ʒ��� ���� ���� �߰� block���� �� �Լ��� �θ� ���, str1, str2 ������ �����ش�
" ����ϳ��� �������� �ʴ� ��� ������ �ʴ´�
"str1
"   In the Middle of Pattern 
"str2
function! RemoveBlockString(str1,str2)
    let nr_cur=line(".") 

    let nr_e = searchpair(a:str1,"",a:str2,"W")
    let nr_s = searchpair(a:str1,"",a:str2,"bW")

    "pair�� pattern�� �������� ������ �׳� return
    if nr_e == 0 || nr_s == 0
        return
    endif

    call cursor(nr_e,0)
    exe "normal dd"
    call cursor(nr_s,0)
    exe "normal dd"
    
    call cursor(nr_cur,0)
endfunction


"���� ��ġ ���� ���ӵ� ������ ���Ͽ� ������ ���Ͽ� �´� ������ ����ã��
"forward�� > 0 �̸� �Ʒ�������, < 0 �̸� �������� ã�´�
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

"���� ��ġ ���� ���ӵ� ������ ���Ͽ� ������ ���Ͽ� ���� �ʴ� ������ ����ã��
"forward�� > 0 �̸� �Ʒ�������, < 0 �̸� �������� ã�´�
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

"���� ������ ���� line�� ã�� ����. 
"Ŀ���� pattern ���ۺ� ó��,�߰�,����  �־�� ��
"#include...
"#include...
"#include...
"Ȥ��
"    abc_t
"    def_t
"���
function! SelectLineOfSamePattern(pattern)
    "move to last pattern
    call FindLastContinuousLinePatternMatch(a:pattern, 1)

    exe "normal v"

    "select to first pattern
    call FindLastContinuousLinePatternMatch(a:pattern, -1)
endfunction


"���� ��ġ����, ���� #include�� �ִ� ��ġ�� ã��,
"����� �Է����� header file�̸���, comment�� �޾� �ڵ�ϼ�
"���� Comment�� �Է����� ������, �ڵ����� header�����̸�_t�� ����
"��Ŀ��, ������ �����ϴ� ��ġ�� x�� ��� ���ұ� ������, mx
" ������� �Է��� ��ġ��, 'x�� ���ؼ� ���� ��ġ�� ���Ͱ����ϴ�
function! InsertIncludeHeader(comment)
    exe "normal mx"

    exe "normal gg"
    if search('^#include','W') == 0
        return
    endif

    "���� �� �˻�
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

"str1,str2�� pair�� �����ϴ��� �����ϰ�, str1,str2������ �����
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


"����ڷ� ���� ����-pair�� �Է¹޾� �����
function! RemoveFromUserInput()
    let str1 = input("block marker string1? ")
    let str2 = input("block marker string2? ")

    call RemoveMatchPattern(str1,str2)
endfunction


"upper scope�� �̵�
"�ű�� �� ��ġ�� x�� bookmark
function! MoveToUpperScope()
    exe "normal mx"
    exe "normal [{"
endfunction


"upper scope�� name�̸��� ���� ������ �����Ѵ�
function! InsertDeclaration(name)
    call MoveToUpperScope()
    "
    "���� �� �˻�
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

" string���� �Է����� �־��� character�� seperator�� �Ͽ�
" �ش� token ���� return
" @param    input_string    ���� string
" @param    token           seperator�� ����� ����
" @param    index           ���° �����ΰ�? 1���� ����
" @return   �ش� ��ū�� ������ empty string
" @warning  �ٳ��� seperator�� ���Ե��� ����
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

"Ŀ���� ��ġ�� �ܾ foo_bar_[ste]�� ������ struct�̸��� ��� foo_bar_[ste]�� ��ȯ
function! ConvertCwordToTbType()
    let word=expand('<cword>')
    if match(word,'_[steu]$') == -1
        return
    endif

    return substitute(word,'_[steu]$','_[steu]','')
endfunction

