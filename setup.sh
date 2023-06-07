# !/usr/bin/zsh

cd $(dirname $0)
ENVDIR=$(pwd)

read "FULLNAME?Enter your full name: "
read "EMAIL?Enter your e-mail address: "

DOWNLOADS_DIR=${HOME}/Downloads

# Install standard applications
echo '\n\e[0;36mInstalling standard applications ...\e[m\n'
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y software-properties-common apt-transport-https
sudo apt-get install -y aptitude
sudo apt-get install -y curl wget rsync gnupg
sudo apt-get install -y bash-completion
sudo apt-get install -y lsb-release
sudo apt-get update
sudo apt-get upgrade -y

# Set up Git
echo '\n\e[0;36mSetting up Git ...\e[m\n'
echo "[user]
    name = ${FULLNAME}
	email = ${EMAIL}
[include]
    path = ${ENVDIR}/git/gitconfig" > ${HOME}/.gitconfig

# Set up Zsh
echo '\n\e[0;36mSetting up Zsh ...\e[m\n'
ln -s ${ENVDIR}/zsh/.zshenv ${HOME}/.zshenv
source ${HOME}/.zshenv
source ${ZDOTDIR}/.zshrc
ln -s ${ENVDIR}/dotfiles/dircolors ${HOME}/.dircolors

# Install and set up C & C++
echo '\n\e[0;36mSetting up C and C++ ...\e[m\n'
## GCC, G++, LLVM
sudo apt-get install -y gcc g++ build-essential llvm
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
## C++ libraries
sudo apt-get install -y libeigen3-dev
sudo apt-get install -y libboost-all-dev
## Make, CMake
sudo apt-get install -y make cmake
## ClangFormat
sudo apt-get install -y clang-format
ln -s ${ENVDIR}/dotfiles/clang-format ${HOME}/.clang-format

# Install and set up Python
echo '\n\e[0;36mSetting up Python ...\e[m'
## Dependent libraries
echo '\n\e[36mInstalling libraries required to build Python ...\e[m\n'
sudo sh -c 'echo "deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main" >> /etc/apt/sources.list'
sudo apt-get update
sudo apt-get build-dep -y python3.10
sudo apt-get install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
## Python
echo '\n\e[36mBuilding and installing Python ...\e[m\n'
pyenv install 3.10.10
pyenv global 3.10.10
eval "$(pyenv init -)"
## pip
echo '\n\e[36mInstalling pip ...\e[m\n'
sudo apt-get install -y python3-pip
pip install --upgrade pip
## Python modules
echo '\n\e[36mInstalling some Python modules ...\e[m\n'
pip install autopep8 ipykernel isort matplotlib numpy pandas scipy sympy yapf
mkdir -p ${HOME}/.config/yapf
ln -s ${ENVDIR}/dotfiles/yapf_style ${HOME}/.config/yapf/style

# Install and set up LaTeX
read -k 1 $'REPLY?\n\e[0;33mWould you like to install LaTeX? (Y/n): \e[m'
if [[ $REPLY == $'\n' ||  $REPLY == [yY] ]]; then
    echo '\n\e[0;36mInstalling LaTeX ...\e[m\n'
    sudo add-apt-repository multiverse
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends texlive-full
    sudo apt-get install -y --no-install-recommends ttf-mscorefonts-installer
    sudo add-apt-repository -r multiverse
    sudo apt-get update
    echo '\n\e[0;36mSetting up Latex ...\e[m\n'
    export LATEXDIR=${ENVDIR}/latex
    export TEXMFHOME=${LATEXDIR}/texmf
    ln -s "$(pwd)/dotfiles/latexmkrc" ${HOME}/.latexmkrc
    sudo apt-get install -y perl
    sudo cpan -i App::cpanminus
    sudo cpanm YAML::Tiny
    sudo cpanm File::HomeDir
    sudo cpanm Unicode::GCString
    sudo cpanm Log::Log4perl
    sudo cpanm Log::Dispatch::File
    echo "paths:
    - ${LATEXDIR}/latexindent/userSettings.yaml" > ${HOME}/.indentconfig.yaml
else
    echo '\n\e[0;31mLaTeX installation skipped.\e[m'
fi

# Install editors
## Vim
echo '\n\e[0;36mInstalling Vim ...\e[m\n'
sudo apt-get install -y vim
## VSCode
read -k 1 $'REPLY?\n\e[0;33mWould you like to install VSCode? (Y/n): \e[m'
if [[ $REPLY == $'\n' ||  $REPLY == [yY] ]]; then
    echo '\n\e[0;36mInstalling VSCode ...\e[m\n'
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ${DOWNLOADS_DIR}/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 ${DOWNLOADS_DIR}/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f ${DOWNLOADS_DIR}/packages.microsoft.gpg
    sudo apt-get update
    sudo apt-get install -y code
else
    echo '\n\e[0;31mVSCode installation skipped.\e[m'
fi

# Install browsers
## Google Chrome
read -k 1 $'REPLY?\n\e[0;33mWould you like to install Google Chrome? (Y/n): \e[m'
if [[ $REPLY == $'\n' ||  $REPLY == [yY] ]]; then
    echo '\n\e[0;36mInstalling Google Chrome ...\e[m\n'
    wget -P ${DOWNLOADS_DIR} https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt-get install -y ${DOWNLOADS_DIR}/google-chrome-stable_current_amd64.deb
    rm -f ${DOWNLOADS_DIR}/google-chrome-stable_current_amd64.deb
else
    echo '\n\e[0;31mGoogle Chrome installation skipped.\e[m'
fi

# Install communication tools
## Slack
if compgen -G "${DOWNLOADS_DIR}/slack-desktop*.deb" > /dev/null; then
    echo '\n\e[0;36mInstalling Slack ...\e[m\n'
    sudo apt-get install -y ${DOWNLOADS_DIR}/slack-desktop*.deb && rm -f ${DOWNLOADS_DIR}/slack-desktop*.deb
else
    echo '\n\e[0;31mSlack installation skipped.\e[m'
fi
# Discord
read -k 1 $'REPLY?\n\e[0;33mWould you like to install Discord? (Y/n): \e[m'
if [[ $REPLY == $'\n' ||  $REPLY == [yY] ]]; then
    echo '\n\e[0;36mInstalling Discord ...\e[m\n'
    curl -L "https://discord.com/api/download?platform=linux&format=deb" --output ${DOWNLOADS_DIR}/discord.deb
    sudo apt-get install -y ${DOWNLOADS_DIR}/discord.deb && rm -f ${DOWNLOADS_DIR}/discord.deb
else
    echo '\n\e[0;31mDiscord installation skipped.\e[m'
fi
## Zoom
read -k 1 $'REPLY?\n\e[0;33mWould you like to install Zoom? (Y/n): \e[m'
if [[ $REPLY == $'\n' ||  $REPLY == [yY] ]]; then
    echo '\n\e[0;36mInstalling Zoom ...\e[m\n'
    wget -P ${DOWNLOADS_DIR} http://zoom.us/client/latest/zoom_amd64.deb
    sudo apt-get install -y ${DOWNLOADS_DIR}/zoom_amd64.deb && rm -f ${DOWNLOADS_DIR}/zoom_amd64.deb
else
    echo '\n\e[0;31mZoom installation skipped.\e[m'
fi

# Install Docker Engine
echo '\n\e[0;36mInstalling Docker ...\e[m\n'
sudo apt-get install -y ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list'
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose
sudo usermod -aG docker $(whoami)

# Install and set up Gnuplot
echo '\n\e[0;36mInstalling Gnuplot ...\e[m\n'
sudo apt-get install -y gnuplot
echo "set loadpath \"${ENVDIR}/gnuplot/gnuplot-palettes\"

load \"${ENVDIR}/gnuplot/gnuplotrc\"" > ${HOME}/.gnuplot

# Set up input sources
echo '\n\e[0;36mInstalling Mozc ...\e[m\n'
sudo apt-get install -y ibus-mozc mozc-utils-gui
ibus restart

# Install other applications
echo '\n\e[0;36mInstalling other applications ...\e[m\n'
sudo apt-get install -y colordiff
sudo apt-get install -y usb-creator-gtk
curl -sS https://webinstall.dev/shfmt | bash && rm -rf ${DOWNLOADS_DIR}/webi
sudo apt-get install -y gthumb # Image viewer and editor
sudo apt-get install -y vlc # Media player
sudo update-pciids

# Uninstall unnecessary applications
echo '\n\e[0;36mUninstalling unnecessary applications ...\e[m\n'
sudo apt-get purge -y aisleriot gnome-mahjongg gnome-mines gnome-sudoku
sudo apt-get autoremove -y

# Load dconf settings
echo '\n\e[0;36mLoad dconf settings ...\e[m\n'
dconf load / < ${ENVDIR}/config/dconf.ini

echo '\n\e[0;36mAll installations and setups have completed!\e[m\n'

echo '\e[0;33mYou need to restart your computer.\e[m'
read -s -k $'?\e[0;33mPress [ENTER] to continue or Ctrl-c to cancel and restart manually.\e[m'

echo '\n\n\e[0;31mRebooting your computer ...\e[m\n'
reboot
