#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# ------------share--------------
invocation='echo "" && say_verbose "Calling: ${yellow:-}${FUNCNAME[0]} ${green:-}$*${normal:-}"'
exec 3>&1
if [ -t 1 ] && command -v tput >/dev/null; then
	ncolors=$(tput colors || echo 0)
	if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
		bold="$(tput bold || echo)"
		normal="$(tput sgr0 || echo)"
		black="$(tput setaf 0 || echo)"
		red="$(tput setaf 1 || echo)"
		green="$(tput setaf 2 || echo)"
		yellow="$(tput setaf 3 || echo)"
		blue="$(tput setaf 4 || echo)"
		magenta="$(tput setaf 5 || echo)"
		cyan="$(tput setaf 6 || echo)"
		white="$(tput setaf 7 || echo)"
	fi
fi

say_warning() {
	printf "%b\n" "${yellow:-}Warning: $1${normal:-}" >&3
}

say_err() {
	printf "%b\n" "${red:-}Error: $1${normal:-}" >&2
}

say() {
	# using stream 3 (defined in the beginning) to not interfere with stdout of functions
	# which may be used as return value
	printf "%b\n" "${cyan:-}${normal:-} $1" >&3
}

say_verbose() {
	if [ "$verbose" = true ]; then
		say "$1"
	fi
}

machine_has() {
	eval $invocation

	command -v "$1" >/dev/null 2>&1
	return $?
}

check_sudo() {
	sudo echo "check sudo" || {
		say_err "sudo not found"
		exit 1
	}
}

DEBIAN_FRONTEND=noninteractive

# 安装依赖
install_dependency() {
	check_sudo
	sudo apt update &&
		sudo apt install -y wget curl git &&
		sudo apt install -y xclip &&
		sudo apt install -y python3-dev python3-pip &&
		sudo apt install -y ripgrep
	
	sudo apt install -y nodejs npm python3-venv
	pip3 install pythonenv

	# nerd font
	wget -P /tmp/ https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/Hack.zip
	unzip -o /tmp/Hack.zip -d /tmp/Hack
	check_sudo
	sudo mkdir -p /usr/share/fonts/truetype/hack-nerd
	sudo mv -f /tmp/Hack/*.ttf /usr/share/fonts/truetype/hack-nerd
	sudo fc-cache -f -v

	# lazygit
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	wget -O /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar -xzf /tmp/lazygit.tar.gz -C /tmp
	check_sudo
	cd /tmp && check_sudo &&
		sudo install lazygit /usr/local/bin

	# go DiskUsage
	check_sudo
	sudo add-apt-repository -y ppa:daniel-milde/gdu
	sudo apt update &&
		sudo apt install -y gdu

	# bottom
	check_sudo
	curl -Lo /tmp/bottom_amd64.deb https://github.com/ClementTsang/bottom/releases/download/0.8.0/bottom_0.8.0_amd64.deb
	sudo dpkg -i /tmp/bottom_amd64.deb

}

# 安装neovim
install_neovim() {
	wget -P /tmp/ https://github.com/neovim/neovim/releases/download/v0.9.0/nvim-linux64.tar.gz
	check_sudo
	sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /usr/local/ --strip-components=1 nvim-linux64/
}

# 安装Astronvim
install_astronvim() {
	if [ ! -d "$HOME/.config/nvim" ]; then
		git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
	fi
	if [ ! -d "$HOME/.config/nvim/user" ]; then
		git clone https://github.com/jungheil/astronvim_config.git ~/.config/nvim/lua/user
	fi
	nvim --headless -c 'quitall'
}

install_dependency
install_neovim
install_astronvim
