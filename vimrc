" ~/.vim/vimrc
" ~.vim/vundle.vimrc
" ~/.vim/mac-alt-map.vimrc

" runtimepath管理 "{{{
set runtimepath-=~/.vim
set runtimepath+=~/.vim
set runtimepath-=~/.vim/bundle/vundle.vim
set runtimepath+=~/.vim/bundle/vundle.vim
"}}}

" 变量定义 {{{1
let s:W_TRUE  = 1
let s:W_FALSE = 0

let s:W_colorscheme_applied = 0
let s:W_last_filetype = ""
let s:W_last_insert_im_status = 0

let s:W_last_mark_idx = 5
let s:W_cscope_is_from_symbol = s:W_FALSE
" }}}1

" 函数定义 {{{1
" W_get_visual_selected_text {{{2
function! W_get_visual_selected_text()
    " Check if is in visual mode ?
    let l:reg_bakup = @x
    normal gv"xy
    let l:ret = @x
    let @x = l:reg_bakup
    return l:ret
endfunction
"}}}2
" W_mark: 高亮单词，用于替换Mark插件（Mark插件性能不行）{{{2
function! W_mark(str, is_a_word)
    let l:syn_num = 6
    let l:cur_syn = synIDattr(synID(line("."), col("."), 1), "name")
    if 0 == match(l:cur_syn, "W_MarkWord")
        "let s:W_last_mark_idx = (s:W_last_mark_idx + l:syn_num - 1) % l:syn_num
        execute 'syn match none /\<' . a:str . '\>/'
    else " Choose a color and mark a:str
        " 高亮的颜色，添加颜色时记得要更新l:syn_num的初始值"
        hi W_MarkWord0 ctermbg=Cyan    ctermfg=Black guibg=#8CCBEA guifg=Black
        hi W_MarkWord1 ctermbg=Green   ctermfg=Black guibg=#A4E57E guifg=Black
        hi W_MarkWord2 ctermbg=Yellow  ctermfg=Black guibg=#FFDB72 guifg=Black
        hi W_MarkWord3 ctermbg=Red     ctermfg=Black guibg=#FF7272 guifg=Black
        hi W_MarkWord4 ctermbg=Magenta ctermfg=Black guibg=#FFB3FF guifg=Black
        hi W_MarkWord5 ctermbg=Blue    ctermfg=White guibg=#9999FF guifg=Black

        let s:W_last_mark_idx = (s:W_last_mark_idx + 1) % l:syn_num
        let l:exec_str = 'syn match W_MarkWord' . s:W_last_mark_idx
        if s:W_TRUE == a:is_a_word
            execute l:exec_str . ' /\<' . a:str . '\>/'
        else
            execute l:exec_str . ' /' . a:str . '/'
        endif
    endif
endfunction
" }}}2
" W_source: source 一个文件 {{{2
function! W_source(file)
    if filereadable(a:file)
        source a:file
        return s:W_TRUE
    endif
    return s:W_FALSE
endfunction
" }}}2
" W_exec_cmd: execute an command{{{2
function! W_exec_cmd(cmd)
    if exists(a:cmd)
        source a:cmd
        return s:W_TRUE
    endif
    return s:W_FALSE
endfunction
" }}}2
" W_eatchar: 吃掉一个字符 {{{2
function! W_eatchar(char)
    let c = nr2char(getchar())
    return (c =~ a:char) ? '' : c
endfunction
" }}}2
" W_common_replace: 通用自动替换 {{{2
function! W_common_replace()
    "iabbrev ( ()<Left><C-r>=W_eatchar(')')<CR>
    "iabbrev [ []<Left><C-r>=W_eatchar(']')<CR>
    "iabbrev { {<CR>}<Esc>%a

    inoremap " ""<Left>
    inoremap ' ''<Left>
    inoremap ` ``<Left>
    inoremap ( ()<Left>
    inoremap [ []<Left>
    inoremap { {<CR>}<Esc>O
    inoremap <C-l> <Right>
endfunction
" }}}2
" W_C_replace: C语言自动替换 {{{2
function! W_C_replace()
    " 考虑到({等符号已成对匹配，以下替换也做了相应修改
    "iabbrev iff if ()<CR>{<CR>}<Esc>kk$i<C-r>=W_eatchar(' ')<CR>
    "iabbrev elsee else<CR>{<CR>}<Esc>O<C-r>=W_eatchar(' ')<CR>
    "iabbrev whilee while ()<CR>{<CR>}<Esc>kk$i<C-r>=W_eatchar(' ')<CR>
    "iabbrev fore for ()<CR>{<CR>}<Esc>kk$i<C-r>=W_eatchar(' ')<CR>
    "iabbrev doo do<CR>{<CR>}<CR>while ();<Left><Left><C-r>=W_eatchar(' ')<CR>

    iabbrev iff if (<C-o>o{<Esc>ddkk$i<C-r>=W_eatchar(' ')<CR>
    iabbrev forr for (<C-o>o{<Esc>ddkk$i<C-r>=W_eatchar(' ')<CR>
    iabbrev whilee while (<C-o>o{<Esc>ddkk$i<C-r>=W_eatchar(' ')<CR>
    iabbrev doo do<CR>{<Esc>ddowhile (<Right>;<Left><Left><C-r>=W_eatchar(' ')<CR>
    iabbrev elsee else<CR>{<C-r>=W_eatchar('')<CR>

    iabbrev inc #include <.h><Left><Left><Left><C-r>=W_eatchar(' ')<CR>
endfunction
" }}}2
" W_code_common_setting: 代码通用设置 {{{2
function! W_code_common_setting()
    syntax on
    set cindent
    set tabstop=4
    set shiftwidth=4
    set expandtab
    set nofoldenable

    "set cursorline
    "set colorcolumn=100

    " 显示特殊字符
    set list
    "set listchars=tab:\|\ ,trail:-,nbsp:%
    set listchars=tab:\|\ ,trail:•,nbsp:%
    " 警示行尾多余空格
    " match Error /\s\+$/
    " 显示缩进垂直对齐线
    "call W_exec_cmd("IndentLinesEnable")

    " 按<Leader><Leader>执行make并打开quickfix窗口
    " 然后跳到第一个错误处(如果有错误的话)
    nnoremap <Leader><SPACE> :make<CR><CR>:cw<CR>:cc<CR>

    " 将选中的代码按 '=' 对齐
    vnoremap <Leader>= :Tabularize /=<CR>

    " 快速插入函数注释头
    command! Ifc call W_insert_function_header('cn')
    command! Ife call W_insert_function_header('en')
    " 不知道为什么会多输出一个0,所以用<BS>删除
    inoremap <Leader>ifc <C-r>=W_insert_function_header('cn')<CR><BS><C-o>A
    inoremap <Leader>ife <C-r>=W_insert_function_header('en')<CR><BS><C-o>A

    call W_common_replace()
    call W_set_colorscheme("solarized")
endfunction
"}}}2
" W_set_guifont: 设置GUI字体{{{2
function! W_set_guifont()
    if !has("gui_running")
        return
    endif

    if has("macunix")
        "set guifont=Monaco\ for\ Powerline:h16,Monaco:h16
        set guifont=Monaco:h16
        " 单独设置中文字体
        " 备用字体
        " Hannotate\ SC\ Regular
        " Libian\ SC\ Regular
        " Yuanti\ SC\ Regular
        " Xingkai\ SC\ Light
        set guifontwide=Kaiti\ SC\ Regular
    else
        "YaHei Consolas Hybrid字体不知为何会使powerline的状态栏占用命令栏
        "set guifont=YaHei\ Consolas\ Hybrid\ 13
        "set guifont=Source\ Code\ Pro\ 13
        "set guifont=Courier\ 10\ Pitch\ 13
        set guifont=Consolas\ 13
    endif
endfunction
"}}}2
" W_color_modify: 颜色加减运算 {{{2
" 正确的实现方法: RGB->HSV,修改V值->RGB
function! W_color_modify(color, oper, modify_value)
    if a:color == ""
        " 返回红色以做告警
        return '#FF0000'
    endif

    if a:oper == 'add'
        let l:col_r = '0x' . strpart(a:color, 1, 2) + a:modify_value
        let l:col_g = '0x' . strpart(a:color, 3, 2) + a:modify_value
        let l:col_b = '0x' . strpart(a:color, 5, 2) + a:modify_value
    elseif a:oper == 'sub'
        let l:col_r = '0x' . strpart(a:color, 1, 2) - a:modify_value
        let l:col_g = '0x' . strpart(a:color, 3, 2) - a:modify_value
        let l:col_b = '0x' . strpart(a:color, 5, 2) - a:modify_value
    elseif a:oper == 'invert'
        let l:col_r = 0xff - ('0x' . strpart(a:color, 1, 2))
        let l:col_g = 0xff - ('0x' . strpart(a:color, 3, 2))
        let l:col_b = 0xff - ('0x' . strpart(a:color, 5, 2))
    else
        echom "W_color_modify: invalid oper"
        return a:color
    endif

    if l:col_r > 0xff | let l:col_r = 0xff | endif
    if l:col_g > 0xff | let l:col_g = 0xff | endif
    if l:col_b > 0xff | let l:col_b = 0xff | endif

    if l:col_r < 0 | let l:col_r = 0 | endif
    if l:col_g < 0 | let l:col_g = 0 | endif
    if l:col_b < 0 | let l:col_b = 0 | endif

    return '#' . printf("%02x", l:col_r) . printf("%02x", l:col_g) . printf("%02x", l:col_b)
endfunction
"}}}2
" W_set_colorscheme: 设置配色方案 {{{2
function! W_set_colorscheme(color)
    if ! has("gui_running")
        return
    endif

    let g:W_color_scheme = a:color
    "let g:W_color_scheme = "solarized"

    " 设置配色方案{{{3
    " 还可以的 light 主题 {{{
    " biogoo
    " bmichaelsen
    " colorful
    " colorzone
    " d8g_02
    " nedit2
    " pspad
    " smp
    " soso
    " [*****] newspaper
    " [*****] peaksea
    " Tomorrow-Night-Eighties
    " PapayaWhip
    "
    " 暗色配色方案：
    " anotherdark
    " bubblegum
    " carvedwood
    " chance-of-storm
    " codeschool
    " corn
    " corporation
    " darkburn
    " darkz
    " dusk
    " freya
    " hybrid
    " lilypink
    " lucius
    " Monokai
    " mint
    " mrpink
    " neon
    " peaksea
    " pf_earth
    " phd
    " railscasts
    " rainbow_neon
    " rdark
    " selenitic
    " settlemyer
    " sonofobsidian
    " sorcerer
    " southwest-fog
    " spectro
    " strawimodo
    " tango2
    " tchaba
    " two2tango
    " vilight
    " void
    " vydark
    " watermark
    " wolfasm (only aviliable in rmbp)
    " wombat
    " zenburn
    " kellys
    " mrpink
    " kib_darktango
    " kolor
    " lilypink
    " liquidcarbon
    " lucius
    " manuscript
    " native
    " nazca
    " southwest-fog
    "}}}
    syntax enable
    set background=dark
    execute 'colorscheme ' . g:W_color_scheme
    "execute 'source ' . g:W_color_scheme
    let s:W_colorscheme_applied = 1
    "}}}3

    " 调整配色方案{{{3
    if &background != 'dark'
        " 以下调整均针对 dark 类主题
        " light 类主题很少用，所以不进行调整
        return
    endif

    if g:W_color_scheme == "solarized"
        hi Normal   guibg=#00222C guifg=#A0B5B7
        hi Function gui=bold guifg=#2AA198
        hi Comment  guifg=#606F83
    elseif g:W_color_scheme == "gruvbox"
        hi cFunctions gui=bold guifg=#ffcc88 cterm=bold ctermfg=DarkBlue
        "hi Normal guibg=#303030
        hi String guibg=#373A17
        "hi Normal  guibg=#2D2C25
        "hi Normal  guibg=#252D2B
        hi Normal  guibg=#18261D
    elseif g:W_color_scheme == "neon"
        hi Folded  guibg=#003040 guifg=Grey
        hi Comment guifg=#909090
        hi NonText guibg=#282828
        "hi String guifg=#80BADF guibg=#2A3A45
    elseif g:W_color_scheme == "yeller"
        hi Normal   guibg=#16241B
        hi Function guifg=#73BD93
    endif

    if has("gui_running")
        let l:normal_bg = synIDattr(hlID("Normal"), "bg#", "gui")
        let l:normal_fg = synIDattr(hlID("Normal"), "fg#", "gui")

        " LineNr/CursorLineNr
        execute 'hi LineNr       guibg=' . W_color_modify(l:normal_bg, 'add', 0x6) 'guifg=' . W_color_modify(l:normal_bg, 'add', 0x70)
        execute 'hi CursorLineNr guibg=' . l:normal_bg . ' gui=none' 'guifg=' . W_color_modify(l:normal_bg, 'add', 0x90)

        " StatusLine/StatusLineNC
        execute 'hi StatusLine   gui=none' 'guibg=' . W_color_modify(l:normal_bg, 'add', 0x1D) 'guifg=' . W_color_modify(l:normal_bg, 'add', 0x88)
        execute 'hi StatusLineNC gui=none' 'guibg=' . W_color_modify(l:normal_bg, 'add', 0x10) 'guifg=' . W_color_modify(l:normal_bg, 'add', 0x70)

        execute 'hi VertSplit    guibg=' . W_color_modify(l:normal_bg, 'add', 0x1A) 'guifg=' . W_color_modify(l:normal_bg, 'add', 0x45)

        execute 'hi Function     gui=bold'
        hi! link vimFunction Function
        execute 'hi Constant     guibg=' . W_color_modify(l:normal_bg, 'add', 0xA)

        " SpecialKey/Conceal
        " SpecialKey for chars setting by (:set listchars)
        execute 'hi SpecialKey gui=bold guibg=' . l:normal_bg ' guifg=' . W_color_modify(l:normal_bg, 'add', 0x48)
        " Conceal for indentline plugin
        hi! link Conceal SpecialKey

        " Folded
        execute 'hi Folded guibg=' . W_color_modify(l:normal_bg, 'add', 0x20)

        " Pmenu/PmenuSel/ColorColumn
        "hi! link Pmenu LineNr
        "hi! link PmenuSel Cursor
        execute 'hi Pmenu gui=NONE guibg=' . W_color_modify(l:normal_bg, "add", 0x10) 'guifg=' . W_color_modify(l:normal_fg, 'sub', 0x25)
        execute 'hi PmenuSel guibg=' . W_color_modify(l:normal_bg, 'add', 0x25) 'guifg=' . W_color_modify(l:normal_fg, 'add', 0x30)
        hi! link ColorColumn Pmenu

        " Visual
        hi Visual NONE
        execute 'hi Visual guibg=' . W_color_modify(l:normal_bg, 'add', 0x25)

        " TabLine/TabLineSel/TabLineFill
        let l:tmp_color = W_color_modify(l:normal_bg, 'add', 0x20)
        execute 'hi TabLine     gui=none guibg=' . l:tmp_color . ' guifg=' . l:normal_fg
        execute 'hi TabLineFill gui=none guibg=' . l:tmp_color . ' guifg=' . l:tmp_color
        execute 'hi TabLineSel  gui=bold guibg=' . l:normal_bg . ' guifg=#D2A458'

        " Search/Cursor
        "hi Search NONE
        "hi Search gui=reverse
        let l:tmp_color = synIDattr(hlID("String"), "fg#", "gui")
        if l:tmp_color != ""
            execute 'hi Search gui=NONE guifg=#222222 guibg=' . l:tmp_color
        endif
        hi Cursor NONE
        hi Cursor gui=reverse
    else
        hi Pmenu    ctermbg=0 ctermfg=7
        hi PmenuSel ctermbg=1 ctermfg=8

        hi Visual NONE
        hi Visual cterm=reverse term=reverse

        hi Search NONE
        hi Search term=reverse cterm=reverse

        hi Cursor NONE
        hi Cursor term=reverse cterm=reverse
    endif

    " }}}3
    " 重新加载mark.vim（否则mark.vim将失效） {{{3
    " 下面的autocmd命令无预期效果, why?
    " autocmd ColorScheme * source  ~wolfwzr/.vim/bundle/Mark/plugin/mark.vim
    " call W_source("~wolfwzr/.vim/bundle/Mark/plugin/mark.vim")
    if s:W_TRUE == W_source("~/.vim/bundle/rainbow/plugin/rainbow.vim")
        RainbowLoad
    endif
    " }}}3
endfunction
call W_set_colorscheme("solarized")
" }}}2
" W_filetype_setting: FileType处理 {{{2
function! W_filetype_setting()
    " 避免重复设置{{{
    if &filetype == ""                      || &filetype == s:W_last_filetype    || s:W_last_filetype == "man"        || &filetype == "man"       || s:W_last_filetype == "help"       || &filetype == "help"      || s:W_last_filetype == "qf"         || &filetype == "qf"        || s:W_last_filetype == "tarbar"     || &filetype == "tagbar"    || s:W_last_filetype == "nerdtree"   || &filetype == "nerdtree"
        let s:W_last_filetype = &filetype
        return
    endif
    "}}}

    " C/CPP/H/NASL/LEX/YACC/BISON/JAVA {{{3
    if &filetype == "c"     || &filetype == "h"     || &filetype == "cpp"   || &filetype == "nasl"  || &filetype == "lex"   || &filetype == "yacc"  || &filetype == "bison" || &filetype == "java"
        if s:W_last_filetype == "c"     || s:W_last_filetype == "h"     || s:W_last_filetype == "cpp"   || s:W_last_filetype == "nasl"  || s:W_last_filetype == "lex"   || s:W_last_filetype == "yacc"  || s:W_last_filetype == "bison" || s:W_last_filetype == "java"
            let s:W_last_filetype = &filetype
            return
        endif
        " 因为在cscope中跳转回来时打开的折叠又变为折叠，所以默认关闭折叠
        set foldmethod=syntax
        call W_code_common_setting()

        " 用缩写(abbreivations)自定义代码块的补全
        " source ~/usr/etc/abbreviations.vim

        " gruvbox (要使这个主题生效，得先设置主题为greyblue)
        "call W_set_colorscheme("greyblue")
        "call W_set_colorscheme("gruvbox")
        "call W_set_colorscheme("yeller")
        call W_set_colorscheme("solarized")

        "setlocal cc=100
        highlight WarningCols gui=undercurl
        match WarningCols /\%>100v/

        call W_C_replace()
    " ASM {{{3
    elseif &filetype == "asm"
        set foldmethod=marker
        set commentstring=;%s
        call W_code_common_setting()

        "call W_set_colorscheme("rainbow_neon")
        setlocal syntax=nasm
        if has("gui_running")
            "call W_exec_cmd("IndentLinesDisable")
            setlocal nolist
        endif
    " PYTHON {{{3
    elseif &filetype == "python"
        set foldmethod=indent
        call W_code_common_setting()
    " SH {{{3
    elseif &filetype == "sh"
        set foldmethod=indent
        call W_code_common_setting()
        "call W_set_colorscheme("neon")
        inoremap { {}<Left>
    " VIM {{{3
    elseif &filetype == "vim"
        set foldmethod=marker
        call W_code_common_setting()
        call W_set_colorscheme("codeschool")
        "call W_set_colorscheme("solarized")
    " MKD {{{3
    elseif &filetype == "mkd"
        call W_code_common_setting()
        setlocal foldenable
        setlocal nonu
        setlocal norelativenumber
        call W_set_colorscheme("two2tango")
    " HTML/XML/CSS/JS/XSL/XSLT {{{3
    elseif &filetype == "html"  || &filetype == "xml"   || &filetype == "css"   || &filetype == "js"    || &filetype == "xsl"   || &filetype == "xslt"
        if s:W_last_filetype == "html"  || s:W_last_filetype == "xml"   || s:W_last_filetype == "css"   || s:W_last_filetype == "js"    || s:W_last_filetype == "xsl"   || s:W_last_filetype == "xslt"
            let s:W_last_filetype = &filetype
            return
        endif
        call W_code_common_setting()
        "call W_set_colorscheme("corn")
    " CONF {{{3
    elseif &filetype == "conf"
        call W_code_common_setting()
    endif
    " }}}3
    let s:W_last_filetype = &filetype
    silent! PowerlineReloadColorscheme
endfunction
" }}}2
" W_insert_function_header: 设置GUI字体{{{2
function! W_insert_function_header(lang)
    let b:reg_bakup = @a
    "中文版{{{
    if a:lang == 'cn' 
        let @a="/*************************************************************************\n 函数名称: \n 功能描述: \n 输入参数: \n 输出参数: \n 返 回 值: \n ------------------------------------------------------------------------\n 最近一次修改记录:\n 修改作者: wangzhengrong\n 修改目的: 定义函数\n 修改日期: "
    "}}}
    "英文版{{{
    elseif a:lang == 'en'
        let @a="/*************************************************************************\n Name        : \n Function    : \n Input Args  : \n Output Args : \n Return Value: \n ------------------------------------------------------------------------\n Lastest Modify Record:\n Author : wangzhengrong\n Purpose: create function\n Date   : "
    endif
    "}}}
    normal "ap10j
    execute 'r!date +\%F'
    normal kJ
    let @a="*************************************************************************/\n"
    normal "ap10k$
    let @a = b:reg_bakup
endfunction
"}}}2
" W_winpos_adjust: 调整GVIM窗口坐标 {{{2
function! W_winpos_adjust(x_inc, y_inc)
    let l:winpos_x = getwinposx() + a:x_inc
    let l:winpos_y = getwinposy() + a:y_inc
    execute 'winpos '.l:winpos_x.' '.l:winpos_y
endfunction
" }}}2
" W_dict_qurey: 单词字典查询 {{{2
function! W_dict_qurey(word)
    if a:word == ""
        return
    endif

    let l:tmp_file_prefix = "/tmp/vim_dict_"

    " 备份寄存器a
    let l:bakup_reg_a = @a

    if has("unix")
        " sdcv -n: 非交互模式
        let @a = system('sdcv -n --utf8-input --utf8-output '.a:word)
    else
        let @a = l:bakup_reg_a
        return
    endif

    let l:nr = bufwinnr(l:tmp_file_prefix . "*")
    if l:nr != -1
        execute nr . "wincmd w"
        normal ggVGd
    else
        " mktemp -u 只会生成文件名，不会创建文件
        execute "split" . system("mktemp -u ". l:tmp_file_prefix . "XXXXXXX")
    endif
    normal "ap

    nnoremap <buffer> q :q!<CR>
    nnoremap <buffer> <SPACE> :call W_dict_qurey('<C-r>=expand("<cword>")<CR>')<CR>
    nnoremap <buffer> <S-SPACE> <C-o>

    " 恢复寄存器a
    let @a = l:bakup_reg_a
endfunction
" }}}2
" W_grep: grep in current buffer{{{2
" Use Bgrep command(in Bgrep plugin) to grep with all buffers
function! W_grep(word)
    call setqflist([])
    silent execute "g/" . a:word . "/if &buftype == '' | call setqflist([{'type': 'l', 'col':1, 'bufnr': winbufnr('.'), 'lnum': line('.'), 'text':getline('.')}], 'a') | endif"
    botright cw
endfunction
" }}}2
" W_cscope_init_db: init cscope database {{{2
function! W_cscope_init_db()
    let l:cwd_bakup = fnameescape(getcwd())
    let l:tmp_dir = ''
    let l:find_db = 0

    " kill all connections
    cs kill -1

    " search the first database from current directory up to '/'
    " load the database and change CWD to that directory
    while l:tmp_dir != '/'
        let l:tmp_dir = fnameescape(getcwd())
        if isdirectory(l:tmp_dir)
            if filereadable(l:tmp_dir . '/cscope.out')
                cs add ./cscope.out
                let l:find_db = 1
                break
            endif
        else
            break
        endif
        " go to parrent directory
        if isdirectory(l:tmp_dir . '/..')
            execute 'cd ' . l:tmp_dir . '/..'
        endif
    endwhile

    if find_db == 0
        " go to origin directory if no database found
        if isdirectory(l:tmp_dir . '/..')
            execute 'cd ' . l:cwd_bakup
        endif
        if $CSCOPE_DB != ""
            " add database pointed to by environment
            cs add $CSCOPE_DB
        endif
    endif
endfunction
" }}}2
" W_cscope_update_db: update cscope database {{{2
function! W_cscope_update_db()
    call system('cscope -Rbq')
    cs reset
endfunction
" }}}2
" W_font_review: 临时在vim中预览字体效果 {{{2
"用法，先创建一个快捷键Ctrl+Enter来执行当前行命令
" nmap <C-Enter> j$v^<S-Enter>:<S-Enter><CR>
" 再查找出当前系统字体，linux下可运行如下命令：
" fc-list  | awk -F ':' '{print $2}' | sed 's/,/\n/g' | sort | uniq| sed 's/^ *//g;s/ *$/\ 14/g;s/ /\\ /g;s/^/set guifont=/g' > /tmp/pwall
" 我是通过man -k font,在里面找到fc-list命令的。
function! W_font_review()
    nmap <C-Enter> j$v^<S-Enter>:<S-Enter><CR>

    " 比较好的字体
    set guifont=YaHei\ Consolas\ Hybrid\ 14
    set guifont=Courier\ 10\ Pitch\ 14
    set guifont=Inconsolata\-dz\ for\ Powerline\ 14
    set guifont=Source\ Code\ Pro\ 14
    set guifont=SimSun\ 16

    " 一般的字体
    set guifont=Anonymice\ Powerline\ 15
    set guifont=Anonymous\ Pro\ for\ Powerline\ 15
    set guifont=Inconsolata\ for\ Powerline\ 16
    set guifont=Meslo\ LG\ L\ DZ\ for\ Powerline\ 13
    set guifont=Meslo\ LG\ L\ for\ Powerline\ 13
    set guifont=Meslo\ LG\ M\ DZ\ for\ Powerline\ 13
    set guifont=Meslo\ LG\ M\ for\ Powerline\ 13
    set guifont=Meslo\ LG\ S\ DZ\ for\ Powerline\ 13
    set guifont=Meslo\ LG\ S\ for\ Powerline\ 13
    set guifont=YaHei\ Consolas\ Hybrid\ for\ Powerline\ 14
    set guifont=Adobe\ Courier\ 14
    set guifont=B&H\ LucidaTypewriter\ 13
    set guifont=Bitstream\ Terminal\ 14
    set guifont=Courier\ 14
    set guifont=Droid\ Sans\ Mono\ 14
    set guifont=DejaVu\ Sans\ Mono\ 14
    set guifont=FreeMono\ 14
    set guifont=Liberation\ Mono\ 14
    set guifont=Luxi\ Mono\ 14
    set guifont=Misc\ Fixed\ 15
    set guifont=Sony\ Fixed\ 15
    set guifont=Source\ Code\ Pro\ Black\ 14
    set guifont=Source\ Code\ Pro\ ExtraLight\ 14
    set guifont=Source\ Code\ Pro\ Light\ 14
    set guifont=Source\ Code\ Pro\ Semibold\ 14
    set guifont=Ubuntu\ Mono\ 14
endfunction
"}}}2
" W_set_fcitx: Insert/Normal模式切换时自动切换fcitx状态{{{2
function! W_set_fcitx(event)
    if a:event == "InsertEnter"
        if s:W_last_insert_im_status == 1       " fcitx is inactive
            call system("fcitx-remote -c")      " inactive fcitx
        elseif s:W_last_insert_im_status == 2   " fcitx is active
            call system("fcitx-remote -o")      " active fcitx
        endif
    elseif a:event == "InsertLeave"
        if executable("fcitx-remote")
            let s:W_last_insert_im_status = system("fcitx-remote | tr -d '\r\n'")
        endif
        if s:W_last_insert_im_status == 2       " fcitx is active
            call system("fcitx-remote -c")      " inactive fcitx
        endif
    endif
endfunction
"}}}2
" W_cscope_lookup_define_or_symbol: 使用cscope查询定义或符号{{{2
" 使用 cscope 查询，先查询符号定义，若查到则跳到定义处，
" 若没有查到，则查询符号引用处并跳到第一个引用的地方。
function! W_cscope_lookup_define_or_symbol(pattern)
    let l:msg_bakup = v:errmsg
    let v:errmsg = ""
    execute "cs find g " . a:pattern
    if v:errmsg == ""
        let v:errmsg = l:msg_bakup
    else
        execute "cs find s " . a:pattern
        let s:W_cscope_is_from_symbol = s:W_TRUE
    endif
endfunction
"}}}2
" W_cscope_back: 针对W_cscope_lookup_define_or_symbol函数的返回{{{2
function! W_cscope_back()
    if s:W_cscope_is_from_symbol == s:W_TRUE
        execute "normal \<C-o>"
        let s:W_cscope_is_from_symbol = s:W_FALSE
    else
        execute "normal \<C-t>"
    endif
endfunction
"}}}2
"}}}1

" 基础设置 {{{1
" 设置显示相对行号，方便jk跳转 "{{{
set relativenumber
set number
"}}}
" runtimepath管理 "{{{
set runtimepath-=~/.vim
set runtimepath+=~/.vim
set runtimepath-=~/.vim/bundle/vundle.vim
set runtimepath+=~/.vim/bundle/vundle.vim
"}}}
" VI兼容性设置 {{{2
set nocp
" }}}2
" mapleader设置 {{{2
let mapleader='\'
" }}}2
" 搜索效果设置 {{{2
set hlsearch
set incsearch
" }}}2
" 设置新建窗口时新窗口的位置 {{{2
set splitbelow
set splitright
" }}}2
" 退格键设置(设置<BS>可删除的内容） {{{2
set backspace=indent,eol,start
" }}}2
" 文件编码设置 "{{{
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,default,latin1
"}}}
" 状态栏设置 {{{2
set laststatus=2   " Always show the statusline
" 使用powerline代替
hi StatusLine cterm=bold gui=bold
set statusline=%f\ %r\ %m\ %q%=[%Y,%{&fileencoding},%{&fileformat}]\ [%l,%02v]\ [%L,%02P]
" }}}2
" 打开文件时恢复光标位置 {{{2
if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
endif
" }}}2
" 空格与Tab相关{{{2
" Tab占四个空格的长度
set ts=4
" 显示特殊字符（listchars选项所配置的特殊字符）
set nolist
" 配置要显示的特殊字符
set listchars=tab:\|\ ,nbsp:%,trail:-
" 配置特殊字符显示配色
" hi SpecialKey ...
" 醒目显示行尾多余空格
" match Error /\s\+$/
" }}}2
" 输入法切换设置{{{2
" 切换到Normal模式时自动使用英文输入法
" 切换到Insert模式时自动使用上次在Insert模式下使用的输入法
if has("macunix")
    set noimdisable
elseif has("unix")
    au InsertEnter * call W_set_fcitx("InsertEnter")
    au InsertLeave * call W_set_fcitx("InsertLeave")
endif
"}}}2
" 鼠标设置{{{2
set mouse=a
" mousemodel 设置为 popup 时：
" 单击左键   - 光标跳转
" 单击右键   - 弹出菜单
" 拖动左键   - 选择文本
" 双击左键   - 选择单词
" Ctrl+左键  - Ctrl+]
" Ctrl+右键  - Ctrl+t
" Shift+左键 - 拓展选区
" Shift+右键 - 搜索单词
set mousemodel=popup
" 可用作 keymap 的鼠标动作
"
" ScrollWheel: (help scroll-mouse-wheel)
" <ScrollWheelUp>
" <ScrollWheelDown>
" <ScrollWheelLeft>
" <ScrollWheelRight>
"
" :help <MiddleRelease>
" code            mouse button               normal action
" <LeftMouse>     left pressed               set cursor position
" <LeftDrag>      left moved while pressed   extend selection
" <LeftRelease>   left released              set selection end
" <MiddleMouse>   middle pressed             paste text at cursor position
" <MiddleDrag>    middle moved while pressed -
" <MiddleRelease> middle released            -
" <RightMouse>    right pressed              extend selection
" <RightDrag>     right moved while pressed  extend selection
" <RightRelease>  right released             set selection end

" double click
nmap <2-LeftMouse> <Leader>m

nmap <S-ScrollWheelUp>   <C-o>
nmap <S-ScrollWheelDown> <C-i>

" Auto copy on select
"vnoremap <LeftRelease> "+ygv<LeftRelease>
"vnoremap v             "+y
"set go+=P

"}}}2
" 杂项设置{{{2
set wrap
" 取消CursorLine
" 因为我喜欢CursorLine有淡淡的背景色，但这样会有两个问题：
"   1. 当前行被 mark.vim 加背景色的单词背景变全黑，非常难看
"   2. 影响VIM效率
" 因此取消了CursorLine
set nocursorline
if version >= 703
    call system("mkdir -p ~/.vim/.undo")
    set undofile
    set undodir=~/.vim/.undo
endif
" }}}2
" }}}1

" Vundle及插件设置入口 {{{1
" ~/.vim/bundle/Vundle.vim/Vundle.vimrc
" Vundle是一个管理插件的插件
" 这里配置文件里面包含了各个插件的配置
source ~/.vim/bundle/vundle.vim/vundle.vimrc
" }}}1

" 快捷键设置 {{{1

" 重设字体 (Bug?){{{
" 不知为何，当打开一些没有特殊处理的类型文件时
" （不在 W_filetype_setting 函数处理的类型）
" 偶尔会出现状态栏位于最底一行，把命令行给侵占了
" 通过debug发现重现设置字体能解决这问题。于是有了这个快捷键
" 但根本原因还是未找到，为何字体会造成这样的影响？
" !!!!!更新，最新观察，似乎是因为字体引起的，YaHei字体会出现这个问题
" 换成其它字体后到目前为止没再出现过,且Mac上一直没有出现过。
" nnoremap <Leader>1 :call W_set_guifont()<CR>
" }}}

" hardmode {{{2
" 用 <C-h> 代替 <BS>, <C-w> 还可以直接删除一个word
" 等熟练使用后可以将<BS>映射为删除整行 <ESC>^C
" inoremap <BS> <NOP>
" cnoremap <BS> <NOP>
" }}}2

" 翻页设置 {{{2
"nnoremap <SPACE> <C-f>
"nnoremap <TAB> <C-b>
" }}}2

" 快速查看QuickFix List的上一项/下一项 {{{2
if has("gui_running")
    nnoremap <F2> :botright cw<CR>
    nnoremap <F3> :cp<CR>
    nnoremap <F4> :cn<CR>

    nnoremap <Leader>q :botright cw<CR>
    nnoremap <Leader>] :cn<CR>
    nnoremap <Leader>[ :cp<CR>

    " Tips:
    "   :colder 查看上一个quickfix窗口
    "   :cnewer 查看下一个quickfix窗口
endif
" }}}2

" {}()跳转 {{{2
"   跳到上一个或下一个位于行首的{或}
"   [[ 跳到上一个位于行首的{（默认行为）
"   [] 跳到上一个位于行首的}（默认行为）
"   ][ 跳到下一个位于行首的{（默认行为）
"   ]] 跳到下一个位于行首的}（默认行为）
" 补充：
" 当光标在一个{}块内部时:
"   [{ 上跳到{处（默认行为）
"   ]} 下跳到}处（默认行为）
" 当光标在一个()块内部时:
"   [( 上跳到(处（默认行为）
"   ]) 下跳到)处（默认行为）
" 当光标在一个{}/()/[]的一边上时:
"   % 跳到另一边（默认行为）
nnoremap ][ ]]
nnoremap ]] ][
" }}}2

" Tab/Window/GUI窗口相关{{{2
if has("gui_running")
    " Tab Navigate
    nnoremap <C-j>     :tabnext<CR>
    nnoremap <C-k>     :tabprev<CR>
    " Duplication current window to a new tab
    nnoremap <C-n>     :tabnew %<CR>

    " Window跳转 {{{
    nnoremap <Leader>j <C-w>j
    nnoremap <Leader>k <C-w>k
    nnoremap <Leader>h <C-w>h
    nnoremap <Leader>l <C-w>l
    "}}}

    if has("macunix")
        " 调整GVIM窗口大小 {{{
        "nmap <C-j> :set lines+=1<CR>
        "nmap <C-k> :set lines-=1<CR>
        "nmap <C-h> :set columns-=3<CR>
        "nmap <C-l> :set columns+=3<CR>
        " }}}
    else
        " 调整GVIM窗口大小 {{{
        nmap <A-j> :set lines+=1<CR>
        nmap <A-k> :set lines-=1<CR>
        nmap <A-h> :set columns-=3<CR>
        nmap <A-l> :set columns+=3<CR>
        "}}}
        " 调整GVIM窗口位置 {{{
        nmap <A-S-j> :call W_winpos_adjust(0,10)<CR>
        nmap <A-S-k> :call W_winpos_adjust(0,-10)<CR>
        nmap <A-S-h> :call W_winpos_adjust(-20,0)<CR>
        nmap <A-S-l> :call W_winpos_adjust(20,0)<CR>
        " }}}
    endif
endif
" }}}

" 复制/剪切/粘贴 {{{2
if has("gui_running")
    if ! has("maxunix")
        vnoremap <C-c> "+y
        vnoremap Y     "+y
        vnoremap <C-x> "+x
        vnoremap X     "+x
        inoremap <C-v> <Space><BS><Esc>:set paste<CR>a<C-R>+<Esc>:set nopaste<CR>a
        cnoremap <C-v> <C-r>+
    endif
endif
" }}}2
"
" 以 root 权限保存文件 {{{2
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!
" }}}2

" 代码折叠快捷键 {{{2
" zi : set foldenable!
" za : toggle fold
" zo : open fold
" zc : close fold
" nnoremap <Leader><SPACE> @=((foldclosed(line('.'))<0)?'zc':'zo')<CR>
" nnoremap <Leader><SPACE> za
" }}}2

" 查看当前光标下单词的帮助信息 {{{2

" VIM的帮助信息 {{{3
nnoremap <Leader>h :help <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>H :help <C-R>=expand("<cWORD>")<CR><CR>

nnoremap <F1>   :help <C-R>=expand("<cword>")<CR><CR>
nnoremap <S-F1> :help <C-R>=expand("<cWORD>")<CR><CR>
" }}}3

" linux的man手册 {{{3
runtime ftplugin/man.vim
nnoremap K :Man <C-r>=expand("<cword>")<CR><CR>
" use <Leader>[0-9] ?
nnoremap <Leader>sm0 :Man 0 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm1 :Man 1 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm2 :Man 2 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm3 :Man 3 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm4 :Man 4 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm5 :Man 5 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm6 :Man 6 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm7 :Man 7 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm8 :Man 8 <C-r>=expand("<cword>")<CR><CR>
nnoremap <Leader>sm9 :Man 9 <C-r>=expand("<cword>")<CR><CR>
" }}}3

" 单词字典查询 {{{3
command! -nargs=1 Sdcv call W_dict_qurey("<args>")
nnoremap <Leader>d :Sdcv '<C-R>=expand("<cword>")<CR>'<CR>
" }}}3

" Buffer Grep {{{3
" 在当前Buffer中Grep
nnoremap <Leader>g :g/\<<C-R>=expand("<cword>")<CR>\>/p<CR>
vnoremap <Leader>g :<C-u>g/<C-R>=W_get_visual_selected_text()<CR>/p<CR>

command! -nargs=1 Grep call W_grep("<args>")
nnoremap <Leader>G :call W_grep('\<<C-R>=expand("<cword>")<CR>\>')<CR>
vnoremap <Leader>G :<C-u>call W_grep('<C-R>=W_get_visual_selected_text()<CR>')<CR>
" 在所有Buffer中Grep
" nnoremap <Leader>G :Bgrep <C-R>=expand("<cword>")<CR><CR>
" }}}3

" }}}2

" 快速预览当前光标下的 ColorScheme {{{2
noremap <Leader>C :color <C-r>=expand("<cWORD>")<CR><CR>
" }}}2

" cmdline模式下的光标移动 {{{2
if has("gui_running")
    " Tips:
    "
    " C-d : Show available completion
    " C-f : go to command line window
    "
    " C-i : <Tab>
    " C-n : <Tab> else <Down>
    " C-p : <S-Tab> else <Up>
    "
    " C-h : backspace
    " C-u : delete whole line
    " C-w : delete one word
    "
    " C-b : cursor to Begin of command-line
    " C-e : cursor to End of command-line

    cnoremap <C-j> <Right>
    cnoremap <C-k> <Left>
    cnoremap <C-l> <Del>
endif
" }}}2

" MacVim alt键映射 {{{2
if has("gui_running") && has("macunix")
    " MacVim无法映射alt键(<A-,<M-)都不行
    " 但可以通过直接输入<A-x>(在键盘上按住alt再按x键，得到一个乱码字符）得到
    " 于是可以通过 nmap ê <C-w>j 来创建映射
    " 但直接写在本文件中无效，在新文件中有效,所以将Mac下的alt映射放在新文件中
    " 猜测可能是因为本文件包含中文的原因，新文件中若不包含中文就有效
    source ~/.vim/mac-alt-map.vimrc
endif
" }}}2

" Quick Edit/Source vimrc{{{
command! EditRc   :tabnew ~/.vim/vimrc
command! SourceRc :source ~/.vim/vimrc
"}}}

" 刷新 ColorScheme {{{
"nmap <Leader>c :call W_set_colorscheme(g:W_color_scheme)<CR>
"}}}"

" Mark 当前单词 {{{
nmap <Leader>m :call W_mark(expand("<cword>"), 1)<CR>
vmap <Leader>m :call W_mark(W_get_visual_selected_text(), 0)<CR>
"}}}

" 删除当前 buffer {{{
nmap <Leader><BS> :bdelete %<CR>
"}}}

" 其它 {{{
nmap <Leader>c :echo synIDattr(synID(line("."), col("."), 1), "name")<CR>
"}}}"
" }}}1

" 文件类型相关设置 {{{1
if has("autocmd")
    " 指定某些后缀的文件类型
    autocmd BufRead,BufNewFile *.wsgi               set filetype=python
    autocmd BufRead,BufNewFile *.bashrc             set filetype=sh
    autocmd BufRead,BufNewFile *.vimrc              set filetype=vim
    autocmd BufRead,BufNewFile *.{nasl,inc}         set filetype=nasl
    autocmd BufRead,BufNewFile *.{md,mkd,markdown}  set filetype=mkd

    " 根据不同的文件类型做不同的设置
    "autocmd VimEnter * call W_filetype_setting()
    autocmd BufEnter  * call W_filetype_setting()
    nnoremap <Leader>w :call W_filetype_setting()<CR>

    " CommandLine Windows <CR>可以被映射成其它用途了，所以使用'o'来执行命令
    autocmd CmdWinEnter : nnoremap <buffer> o <CR>

    " 根据不同的文件类型设置按键映射
    augroup filetype_autocmd
        autocmd FileType c,cpp,h,flex,bison,yacc,asm,nasl nnoremap <buffer> <SPACE>             :call W_cscope_lookup_define_or_symbol('<C-R>=expand("<cword>")<CR>')<CR>| nnoremap <buffer> <S-SPACE>           :call W_cscope_back()<CR>| nnoremap <buffer> <S-CR>              :Csg .*.*<Left><Left>| nnoremap <buffer> <C-CR>              :Csg <C-r>+<CR>| nmap     <buffer> <C-LeftMouse>       <SPACE>| nmap     <buffer> <C-ScrollWheelUp>   <Leader>fc| nmap     <buffer> <C-ScrollWheelDown> <Leader>fs
        autocmd FileType help nnoremap <buffer> <SPACE>             <C-]>| nnoremap <buffer> <S-SPACE>           <C-t>| nnoremap <buffer> <BS>                <C-t>| nnoremap <buffer> q                   :q<CR>| set ts=4
        autocmd FileType vim nmap     <buffer> <C-LeftMouse>       <Leader>h| nmap     <buffer> <SPACE>             <Leader>h| nnoremap <buffer> <S-SPACE>           <C-t>| nnoremap <buffer> <BS>                <C-o>| nnoremap <buffer> <C-CR>              :<C-r>+<CR>
        autocmd FileType mkd nnoremap <buffer> <F5>                :!mkd_preview.sh %<CR>| nnoremap <buffer> <C-t>               :Toch<CR>| nnoremap <buffer> o                   A<CR>
        autocmd FileType qf nnoremap <buffer> o                   <CR>| nmap     <buffer> <2-LeftMouse>       o| nnoremap <buffer> q                   :q<CR>| resize 5
        autocmd FileType man nnoremap <buffer> <SPACE>             :Man <C-r>=expand("<cword>")<CR><CR>| nnoremap <buffer> <S-SPACE>           <C-o>| nmap     <buffer> <2-LeftMouse>       <SPACE>| nnoremap <buffer> q                   :q<CR>| setlocal ts=8
    augroup end
endif
" }}}1

" GUI设置 {{{1
if has("gui_running")
    " 去掉菜单栏、工具栏等
    set go=

    " 自动复制选区
    set go+=P

    call W_set_guifont()

    " 设置窗口位置和大小
    "    winpos 120 0
    set columns=120
    set lines=40

    " 设置默认配色方案
    if s:W_colorscheme_applied == 0
        set background=dark
        call W_set_colorscheme("solarized")
    endif

    " 光标设置 (:help 'guicursor')
    set guicursor=n-v-c:block-Cursor/lCursor
    set guicursor+=ve:ver35-Cursor
    set guicursor+=o:hor50-Cursor
    set guicursor+=i-ci:ver25-Cursor/lCursor
    set guicursor+=r-cr:hor20-Cursor/lCursor
    set guicursor+=sm:block-Cursor
    set guicursor+=a:blinkon0
endif
" }}}1

" cscope设置 {{{1
" See more:
"   :help cscope
"   http://vim.wikia.com/wiki/Cscope
if has("cscope")
    "set csprg=/usr/bin/cscope
    set csprg=cscope
    set csto=0
    set cst
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    set nocsverb
    call W_cscope_init_db()
    set csverb

    nnoremap <Leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>ft :cs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fe :cs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <Leader>fi :cs find i <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <Leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>

    " show result in new window
    nnoremap <Leader>fS :split<CR>:cs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fG :split<CR>:cs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fC :split<CR>:cs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fT :split<CR>:cs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fE :split<CR>:cs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <Leader>fF :split<CR>:cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <Leader>fI :split<CR>:cs find i <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <Leader>fD :split<CR>:cs find d <C-R>=expand("<cword>")<CR><CR>

    nnoremap <Leader>fu :call W_cscope_update_db()<CR>
    nnoremap <Leader>fl :call W_cscope_init_db()<CR>

    command! -nargs=1 Css cs find s <args>
    command! -nargs=1 Csg cs find g <args>
    command! -nargs=1 Csc cs find c <args>
    command! -nargs=1 Cst cs find t <args>
    command! -nargs=1 Cse cs find e <args>
    command! -nargs=1 Csf cs find f <args>
    command! -nargs=1 Csi cs find i <args>
    command! -nargs=1 Csd cs find d <args>

    command! Csu call W_cscope_update_db()
    command! Csl call W_cscope_init_db()
endif
" }}}1

