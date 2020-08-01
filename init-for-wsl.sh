#!/bin/bash

function backup() {
    if [[ -z "$1" ]] ;then
        echo -e "\033[31mError: backup() required one parameter\033[m"
        exit 1
    elif [[ -e "$1" ]] ;then
        mv "$1" "$1".bak
    fi
}

function makedir() {
    if [[ -z "$1" ]] ;then
        echo -e "\033[31mError: makedir() required one parameter\033[m"
        exit 1
    elif [[ ! -d "$1" ]] ;then
        if [[ -e "$1" ]] ;then
            mv "$1" "$1".bak
        fi
        mkdir -p "$1"
    fi
}

# sudoers
echo '=========> Modifing /etc/sudoers ...'
echo '%sudo   ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers

# apt repo
echo '=========> Modifing /etc/apt/sources.list ...'
echo 'deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
#deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse' | sudo tee /etc/apt/sources.list
sudo apt clean
sudo apt update
sudo apt upgrade

# download tools
sudo apt install neovim python3-pynvim xsel vim cmake ctags global silversearcher-ag ripgrep \
    npm php gcc clang cppcheck shellcheck gdb cgdb \
    libboost-dev mariadb-client mariadb-server libmysql++-dev \
    zsh install zsh-syntax-highlighting zsh-autosuggestions autojump \
    fzf ranger ncdu htop iotop dstat cloc screenfetch figlet cmatrix python3-pip 
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple
    pip3 install cppman gdbgui thefuck

# vim config
echo '=========> Installing configuration for vim/nvim ...'
backup ~/.SpaceVim
git clone https://gitee.com/mrbeardad/SpaceVim ~/.SpaceVim

makedir ~/.config
backup ~/.config/nvim
ln -s ~/.SpaceVim ~/.config/nvim

makedir ~/.SpaceVim.d
backup ~/.SpaceVim.d/init.toml
cp -v ~/.SpaceVim/mode/init.toml ~/.SpaceVim.d

makedir ~/.local/bin
g++ -O3 -std=c++17 -o ~/.local/bin/quickrun_time ~/.SpaceVim/custom/quickrun_time.cpp
cp -v ~/.SpaceVim/custom/{nop.sh,vim-quickrun.sh} ~/.local/bin

# zsh config
echo '=========> Installing configuration for zsh ...'
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp zsh/*theme ~/.oh-my-zsh/themes
backup ~/.zshrc
cp -v zsh/zshrc-for-wsl.zsh ~/.zshrc

# tmux config
echo '=========> Installing configuration for tmux ...'
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.config/tmux-resurrect
backup ~/.tmux.conf
cp -v tmux/tmux-for-wsl.conf ~/.tmux.conf

# ranger config
echo '=========> Installing configuration for ranger ...'
backup ~/.config/ranger
cp -rv ranger ~/.config/ranger

# ssh config
makedir ~/.ssh
cat ssh/ssh_config >> ~/.ssh/ssh_config
cp .gitconfig ~
sudo cp -v ssh/sshd_config /etc/ssh/sshd_config

# cli config
cp -v bin/{say,see} ~/.local/bin
sudo cp -v bin/terminal-tmux.sh /usr/local/bin
backup ~/.cheat
dotfiles_dir=$PWD
export dotfiles_dir
ln -s  "$dotfiles_dir"/cheat ~/.cheat
makedir ~/.cache/cppman/cplusplus.com
(
cd /tmp || exit 1
tar -zxf "$dotfiles_dir"/cppman/cppman_db.tar.gz
cp -vn cplusplus.com/* ~/.cache/cppman/cplusplus.com
)
backup ~/.gdbinit
cp -v gdb/gdbinit ~/.gdbinit
makedir ~/.cgdb
backup ~/.cgdb/cgdbrc
cp -v gdb/cgdbrc ~/.cgdb

# links
echo '=========> Creating links to access Windows easily ...'
for inUserDir in $(find /mnt/c/Users -maxdepth 1 -not -iregex '/mnt/c/Users/\(all users\|default\|default user\|public\)' | sed '1d') ;do
    if [[ -d "$inUserDir" ]] ;then
        Dir=$inUserDir
        break;
    fi
done
ln -vs "$Dir" ~/WindowsHome
ln -vs "$Dir/AppData/Roaming/alacritty/alacritty.yml" ~/.config/alacritty.yml