#!/bin/bash 
# Luciano Antonio Borguetti Faustino 14/05/2022
# This is a idempotent script used to provision my entire developer environment.
# Idempotent scripts can be called multiple times and each time it’s called, it will 
# have the same effects on the system.
# 
# Currently support only raspberry pi os (64 bits).

set -e errexit
set -u nounset

function package_exists() {
	dpkg --status "${@}" > /dev/null 2>&1 
}

function do_package_install() {
	sudo apt install "${@}" > /dev/null 2>&1 || false
}

function do_packages() {

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

do_packages
