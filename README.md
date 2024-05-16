# ubuntu-environment
This repository contains scripts and configuration files for setting up an Ubuntu environment.

The latest supported version is Ubuntu 22.04 LTS.

## Before Running This Script
### Install Zsh and Git

Set Zsh as the default shell and install Git.

```bash
$ sudo apt update
$ sudo apt install -y zsh git
$ chsh -s $(which zsh)
```

To activate Zsh, you need to log out and log back in to the shell.

### Generate and register SSH keys to communicate with GitHub

Generate public/private ed25519 key pairs.

```zsh
$ mkdir ${HOME}/.ssh && cd ${HOME}/.ssh
$ ssh-keygen -t ed25519 -C "email@example.com" -f github_ed25519
```

Copy the generated public key to the clipboard and register it on [GitHub](https://github.com/settings/keys).

```zsh
$ sudo apt install -y xclip
$ xclip -sel clip < ${HOME}/.ssh/github_ed25519.pub
```

### Download Slack Installer

Download the Slack app installer from its [official site](https://slack.com/downloads/linux) to the Downloads directory if you want the app.
Note that you need to download the .deb version.

## Just Run

Clone this repository and run `setup.sh` using your current Zsh.

```zsh
$ git clone --recursive git@github.com:conjikidow/ubuntu-environment.git ${HOME}/.environment
$ cd ${HOME}/.environment
$ source ./setup.sh
```
