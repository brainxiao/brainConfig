" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2011 Apr 15
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
"else
"  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show thet pull cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremegit pullntal searching 边搜索边出结果

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
"  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  set nocp
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

"show line number
set number
"set numberwidth=5
highlight LineNr ctermfg=blue  ctermbg=black

"show current file path
"set laststatus=2  "启动显示状态行(1),总是显示状态行(2)
"highlight StatusLine cterm=bold ctermfg=black ctermbg=Gray
"set statusline=[%n]\%F%m%r%h\ %=\ \|\ \<\ WHAT\ THE\ FUCK!!\ \>\ \|\ %l,%c\ %p%%\ \| "定制状态栏格式


""""""""""""""""""""""""""""""
"press 'f' to show current function.
""""""""""""""""""""""""""""""
fun! ShowFuncName()  
	let lnum = line(".")  
	let col = col(".")  
	echohl ModeMsg  
	echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))  
	echohl None  
	call search("\\%" . lnum . "l" . "\\%" . col . "c")  
endfun  
"nmap f :call ShowFuncName() <CR> 



""""""""""""""""""""""""""""""
" cscope setting
""""""""""""""""""""""""""""""
if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=1
    set cst
    set nocsverb

    " 解决cscope与tag共存时ctrl+]有时不正常的bug
    nmap :tj =expand("")

    if filereadable("cscope.out")
      cs add cscope.out
    endif

    " Use both cscope and ctag
    set cscopetag

    " Use tags for definition search first
    set cscopetagorder=1

    set csverb

endif

nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR>



" 显示中文帮助
if version >= 603
    set helplang=cn
    set encoding=utf-8
endif


"set autoread       " 设置当文件被改动时自动载入
set ignorecase      "搜索忽略大小写
set smartcase       " 如果搜索模式包含大写字符，不使用 'ignorecase' 选项。只有在输入搜索模式并且打开 'ignorecase' 选项时才会使用。
set showmatch       " 高亮显示匹配的括号
set matchtime=1     " 匹配括号高亮的时间（单位是十分之一秒）
set showmode        " 命令行显示vim当前模式
"set autochdir       "自动切换当前目录为当前文件所在的目录

" 高亮当前行列
"set cursorline
"set cursorcolumn
"highlight CursorLine   cterm=NONE ctermbg=grey ctermfg=magenta
"highlight CursorColumn cterm=NONE ctermbg=grey ctermfg=black
"hi CursorLine   cterm=NONE ctermbg=grey ctermfg=white guibg=darkred guifg=white
"hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white


""""""""""""""""""""""""""""""
"colors setting
""""""""""""""""""""""""""""""
set t_Co=256
"查看Vim配色方案路径：/usr/share/vim/vim73/colors/      ~/.vim/colors
colorscheme skeletor


"Tab使用4个空格
set ts=4
set expandtab
set autoindent


"标签栏设置
set tabpagemax=18    "VIM默认只能打开10个标签页，在配置文件可以修改这个限制
"set showtabline=0    "不显示标签栏
set showtabline=1    "这是默认设置，意思是，在创建标签页后才显示标签栏
"set showtabline=2    "总是显示标签栏


"When .vimrc is edited, reload it
"autocmd! bufwritepost .vimrc source ~/.vimrc


""""""""""""""""""""""""""""""
"插入模式下按Ctrl+h/j/k/l移动光标
"注意，ctrl-h在输入模式下默认等同于backspace键（这和在shell下是一样的）,此时可用ctrl-backspace退格
"更建议在输入之后使用ctrl-[退出输入模式，让vim保持在正常模式
""""""""""""""""""""""""""""""
"imap <C-h> <C-o>h
"imap <C-j> <C-o>j
"imap <C-k> <C-o>k
"imap <C-l> <C-o>l

"let Tlist_JS_Settings = 'javascript;s:string;a:array;o:object;f:function'
"let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'
"let g:tlist_javascript_settings = 'javascript;r:var;s:string;a:array;o:object;u:function'
"let g:tlist_javascript_settings = 'javascript;s:string;a:array;o:object;f:function'




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""Plug setting"""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')


"""""""""""""""""""""""""""""""""""""
"NERDTree
"""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/nerdtree'

"NERDTree快捷键
nmap <F4> :NERDTreeToggle <CR>
nmap <F2> :NERDTreeFind  <CR>
let NERDTreeWinPos="right"
let NERDTreeWinSize=50
let NERDTreeShowLineNumbers=1
let NERDTreeQuitOnOpen=1


"""""""""""""""""""""""""""""""""""""
"MRU
"""""""""""""""""""""""""""""""""""""
Plug 'yegappan/mru'

if filereadable("./.vim_mru_files")         "若当前目录有.vim_mru_files则使用当前，若无则使用defaul: ~/.vim_mru_files
let MRU_File = './.vim_mru_files'
endif
let MRU_Window_Height = 20


"""""""""""""""""""""""""""""""""""""
"taglist-plus
"""""""""""""""""""""""""""""""""""""
"Plug 'vim-scripts/taglist-plus'

"let Tlist_Auto_Open = 1
"let Tlist_Display_Prototype = 1    在taglist窗口中显示标记原型而不是标记名称
"let Tlist_Exit_OnlyWindow = 1
"let Tlist_Show_One_File = 1
"let Tlist_Inc_Winwidth = 0
"let Tlist_WinWidth = 60
"set updatetime=1500


""""""""""""""""""""""""""""""
"taglist
""""""""""""""""""""""""""""""
Plug 'vim-scripts/taglist.vim'
let Tlist_Show_One_File=1       "只显示当前文件的tags
let Tlist_WinWidth=50           "设置taglist宽度
let Tlist_Exit_OnlyWindow=1     "tagList窗口是最后一个窗口，则退出Vim
"let Tlist_Use_Right_Window=0    "在Vim窗口右侧显示taglist窗口
"set tags=tags
let Tlist_Auto_Open=0           "默认打开Taglist
set updatetime=100             "根据光标位置自动更新Taglist高亮tag的间隔时间，单位为毫秒 默认4000,不能改太小
"let Tlist_Auto_Update=1




""""""""""""""""""""""""""""""
"Leaderf 模糊查找神器
""""""""""""""""""""""""""""""
Plug 'Yggdroot/LeaderF'

"按键映射，按F3进入LeaderFile
nmap <F3> :LeaderfFile  <CR>


""""""""""""""""""""""""""""""
"bufExplorer
""""""""""""""""""""""""""""""
Plug 'jlanzarotta/bufexplorer'

let g:bufExplorerSplitHorzSize=50
let g:bufExplorerVertSize=50     " if 0, New split windows size set by Vim.
let g:bufExplorerSplitRight=1        " 0->Split left. 1->Split right
let g:bufExplorerSplitBelow=1        " Split new window 1->below current. 0->above current.
let g:bufExplorerUseCurrentWindow=0
let g:bufExplorerDetailedHelp=1      " Show detailed help.


""""""""""""""""""""""""""""""
" lookupfile
""""""""""""""""""""""""""""""
"Plug 'vim-scripts/lookupfile'

"lookupfile需要依赖genutils
"Plug 'vim-scripts/genutils'

"let g:LookupFile_MinPatLength = 2               "最少输入2个字符才开始查找
"let g:LookupFile_PreserveLastPattern = 0        "不保存上次查找的字符串
"let g:LookupFile_PreservePatternHistory = 1     "保存查找历史
"let g:LookupFile_AlwaysAcceptFirst = 1          "回车打开第一个匹配项目
"let g:LookupFile_AllowNewFiles = 1              "允许创建不存在的文件  0->允许 1->不允许
"let g:LookupFile_UsingSpecializedTags = 1       "按filenametags格式显示结果
"if filereadable("./filenametags")               "设置tag文件的名字
"let g:LookupFile_TagExpr = '"./filenametags"'
"endif

"映射LookupFile为\lk
"nmap <silent> <leader>lk :LUTags<cr>
"映射LUBufs为\ll          
"nmap <silent> <leader>ll :LUBufs<cr>
"映射LUWalk为\lw
"nmap <silent> <leader>lw :LUWalk<cr>
"映射F4打开LookupFile,默认为F5
"nmap <unique> <silent> <F4> <Plug>LookupFile


" -----------------------------------------------
" 加强版状态条
" -----------------------------------------------
Plug 'itchyny/lightline.vim'

"支援lightline显示gitbranch
Plug 'tpope/vim-fugitive'

set laststatus=2  "启动显示状态行(1),总是显示状态行(2)
let g:lightline = {
      \ 'colorscheme': 'default',
      \ 'active': {
      \   'left': [ [ 'gitbranch', 'paste' ],
      \             [ 'readonly', 'absolutepath', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat' ],
      \              [ 'fileencoding' ],
      \              [ 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }






""""""""""""""""""""""""""""""
" 快速切换配色方案
""""""""""""""""""""""""""""""
Plug 'chxuan/change-colorscheme'

map <F12> :NextColorScheme<CR>
imap <F12> <ESC> :NextColorScheme<CR>
map <F11> :PreviousColorScheme<CR>
imap <F11> <ESC> :PreviousColorScheme<CR>


""""""""""""""""""""""""""""""
" 配色方案预览
""""""""""""""""""""""""""""""
Plug 'sjas/csExplorer'




""""""""""""""""""""""""""""""
" 递归查找cscope.out,tag
""""""""""""""""""""""""""""""
Plug 'vim-scripts/autoload_cscope.vim'


""""""""""""""""""""""""""""""
" 自动补全
""""""""""""""""""""""""""""""
Plug 'vim-scripts/AutoComplPop'


""""""""""""""""""""""""""""""
"扩展%命令，使%命令可以在其它程序语言的开始结束标记间跳转
""""""""""""""""""""""""""""""
Plug 'vim-scripts/matchit.zip'




call plug#end()
