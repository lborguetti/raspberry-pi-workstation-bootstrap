#!/bin/bash
# Luciano Antonio Borguetti Faustino 14/05/2022
# This is a idempotent script used to provision my entire developer environment.
# Idempotent scripts can be called multiple times and each time it’s called, it will
# have the same effects on the system.
#
# Currently support only raspberry pi os (64 bits).

set -e errexit
set -u nounset

function file_changes(){

    diff "dotfiles/${*}" "${HOME}/${*}" > /dev/null 2>&1 || false

}

function file_exists(){

    stat "${HOME}/${*}" > /dev/null 2>&1 || false

}

function do_dotfile_install(){

    _dirname=""

    _dirname=$(dirname "${*}") || false
    mkdir --parents "${HOME}/${_dirname}" > /dev/null || false
    cp --force --backup "dotfiles/${*}" "${HOME}/${*}" > /dev/null 2>&1 || false

}

function do_dotfiles(){

dotfile=""

while IFS="" read -r dotfile; do
    if ! file_exists "${dotfile}"; then
        echo -n "Ensuring the copy of the ${dotfile} dotfile: "
        if ! do_dotfile_install "${dotfile}"; then
            echo "fail"
        else
            echo "ok"
        fi
    else
        if ! file_changes "${dotfile}"; then
            echo -n "The file was changed, ensuring the copy of the ${dotfile} dotfile: "
            if ! do_dotfile_install "${dotfile}"; then
                echo "fail"
            else
                echo "ok"
            fi
        fi
    fi
done <<< "$(cd dotfiles && find . -type f)"

}

function package_exists(){

    dpkg --status "${@}" > /dev/null 2>&1 || false

}

function do_package_install(){

    DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install "${@}" > /dev/null || false

}

function do_packages(){

package=""

while IFS="" read -r package; do
    if ! package_exists "${package}"; then
        echo -n "Ensuring the installation of the ${package} package: "
        if ! do_package_install "${package}"; then
            echo "fail"
        else
            echo "ok"
        fi
    fi
done < ./packages.txt

}

function do_neovim(){

    vim +PlugUpdate +qall || false
    vim +PlugUpgrade +qall || false

}

do_dotfiles
do_packages
do_neovim
