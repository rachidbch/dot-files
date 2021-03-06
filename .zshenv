# Utility {{{1
function register_path() { # {{{2
    dir="$1"
    if [ -d "$dir/bin" ]; then _path="$dir/bin:$_path"; fi
    if [ -d "$dir/sbin" ]; then _path="$dir/sbin:$_path"; fi
    if [ -d "$dir/man" ]; then _manpath="$dir/man:$_manpath"; fi
    if [ -d "$dir/share/man" ]; then _manpath="$dir/share/man:$_manpath"; fi
    if [ -d "$dir/info" ]; then _infopath="$dir/info:$_infopath"; fi
    if [ -d "$dir/include" ]; then _include_path="$dir/include:$_include_path"; fi
    if [ -d "$dir/lib" ]; then _library_path="$dir/lib:$_library_path"; fi
}

function register_paths() { # {{{2
    dir="$1"
    if [ -d "$dir" ] || [ -z "$dir" ]; then
        register_path "$dir"
        for i in $dir/*(N); do
            register_path "$i"
        done
    fi
}

function export_paths() { # {{{2
    export PATH=$_path
    export MANPATH=$_manpath
    export INFOPATH=$_infopath
}

function restore_paths() { # {{{2
    export PATH=$_default_path
    export MANPATH=$_default_manpath
    export INFOPATH=$_default_infopath
    export INCLUDE_PATH=$_default_include_path
    export LIBRARY_PATH=$_default_library_path
}

function source_if() { # {{{2
    [[ -s "$1" ]] && source "$1"
}

function has_command() { # {{{2
    $(which $1 > /dev/null 2>&1)
}

# Manager {{{1
function init_envs() {
    # homebrew (OSX)
    [[ -d "/usr/local/share/python" ]] && export PATH=/usr/local/share/python:$PATH

    # rvm
    source_if "$HOME/.rvm/scripts/rvm"

    # rbenv
    if [ -d "$HOME/.rbenv" ]; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
    fi

    # pyenv
    if [ -d "$HOME/.pyenv" ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi

    # nvm
    source_if "$HOME/.nvm/nvm.sh"

    # nodebrew
    [[ -d "$HOME/.nodebrew" ]] && export PATH=$HOME/.nodebrew/current/bin:$PATH

    # cabal
    [[ -d "$HOME/.cabal" ]] && export PATH=$HOME/.cabal/bin:$PATH

    # perlbrew
    source_if "$HOME/perl5/perlbrew/etc/bashrc"

    # golang
    if has_command "go"; then
        export GOPATH="$HOME/.go"
        export PATH="$GOPATH/bin:$PATH"
    fi
}

# Export {{{1
# Path {{{2
_default_path=$PATH
_default_manpath=$MANPATH
_default_infopath=$INFOPATH
_default_include_path=$INCLUDE_PATH
_default_library_path=$LIBRARY_PATH

register_paths ""
register_paths "/usr"
register_paths "/opt/local"
register_paths "/usr/local"
register_paths "$HOME/local"
export_paths
init_envs

# Misc {{{2
export TZ=JST-9
export EDITOR=`which vim`
export PAGER=`which less`
export SHELL=`which zsh`
export LESS="-i -M -R"
export GREP_COLOR="01;33"
export GREP_OPTIONS="--color=auto"
export WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

[ -n $TERM ] && export TERM=xterm-256color

# SSH-Agent {{{2
SSH_AGENT=`which ssh-agent`
SSH_ADD=`which ssh-add`
SSH_ENV="$HOME/.ssh/environment"

function start_ssh_agent {
    echo "Initialising new SSH agent..."
    $SSH_AGENT | head -n 2 > $SSH_ENV
    chmod 600 $SSH_ENV
    . $SSH_ENV > /dev/null
    $SSH_ADD < /dev/null
}

if [ -f $SSH_ENV ]; then
    . $SSH_ENV > /dev/null
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ > /dev/null || {
        start_ssh_agent
    }   
else
    start_ssh_agent
fi

# End {{{1
source_if "$HOME/.zshenv.local"

