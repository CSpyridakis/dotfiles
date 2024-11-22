#!/usr/bin/env zsh

CLR_RST='\e[0m'
CLR_RED='\e[0;31m'
CLR_GREEN='\e[0;32m'
CLR_BROWN='\e[0;33m'
CLR_YELLOW='\e[1;33m'
CLR_BLUE='\e[0;34m'
CLR_PURPLE='\e[0;35m'
CLR_WHITE='\e[1;37m'

# =======================================================================================
# =======================================================================================
# =======================================================================================

# ----------------------------------------------------------------------------
# TMUX
# ----------------------------------------------------------------------------
# If TMUX is not set in this terminal, then activate it by default!
if [ "$TMUX" = "" ]; then tmux; fi

alias tps="tmux list-panes | cut -d' ' -f1-2"   # When in TMUX find dimensions of each pane

function ctmux(){
    for i in $(tmux ls | grep -v attached | cut -d':' -f1) ; do
        tmux killw -t $i
    done
    tmux ls
}

alias wraptext="cut -c1-$COLUMNS" # cut lines if output is bigger than the width of the pane/terminal: eg. cat log | wraptext

# ----------------------------------------------------------------------------
# POWER OPERATIONS
# ----------------------------------------------------------------------------
alias sx="shutdown 0"
alias sxr="shutdown -r 0"

# ----------------------------------------------------------------------------
# TERMINAL OPERATIONS
# ----------------------------------------------------------------------------
alias ngt="gnome-terminal"

function colours(){ # Display terminal possible colours
    for i in {0..255}; do  printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done
}

function myfunctions(){ # Display all custom functions from ~/.zshrc, and it's first kid files that it sources
    local list=`cat ~/.zshrc $(cat ~/.zshrc | grep source | tr -s ' ' | cut -d' ' -f2) 2>/dev/null | grep -E '^function ' | tr -d '{' | tr -s ' ' | cut -d' ' -f2- | sort`
    
    local i=1
    while IFS= read -r line; do
        local my_func="`echo $line | cut -d'(' -f 1`"
        local comment="`echo $line | grep '\#' | cut -d'#' -f2 `"
        echo -n "${CLR_BLUE}${i}${CLR_RST}. ${CLR_RED}${my_func}${CLR_RST}()"
        [ ! -z "${comment}" ] && echo " ${CLR_GREEN}#${comment}${CLR_RST}" || echo 
        (( i+=1 ))
    done <<< "$list"
}

function myalias(){    # Display all custom aliases from ~/.zshrc, and it's first kid files that it sources
    local list=`cat ~/.zshrc $(cat ~/.zshrc | grep source | tr -s ' ' | cut -d' ' -f2) 2>/dev/null | grep -E '^alias ' | tr -s ' ' | cut -d' ' -f2- | sort`

    local i=1
    while IFS= read -r line; do
        local my_alia="`echo $line | cut -d'=' -f 1`"
        local full_comm="`echo $line | cut -d'"' -f 2`"
        local comment="`echo $line | grep '\#' | cut -d'#' -f2 `"
        echo -n "${CLR_BLUE}${i}${CLR_RST}. ${CLR_RED}${my_alia}${CLR_RST} = \"${CLR_WHITE}${full_comm}${CLR_RST}\""
        [ ! -z "${comment}" ] && echo " ${CLR_GREEN}#${comment}${CLR_RST}" || echo 
        (( i+=1 ))
    done <<< "$list"
}

function mkcd(){  # Create a new directory if not exists and move in
    local dirname=$1
    if [ ! -e ${dirname} ]; then
        mkdir ${dirname}
        cd ${dirname} ;
    elif [ -d ${dirname} ]; then 
        echo "\033[0;31m${dirname} - Exists\033[0m" 1>&2
    elif [ ! -d ${dirname} ]; then
        echo "\033[0;31m${dirname} - Exists as file\033[0m" 1>&2
    fi
}

function fixzshhistory(){
    mv ~/.zsh_history ~/.zsh_history_bad
    strings -eS ~/.zsh_history_bad > ~/.zsh_history
    fc -R ~/.zsh_history
}
# ----------------------------------------------------------------------------
# SSH COMMANDS
# ----------------------------------------------------------------------------
alias ssh_list_keys="ssh-add -l"
alias ssh_keygen=" ssh-keygen -t rsa -b 4096 -C" # "email@domain.com"
#
# Notes:
# SSH PROXY JUMP:           ssh -J ${user-Proxy}@${ip-Proxy} ${userTarget}@${ipTarget}
# SSH PROXY COPY KEY:       ssh-copy-id -i ${key_path} -o ProxyJump=jumpuser@jumphost:2455 remoteuser@remotehost
# SSH USE SPECIFIC KEY:     ssh -o "IdentitiesOnly=yes" -i ${key_path} -p ${ip} ${user}@${ip}
# Or in the ~/.ssh/config add the jump server like:
#
# Host <host-name>
#   HostName <IP-address>
#   Port <specify-port-number-here> # Not important
#   User <user-name> # Not important

# ### The Remote Host
# Host <private-server-name>
#   HostName <IP-address> # Not important
#   Port <specify-port-number-here>  # Not important
#   User <user-name> # Not important
#   ProxyJump <host-name>

# ----------------------------------------------------------------------------
# CONFIG FILES
# ----------------------------------------------------------------------------
alias czsh="code ~/.zshrc"  # Open in vscode .zshrc
alias cmzsh="code $(cat ~/.zshrc | grep my_zshrc.zsh | tr -s ' ' | cut -d' ' -f2)" # Open in vscode my zshrc extension
alias cmtmux="code ~/.tmux.conf"
alias cmtmuxfuncs="code ~/.tmux-functions.sh"
alias szr="source ~/.zshrc" 

# ----------------------------------------------------------------------------
# IP INFO
# ----------------------------------------------------------------------------
alias ipw="curl ifconfig.me"                    # Global IP Address
alias ipl="hostname -I | awk '{print $1}'"      # All local IP Addresses
alias ipl1="ipl | tr -s ' ' | cut -d' ' -f1"   # First local IP Address
alias iplf="ipl | tr -s ' ' | cut -d' ' -f"    # Select one from local IP Addresses
alias iibip="ip a | grep -B 2 `ipl1` | head -n 1 | tr -s ' ' | tr -d ' ' | cut -d ':' -f 2" # Internet interace used based on active local IP

# ----------------------------------------------------------------------------
# ALIASES & FUNCTIONS
# ----------------------------------------------------------------------------
alias myaliasg="myalias | cgrep"
alias myfunctionsg="myfunctions | cgrep"

# ----------------------------------------------------------------------------
# PACKAGE MANAGER SHORTCUTS
# ----------------------------------------------------------------------------
alias aptcr="sudo apt autoclean && sudo apt autoremove"
alias aptup="sudo apt update"
alias aptin="sudo apt -y install"
alias aptli="grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*"
alias aptpo="apt policy"
alias aptar="apt_add_repo"
function apt_add_repo(){
    sudo add-apt-repository -y ppa:$@
    sudo apt-get -y update --fix-missing
    sudo apt update
}
alias aptrr="apt_remove_repo"
function apt_remove_repo(){
    sudo add-apt-repository --remove ppa:$@
    sudo apt update
}

# ----------------------------------------------------------------------------
# GIT
# ----------------------------------------------------------------------------
alias gdf="git diff"
alias gdca="git diff --cached"
alias gst="git status"
alias ga.="git add ."
alias gpl="git pull"
alias gps="git push"
alias gpsf!="git push --force"
alias grhh="git reset HEAD --hard"
alias gff="git update-index --assume-unchanged"         # To have a file in repo but not track
alias grf="git update-index --no-assume-unchanged"      # To revert above command
alias gif="git ls-files -v | grep '^[[:lower:]]'"       # Show ignored files that assume unchanged
alias gdcl="git clean -xdf"                             # See untracked files
alias gscl="git clean -xdn"                             # Delete untracked files

function ghrepodl(){    # Download git repo as git an unzip it
    local repo="$1/archive/master.zip"
    echo "curl -L -o master.zip ${repo}"
    curl -L -o master.zip ${repo}
    unzip master.zip
    rm master.zip
}

function ghreposize(){  # Find git repo size
    local prefix="https://github.com/"
    local own_repo=${1#"$prefix"}
    local size=`curl -s https://api.github.com/repos/${own_repo} | grep size | cut -d':' -f2 | tr -d ',' | numfmt --to=iec --from-unit=1024`
    echo "$1    size: ${size}B"
}

function gacp(){
    git add .
    git commit -m "$1"
    git push
}

# ----------------------------------------------------------------------------
# DOCKER
# ----------------------------------------------------------------------------
alias dila="docker image ls -a"                                                                     # docker list all images
alias dcls="docker container ls"                                                                    # docker list all active containers
alias dcla="docker container ls -a"                                                                 # docker list all containers
alias dcids="docker container ls -a | tr -s ' ' | tail -n +2 | cut -d' ' -f1"                       # docker containers IDs
alias diids="docker image ls -a | tail -n +2 | tr -s ' ' | cut -d' ' -f 3"                          # docker images IDs
                                                              
function dcra(){    # docker delete all containers
    docker container rm `dcids`
}

function dira(){    # docker delete all images
    docker image rm `diids`
}

# ----------------------------------------------------------------------------
# FIND IN FILES
# ----------------------------------------------------------------------------
function findInFiles(){
    pattern=$1
    find . -type f 2> /dev/null | xargs grep --color=always -Hisn $pattern 2> /dev/null
}

function findInSRC(){
    pattern=$1
    find . -type f -name "*.cpp" -or -name "*.hpp" -or -name "*.c" -or -name "*.h" -or -name "*.sh" -or -name "*.txt" -or -name "*Makefile*" -or -name "CMakeLists.txt*" 2> /dev/null | xargs grep --color=always -Hnis $pattern 2> /dev/null 
}

function findNamedSRC(){
    pattern=$1
    find . type f -iname "*${pattern}*" 2> /dev/null | grep --color=always -E "\.(sh|c|h|cpp|hpp|txt|md)$"
}

function findNamedFileDir(){
    pattern=$1
    find . type f -iname "*${pattern}*" 2> /dev/null | grep --color=always "${pattern}"
}

function findInPdfs(){
    toExec="pdftotext \"{}\" - | grep --with-filename --label=\"{}\" --color $@"
    echo "${toExec}"
    find . -name '*.pdf' -exec sh -c "${toExec}" \;
}

function findInRoot(){
    find / -name $@ 2> /dev/null
}

function TODO(){
    echo "find . -type f-name \"*.cpp\" -or -name \"*.hpp\" -or -name \"*.h\" -or -name \"*.c\" -or -name \"*.sh\" $@ | xargs grep -Hni --color=always -A1 \"TODO\""
    find . -type f -name "*.cpp" -or -name "*.hpp" -or -name "*.h" -or -name "*.c" -or -name "*.sh" $@ | xargs grep -Hni --color=always -A1 "TODO"
}
function FIXME(){
    echo "find . -type f -name \"*.cpp\" -or -name \"*.hpp\" -or -name \"*.h\" -or -name \"*.c\" -or -name \"*.sh\" $@ | xargs grep -Hni --color=always -A1 \"FIXME\""
    find . -type f -name "*.cpp" -or -name "*.hpp" -or -name "*.h" -or -name "*.c" -or -name "*.sh" $@ | xargs grep -Hni --color=always -A1 "FIXME"
}

# ----------------------------------------------------------------------------
# GREP
# ----------------------------------------------------------------------------

alias cats="highlight -O xterm256 --force"  # Run sudo apt-get install highlight 
alias cgrep="grep --color=always"

# =======================================================================================
# ================================      MISC       ======================================
# =======================================================================================

alias tinyfileserver="python3 -m http.server 3333 -d ${PWD}"    # Create a tiny http server to share files
alias audiorst="pulseaudio -k && sudo alsa force-reload"        # Restart sound service
alias vlcf/="vlc file://"

# ----------------------------------------------------------------------------
# MUTE WINDOWS FROM LAUNCHER (Useful when do not want ALT+TAB to include them)
# ----------------------------------------------------------------------------

export MUTED_WINDOWS_FROM_TASKBAR=('')

function mute_taskbar_win(){        # Mute window (During ALT+TAB the window will not be visible)
    echo "Add $1 to the muted windows list"
    MUTED_WINDOWS_FROM_TASKBAR+=("$1")
    wmctrl -r "$1" -b add,skip_taskbar
}

function unmute_taskbar_win(){      # Unmute (can view during ALT+TAB the window again)  
    if [[ ${MUTED_WINDOWS_FROM_TASKBAR[@]} =~ "$1" ]] ; then
        echo "Remove $1 from muted windows list"
        MUTED_WINDOWS_FROM_TASKBAR=( "${MUTED_WINDOWS_FROM_TASKBAR[@]/$1}" )
        wmctrl -r "$1" -b remove,skip_taskbar
    fi
}

function list_taskbar_wins(){ # List all active windows
    echo "`wmctrl -l | tr -s ' '`"
}

function list_muted_taskbar_wins(){ # List the muted windows
    echo "${MUTED_WINDOWS_FROM_TASKBAR[@]}"
}


# ----------------------------------------------------------------------------
# Delete n lines from zsh history
# ----------------------------------------------------------------------------
# https://unix.stackexchange.com/questions/236094/how-to-remove-the-last-command-or-current-command-for-bonus-from-zsh-history

# Put a space at the start of a command to make sure it doesn't get added to the history.
setopt histignorespace

alias forget=' my_remove_last_history_entry' # Added a space in 'my_remove_last_history_entry' so that zsh forgets the 'forget' command :).

# ZSH's history is different from bash,
# so here's my fucntion to remove
# the last item from history.
my_remove_last_history_entry() {
    # This sub-function checks if the argument passed is a number.
    # Thanks to @yabt on stackoverflow for this :).
    is_int() ( return $(test "$@" -eq "$@" > /dev/null 2>&1); )

    # Set history file's location
    history_file="${HOME}/.zsh_history"
    history_temp_file="${history_file}.tmp"
    line_cout=$(wc -l $history_file)

    # Check if the user passed a number,
    # so we can delete x lines from history.
    lines_to_remove=1
    if [ $# -eq 0 ]; then
        # No arguments supplied, so set to one.
        lines_to_remove=1
    else
        # An argument passed. Check if it's a number.
        if $(is_int "${1}"); then
            lines_to_remove="$1"
        else
            echo "Unknown argument passed. Exiting..."
            return
        fi
    fi

    # Make the number negative, since head -n needs to be negative.
    lines_to_remove="-${lines_to_remove}"

    fc -W # write current shell's history to the history file.

    # Get the files contents minus the last entry(head -n -1 does that)
    #cat $history_file | head -n -1 &> $history_temp_file
    cat $history_file | head -n "${lines_to_remove}" &> $history_temp_file
    mv "$history_temp_file" "$history_file"

    fc -R # read history file.
}

# ----------------------------------------------------------------------------
# CHANGE PROMPT
# ----------------------------------------------------------------------------
NEXT_LINE_PROMPT="➯ " #  ➥  ⟾  ⫸  ⌦   ⋙  ➯ 
NEXT_LINE_PROMPT_COLOR=${CLR_YELLOW}
NEXT_LINE_PROMPT_ENABLE="FALSE"
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
      print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
      print -n "%{%k%}"
  fi

  print -n "%{%f%}"
  CURRENT_BG='' 
  
  if [[ ${NEXT_LINE_PROMPT_ENABLE} == "TRUE" ]] ; then  	
    printf "\n ${NEXT_LINE_PROMPT_COLOR}${NEXT_LINE_PROMPT}${CLR_RST}"
  fi

  printf "";
}



