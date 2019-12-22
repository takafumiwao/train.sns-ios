#!/bin/sh

# installing xxx を表示する
function installingEcho() {
    echo "installing \033[0;32m$1\033[0;39m"
}

# Successfully installed xxx を表示する
function successInstallEcho() {
    echo "Successfully installed \033[0;34m$1\033[0;39m"
}

# Error installing xxx を表示する
function failureInstallEcho() {
    echo "Error installing \033[0;31m$1\033[0;39m"
}

# already installed xxx を表示する
function alreadyInstalledEcho() {
    echo "already installed \033[0;33m$1\033[0;39m"
}

cd `dirname $0`

echo "################################"
echo "Start setup…"

# Homebrewをインストール
if !(type "brew" > /dev/null 2>&1); then
    installingEcho "Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    if !(type "brew" > /dev/null 2>&1); then
        failureInstallEcho "Homebrew"
        exit 1
    fi
    successInstallEcho "Homebrew🍺"
else
    alreadyInstalledEcho "Homebrew"
fi

# rbenvをインストール
if !(type "rbenv" > /dev/null 2>&1); then
    installingEcho "rbenv"
    brew install rbenv ruby-build

    if !(type "rbenv" > /dev/null 2>&1); then
        failureInstallEcho "rbenv"
        exit 1
    fi

    rbenv install 2.6.3
    rbenv global 2.6.3
    rbenv init

    PROFILE=""
    if [[ $SHELL =~ /bash$ ]]; then
        PROFILE=~/.bash_profile
    elif [[ $SHELL =~ /zsh$ ]]; then
        PROFILE=~/.zprofile
    fi

    if [ ! -e $PROFILE ]; then
        touch "$PROFILE"
    fi

    echo 'eval "$(rbenv init -)"' >> "$PROFILE"
    source "$PROFILE"

    successInstallEcho "rben💎"
else
    alreadyInstalledEcho "rbenv"
fi

# bundlerをインストール
if !(gem list | grep 'bundler' >/dev/null); then
    installingEcho "bundler"
    gem install bundler

    if !(type "bundle" > /dev/null 2>&1); then
        failureInstallEcho "bundle"
        exit 1
    fi

    rbenv rehash
    successInstallEcho "bundler📦"
else
    alreadyInstalledEcho "bundler"
fi

# bundleたちをインストール
echo "installing gem bundle"
bundle install --path vendor/bundle
echo "Successfully installed gem bundle"

echo "Setup is done. Welcome!"
echo "################################"
