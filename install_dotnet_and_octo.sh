#!/usr/bin/env bash

set -euo pipefail

# Globals / Configuration
OCTO_DL_URL="https://download.octopusdeploy.com/octopus-tools/4.30.7/OctopusTools.4.30.7.portable.tar.gz"
OCTO_BIN_PATH="$HOME/.octo"

DOTNETCORE_SCRIPT="https://raw.githubusercontent.com/dotnet/cli/master/scripts/obtain/dotnet-install.sh"
DOTNET_BIN_PATH="$HOME/.dotnet"

verbose=false

# Use in the the functions: eval $invocation
invocation='say_verbose "Calling: ${yellow:-}${FUNCNAME[0]} ${green:-}$*${normal:-}"'

temporary_file_template="${TMPDIR:-/tmp}/octoscript.XXXXXXXXX"

# standard output may be used as a return value in the functions
# we need a way to write text on the screen in the functions so that
# it won't interfere with the return value.
# Exposing stream 3 as a pipe to standard output of the script itself
exec 3>&1

# Setup some colors to use. These need to work in fairly limited shells, like the Ubuntu Docker container where there are only 8 colors.
# See if stdout is a terminal
if [ -t 1 ]; then
    # see if it supports colors
    ncolors=$(tput colors)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        bold="$(tput bold       || echo)"
        normal="$(tput sgr0     || echo)"
        black="$(tput setaf 0   || echo)"
        red="$(tput setaf 1     || echo)"
        green="$(tput setaf 2   || echo)"
        yellow="$(tput setaf 3  || echo)"
        blue="$(tput setaf 4    || echo)"
        magenta="$(tput setaf 5 || echo)"
        cyan="$(tput setaf 6    || echo)"
        white="$(tput setaf 7   || echo)"
    fi
fi

say_err() {
    printf "%b\n" "${red:-}octo_install: Error: $1${normal:-}" >&2
}


say() {
    local prefix=${2-"octo-install"}

    # using stream 3 (defined in the beginning) to not interfere with stdout of functions
    # which may be used as return value
    printf "%b\n" "${cyan:-}$prefix:${normal:-} $1" >&3
}

say_verbose() {
    if [ "$verbose" = true ]; then
        say "$1" ${2:-}
    fi
}

say_dn() {
    say "$1" "dotnet-install"
}

# args:
# remote_path - $1
# [out_path] - $2 - stdout if not provided
downloadcurl() { #Downloads using cURL
    eval $invocation
    local remote_path=$1
    local out_path=${2:-}

    local failed=false
    if [ -z "$out_path" ]; then
        curl --retry 10 -sSL -f --create-dirs $remote_path || failed=true
    else
        curl --retry 10 -sSL -f --create-dirs -o $out_path $remote_path || failed=true
    fi
    if [ "$failed" = true ]; then
        say_verbose "Curl download failed"
        return 1
    fi
    return 0
}

# Install the Dotnet Framework
# argS:
# download_url - $1
install_dotnet() {
    eval $invocation
    local download_url=$1

    local download_failed=false
    local install_failed=false

    script_path=$(mktemp $temporary_file_template)
    say_verbose "Script path: $script_path"

    say_dn "Downloading script: $download_url"
    downloadcurl $download_url $script_path || download_failed=true

    if [ "$download_failed" = true ]; then
        say_err "Cannot download: $download_url"
        return 1
    fi

    bash $script_path --channel 2.0 || install_failed=true

    if [ "$install_failed" = true ]; then
        say_err "Installation of Dotnet Failed"
        return 1
    fi

    return 0
}

# Clean out existing OCTO directory
# args:
# directory - $1
ensure_clean() {
    eval $invocation
    local directory=$1

    say "Cleaning: $directory"
    rm -rf $directory
    mkdir -p $directory

    return 0
}

# Download and extract Octopus Deploy
# args:
# octo_dl_url - $1
# octo_dir - $2
download_extract(){
    eval $invocation
    local octo_dl_url=$1
    local octo_dir=$2

    local download_failed=false
    local extract_failed=false

    zip_path=$(mktemp $temporary_file_template)
    say_verbose "Zip path: $zip_path"

    say "Downloading package: $octo_dl_url"
    downloadcurl $octo_dl_url $zip_path || download_failed=true

    if [ "$download_failed" = true ]; then
        say_err "Cannot download: $download_url"
        return 1
    fi

    say "Extracting package"
    tar -xzf "$zip_path" -C "$octo_dir" > /dev/null || extract_failed=true

    if [ "$extract_failed" = true ]; then
        say_err "Extraction failed"
        return 1
    fi

    return 0
}

# Fix the Octo file
# args:
# octo_dir - $1
fix_octo_file(){
    eval $invocation

    local octo_dir=$1
    local octo_file="$octo_dir/Octo"

    if [ ! -f $octo_file ]; then
        say_err "Octo file not found, could not fix"
        return 1
    else
        mv -f "$octo_file" "$octo_file.broken"
        # remove carriage returns from file
        tr -d '\r' < "$octo_file.broken" > "$octo_file"
        say "Carriage returns removed from $octo_file"

        chmod +x $octo_file
        say "Executable bit set on $octo_file"
    fi


}

install_dotnet "$DOTNETCORE_SCRIPT"
ensure_clean $OCTO_BIN_PATH
download_extract "$OCTO_DL_URL" "$OCTO_BIN_PATH"
fix_octo_file "$OCTO_BIN_PATH"

say "Add to PATH: \`$OCTO_BIN_PATH\` and \`$DOTNET_BIN_PATH\`."

say "Installation finished successfully."