# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#liaozurui@20140920 remark:for display git branch info.
find_git_branch () {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head = ref:\ refs/heads/* ]]; then
                git_branch="(${head#*/*/})"
            elif [[ $head != '' ]]; then
                git_branch="(detached)"
            else
                git_branch="(unknow)"
            fi  
            return
        fi  
        dir="../$dir"
    done
    git_branch=''
}

PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[31;35;1m\]$git_branch\[\033[00m\]\[\033[00m\]:\[\033[01;36m\]\w\[\033[32m\]\$\[\033[00m\]'
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
	alias buildtags='~/tools/buildtags.sh'
	alias lookupfile='~/tools/lookfile.sh'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

#alias for git cmd
alias reset='git reset --hard HEAD~10'
alias pick='git cherry-pick'
alias pickc='git cherry-pick --continue'
#alias for 

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

stty -ixon
export USE_CCACHE=1
#“export EDITOR=/usr/bin/vim“

export PATH=~/.local/bin:~/bin:$PATH

alias my_cscope_tags='ctags -R --c++-kinds=+p --fields=+iaS --extra=+q && cscope -Rbq'
alias my_cscope_files='find . -iregex ".*\(\.h\|\.c\|\.cpp\|\.mk\|\.ini\|\.java\|\.sh\|\.cfg\|\.xml\|\Makefile\|\.rc\|\.conf\|\.aidl\)$" > cscope.files'
alias my_make_tags='my_cscope_files && my_cscope_tags'
alias docker='docker_auto_choose'
#兼容tmux
alias tmux="tmux -2"
#export TERM=screen-256color
Is_Empty() {
    if [ "$1" = "" ]
    then
            return 0
    else
            return 1
    fi
}

do_push(){
        find_git_branch
        local git_branch=$(echo $git_branch | sed "s/(\(.*\)).*/\1/g")
        local local_ver=$(echo $git_branch | grep -Po "\d+.\d+\.\d+")
        echo $local_ver
        if [ "local_ver" != "" ]
        then
                local last_stable_ver=$(cvt-baseline-versions | grep laststable | grep -Po "\d+.\d+\.\d+")
                echo last
                echo $last_stable_ver
                if [ "$last_stable_ver" != "$local_ver" ]
                then
                        read -p "你的本地基线版本不是最新基线版本，确认是否继续(Y/N)(默认继续)?" PUSH_CODE
                        if [ $PUSH_CODE = 'N' ] && [ $PUSH_CODE = 'n' ]
                        then
                                echo "exit......"
                                return 1
                        fi
                fi

        fi
        if git remote -v | grep "tv@git.gz.cvte.cn"
        then
                echo "It's a git"
                PUSH_RESULT=$(git push origin $git_branch)
        else
                echo "Is's not a git"
                PUSH_RESULT=$(git gt-dpush origin $git_branch)
        fi
}

#default use PY3
alias python='python3'

#兼容tmux
alias tmux="tmux -2"
export do_push

#vscode
#~/MyTool/script/vscode-service.sh &
