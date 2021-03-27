#! /bin/bash


# Define some colors for quick use...
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_WHITE=$(tput setaf 7)
BOLD=$(tput bold)
COLOR_RESET=$(tput sgr0)

function echo_red(){
	echo "${COLOR_RED}${BOLD}$1${COLOR_RESET}"
}

function echo_green(){
	echo "${COLOR_GREEN}${BOLD}$1${COLOR_RESET}"
}

function echo_yellow(){
	echo "${COLOR_YELLOW}${BOLD}$1${COLOR_RESET}"
}


set -e
# set -x

if [ $# -ge 1 ]; then
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		echo "Small tool to install some nice things such as zsh, cool fonts, and others packages"
		echo "USAGE: $0 [-h | --help]"
		echo "	-h, --help	: this help"
		exit 0
	fi
fi





if [ $(whoami) == "root" ]; then
	echo "-----------"
	echo "Sorry, retry without root"
	exit 0
fi

USER_HOME=$(echo $HOME)

##################################
#		 Question Time !!
##################################

if [ $(uname -r | grep "microsoft-standard") ]; then
	isWSL=1
fi

if [ "$(cat /etc/os-release | grep 'kali')" ]; then
	distrib="kali"
elif [ "$(cat /etc/os-release | grep 'debian')" ]; then
	distrib="debian"
elif [ "$(cat /etc/os-release | grep 'arch')" ]; then
	distrib="arch"
fi

echo "Here is some question :"
while [ "$iZSH" != "y" ] && [ "$iZSH" != "yes" ] && [ "$iZSH" != "n" ] && [ "$iZSH" != "no" ]; do
	read -p "Install zsh (it will be with antigen and p10k) ? [y/n] " iZSH
done
while [ "$iFONTS" != "y" ] && [ "$iFONTS" != "yes" ] && [ "$iFONTS" != "n" ] && [ "$iFONTS" != "no" ]; do
	read -p "Install cool fonts compatible with zsh ? [y/n] " iFONTS
done

INSTALL_COMMON_TOOLS="tar bzip2 unrar-free unzip p7zip-full build-essential zstd wget"


INSTALL_KALI_PACKAGES="kali-linux-default kali-tools-top10 sherlock ltrace strace tree"
INSTALL_KALI_PACKAGES_REPLY=$INSTALL_KALI_PACKAGES
if [ "$distrib" == "kali" ]; then
	echo "Install below kali packages (type all to install all or type desired pakages, if none just press enter) :"
	echo " $INSTALL_KALI_PACKAGES"
	read -p "Your response : " INSTALL_KALI_PACKAGES_REPLY
fi

##################################
#		 Install zsh and co
##################################

if [ $iZSH == "y" ] || [ $iZSH == "yes" ]; then
	echo "Installing zsh, antigen and p10k for $USER_HOME"

	sudo apt update && sudo apt install -y zsh 

	## Install antigen-zsh and p10k
	sudo apt update && sudo apt install -y curl git
	if ! [ -d $USER_HOME/.config/antigen ]; then
		mkdir -p $USER_HOME/.config/antigen/
	fi
	curl -L git.io/antigen > $USER_HOME/.config/antigen/antigen.zsh

	cat << _EOF_ > $USER_HOME/.zshrc
source $USER_HOME/.config/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme. Load p10k
#antigen theme robbyrussell
antigen theme romkatv/powerlevel10k


# Tell Antigen that you're done.
antigen apply
_EOF_
	
	chsh -s $(which zsh)
	echo_green "Install of zsh and co completed"
fi

##################################
# Install cool fonts for the terminal with zsh and co
##################################

# Install cool fonts for the terminal with zsh and co
if [ "$iFONTS" == "y" ] || [ "$iFONTS" == "yes" ]; then

	FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip"
	FONTS_NAME="CascadiaCode"
	FONTS_ZIP="CascadiaCode.zip"

	FONTS_PATH="/usr/share/fonts/$FONTS_NAME"

	echo "Install some cool fonts $FONTS_NAME"

	sudo apt update && sudo apt install -y curl

	if ! [ -d $FONTS_PATH ]; then
		echo "Creating $FONTS_PATH"
		sudo mkdir $FONTS_PATH
	fi

	curl -L -O "$FONTS_URL"

	if [ -f "$FONTS_ZIP" ]; then
	    unzip "$FONTS_ZIP" -d $FONTS_NAME
	else
	    echo_red "Unable to find the pulled fonts archive file.  Fonts install failed."
	    exit 1
	fi

	if [ -d $FONTS_PATH ]; then
		# for file in $(find $FONTS_NAME | grep ttf | sed -e 's/^/"/g' -e 's/$/"/g' | tr '\n' ' '); do
		#     # echo " "
		#     echo "Installing the $file fonts in $FONTS_PATH"

		#     mv $file $FONTS_PATH
		# done
		sudo mv $FONTS_NAME/*ttf $FONTS_PATH
		# clean up archive file
		echo "Clearing and regenerating the font cache.  You will see a stream of text as this occurs..."
		rm -rf $FONTS_ZIP $FONTS_NAME
		fc-cache -f 
		echo "Testing. You should see the expected install filepaths in the output below..."
		fc-list | grep "$FONTS_NAME"

		echo_green "Install of $FONTS_NAME fonts completed"
	else
	    echo_red "Unable to identify the unpacked font directory $FONTS_PATH. Install failed."
	    exit 1
	fi
fi

##################################
# Install Common tools
##################################

sudo apt update
sudo apt install -y $INSTALL_COMMON_TOOLS
if [ $? -eq 0  ]; then
  echo_green "$INSTALL_COMMON_TOOLS installed"
fi

app=sublimetext
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y sublime-text
if [[ $? == 0  ]]; then
	echo_green "$app installed"
fi

##################################
# Update .bashrc and .zshrc with some aliases
##################################

 echo "bin2ascii() { { tr -cd 01 | fold -w8; echo; } | sed '1i obase=8; ibase=2' | bc | sed 's/^/\\/' | tr -d '\n' | xargs -0 echo -e; }" >> $USER_HOME/.bashrc
 echo "bin2ascii() { { tr -cd 01 | fold -w8; echo; } | sed '1i obase=8; ibase=2' | bc | sed 's/^/\\/' | tr -d '\n' | xargs -0 echo -e; }" >> $USER_HOME/.zshrc

echo '# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
extractor ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;      
      *)           echo "Cannot be extracted via extractor()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}' >> $USER_HOME/.bashrc
echo '# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
extractor ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;      
      *)           echo "Cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}' >> $USER_HOME/.zshrc


##################################
# Downloading some git repo for kali
##################################
if [ "$distrib" == "kali" ]; then
	if [ "$INSTALL_KALI_PACKAGES_REPLY" == "all"]; then
		echo "Installing $INSTALL_KALI_PACKAGES ..."
		sudo apt update
		sudo apt install -y $INSTALL_KALI_PACKAGES
	elif [ "$INSTALL_KALI_PACKAGES_REPLY" != "" ]; then
		echo "Installing $INSTALL_KALI_PACKAGES_REPLY ..."
		sudo apt update
		sudo apt install -y $INSTALL_KALI_PACKAGES_REPLY
	fi

	echo "Downloading SecList in /opt"
	git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists

	echo "Downloading john in /opt"
	git clone https://github.com/openwall/john.git

fi





if [ "$iZSH" == "y" ] || [ "$iZSH" == "yes" ]; then
	zsh
fi

echo_green "Please now reboot/relaunch your terminal"

