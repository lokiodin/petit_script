#! /usr/bin/env bash

# Installe differentes appli sur debian

sudo apt update


# tree
if [[ ${sudo apt install tree -y} ]]; then
	echo "tree installé"
fi

# sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update

if [[ ${sudo apt-get install sublime-text} ]]; then
	echo "Sublime Text installé"
fi

