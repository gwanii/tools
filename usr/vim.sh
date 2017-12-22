#!/bin/bash
#set -x
echo -e "\n*************************************************"
echo "Installing vim tooklkit..."
echo -e "\n*************************************************"
echo "Running apt-get update..."
echo "*************************************************"
apt-get update

echo -e "\n*************************************************"
echo "Installing cscope ctags..."
echo "*************************************************"
apt-get install cscope ctags
mkdir -p ~/.vim/bundle/cscope_maps/plugin
pushd ~/.vim/bundle/cscope_maps/plugin
wget http://cscope.sourceforge.net/cscope_maps.vim
popd
cp ./.vimrc ~/.vimrc

echo -e "\n*************************************************"
echo "Installing vim bundles/plugins- pathogen, NERDTree..."
echo "*************************************************"
mkdir -p ~/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdtree.git
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/Vimjas/vim-python-pep8-indent.git
git clone https://github.com/altercation/vim-colors-solarized.git
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
cd ~
echo -e "\nInstallation of vim tooklkit done..."
echo "*************************************************"
