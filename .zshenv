# Utility {{{1
register_path() { # {{{2
    dir="$1"
    if [ -d "$dir/bin" ]; then export PATH="$dir/bin:$PATH"; fi
    if [ -d "$dir/sbin" ]; then export PATH="$dir/sbin:$PATH"; fi
    if [ -d "$dir/man" ]; then export MANPATH="$dir/man:$MANPATH"; fi
    if [ -d "$dir/share/man" ]; then export MANPATH="$dir/share/man:$MANPATH"; fi
    if [ -d "$dir/info" ]; then export INFOPATH="$dir/info:$INFOPATH"; fi
    if [ -d "$dir/include" ]; then export INCLUDE_PATH="$dir/include:$INCLUDE_PATH"; fi
    if [ -d "$dir/lib" ]; then export LIBRARY_PATH="$dir/lib:$LIBRARY_PATH"; fi
}
register_paths() { # {{{2
    dir="$1"
    if [ -d "$dir" ] || [ -z "$dir" ]; then
        register_path "$dir"
        for i in $dir/*; do
            register_path "$i"
        done
    fi
}

source_if() { # {{{2
    [[ -s "$1" ]] && source "$1"
}

# Manager {{{1
before_register_paths() {
}

after_register_paths() {
    # homebrew (OSX)
    [[ -d "/usr/local/share/python" ]] && export PATH=/usr/local/share/python:$PATH

    # pythonbrew
    source_if "$HOME/.pythonbrew/etc/bashrc"

    # virtualenv
    export PYTHONSTARTUP=$HOME/.pythonstartup
    export WORKON_HOME=$HOME/.virtualenvs
    if [ -d $WORKON_HOME ]; then
        export VIRTUALENVERAPPER_SH=`which virtualenvwrapper.sh`
        source_if "$VIRTUALENVERAPPER_SH"
    fi

    # rvm
    source_if "$HOME/.rvm/scripts/rvm"

    # rbenv
    if [ -d "$HOME/.rbenv" ]; then
        export PATH=$HOME/.rbenv/bin:$PATH
        eval "$(rbenv init -)"
    fi

    # nvm
    source_if "$HOME/.nvm/nvm.sh"

    # nodebrew
    [[ -d "$HOME/.nodebrew" ]] && export PATH=$HOME/.nodebrew/current/bin:$PATH

    # cabal
    [[ -d "$HOME/.cabal" ]] && export PATH=$HOME/.cabal/bin:$PATH

    # perlbrew
    source_if "$HOME/perl5/perlbrew/etc/bashrc"
}

# Export {{{1
# Path {{{2
#if [ -n "$SCREEN" -o -z "$REGISTER_PATHS_COMPLETED" ]; then
if [ -z "$REGISTER_PATHS_COMPLETED" ]; then
    before_register_paths

    # for Defaults
    register_paths ""
    register_paths "/usr"
    
    # for MacPorts
    register_paths "/opt/local"

    # for manually build applications
    register_paths "/usr/local"

    # for my own tools
    register_paths "$HOME/local"
    register_paths "$HOME/local/enabled"

    # exports
    export PATH MANPATH INFOPATH
    export INCLUDE_PATH
    export C_INCLUDE_PATH=$INCLUDE_PATH
    export CPP_INCLUDE_PATH=$INCLUDE_PATH
    export LIBRARY_PATH
    export LD_LIBRARY_PATH=$LIBRARY_PATH

    # completed
    export REGISTER_PATHS_COMPLETED=1

    after_register_paths

    export _PATH=$PATH
else
    [ -n $_PATH ] && export PATH=$_PATH
fi

# Misc {{{2
export TZ=JST-9
export EDITOR=`which vim`
export PAGER=`which less`
export SHELL=`which zsh`
export LESS="-i -M -R"
export GREP_COLOR="01;33"
export GREP_OPTIONS="--color=auto"
export WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

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

