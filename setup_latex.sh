# !/usr/bin/zsh

TOOLS_DIR=${HOME}/Tools
mkdir -p ${TOOLS_DIR}

# Install LaTeX and dependent packages
echo '\n\e[1;36mInstalling LaTeX ...\e[m\n'
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get install -y --no-install-recommends texlive-full
sudo apt-get install -y --no-install-recommends ttf-mscorefonts-installer
sudo add-apt-repository -r multiverse
sudo apt-get update

# Set up LaTeX
echo '\n\e[1;36mSetting up Latex ...\e[m\n'
git clone --recursive git@github.com:conjikidow/latex-environment.git ${TOOLS_DIR}/latex
export LATEXDIR="${TOOLS_DIR}/latex"
export TEXMFHOME="${LATEXDIR}/texmf"
ln -s "$(pwd)/rc/latexmkrc" ${HOME}/.latexmkrc

echo "# Paths to user settings for latexindent.pl
#
# Note that the settings will be read in the order you
# specify here- each successive settings file will overwrite
# the variables that you specify

paths:
- ${LATEXDIR}/latexindent/userSettings.yaml" > ${HOME}/.indentconfig.yaml

echo '\n\e[1;36mAll installations and settings have completed!\e[m\n'
