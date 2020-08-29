#! /usr/bin/env bash

# Installe differentes appli sur debian

sudo apt update


# tree
app=tree
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi

# sublime text
app=sublimetext
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text
if [[ $? == 0  ]]; then
	echo "$app installé"
fi

# extractor de differents fichiers (zip, gz, ...)
app=tar
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
app=bunzip2
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
app=unrar
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
app=unzip
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
# app=uncompress
# if [[ ${sudo apt install $app -y} ]]; then
# 	echo "$app installé"
# fi
app=p7z-full
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
app=ar
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
app=zstd
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi
echo "# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
ex ()
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
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}" >> ~/.bashrc


# Chromium
app=chromium
sudo apt install $app -y
if [[ $? == 0  ]]; then
	echo "$app installé"
fi

# 