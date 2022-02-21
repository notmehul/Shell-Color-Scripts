#!/usr/bin/env bash

# Simple CLI for shell-color-scripts

DIR_COLORSCRIPTS="/opt/shell-color-scripts/colorscripts"
if command -v find &>/dev/null; then
    LS_CMD="$(command -v find) ${DIR_COLORSCRIPTS} -maxdepth 1 -type f"
else
    LS_CMD="$(command -v ls) ${DIR_COLORSCRIPTS}"
fi

DIR_ANIMATED_COLORSCRIPTS="/opt/shell-color-scripts/animated-colorscripts"
if command -v find &>/dev/null; then
    LS_CMD_ANIMATED="$(command -v find) ${DIR_ANIMATED_COLORSCRIPTS} -maxdepth 1 -type f"
else
    LS_CMD_ANIMATED="$(command -v ls) ${DIR_ANIMATED_COLORSCRIPTS}"
fi

list_colorscripts="$($LS_CMD | xargs -I $ basename $ | cut -d ' ' -f 1 | nl)"
length_colorscripts="$($LS_CMD | wc -l)"

list_colorscripts_animated="$($LS_CMD_ANIMATED | xargs -I $ basename $ | cut -d ' ' -f 1 | nl)"
length_colorscripts_animated="$($LS_CMD_ANIMATED | wc -l)"

fmt_help="  %-20s\t%-54s\n"
function _help() {
    echo "Description: A collection of terminal color scripts."
    echo ""
    echo "Usage: colorscript [OPTION] [SCRIPT NAME/INDEX]"
    printf "${fmt_help}" \
        "-h, --help, help" "Print this help." \
        "-l, --list, list" "List all installed colorscripts." \
        "-r, --random, random" "Run a random NON-ANIMATED colorscript." \
        "-R, --random-animated, random-animated" "Run a random ANIMATED colorscript." \
        "-e, --exec, exec" "Run a specified NON-ANIMATED colorscript by SCRIPT NAME or INDEX."\
        "-E, --exec-animated, exec-animated" "Run a specified ANIMATED colorscript by SCRIPT NAME or INDEX."\
        "-b, --blacklist, blacklist" "Blacklist a colorscript by SCRIPT NAME or INDEX." \
        "-a, --all, all" "List the outputs of all NON-ANIMATED colorscripts with their SCRIPT NAME"
}

function _list() {
    echo "--------------------------------------------------"
    echo "There are "$($LS_CMD_ANIMATED | wc -l)" ANIMATED colorscripts. Run with:"
    echo "    colorscript -E name-or-index"
    echo "--------------------------------------------------"
    echo "${list_colorscripts_animated}"
    echo "--------------------------------------------------"
    echo "There are "$($LS_CMD | wc -l)" NON-ANIMATED colorscripts. Run with:"
    echo "    colorscript -e name-or-index"
    echo "--------------------------------------------------"
    echo "${list_colorscripts}"
}

function _random() {
    declare -i random_index=$RANDOM%$length_colorscripts
    [[ $random_index -eq 0 ]] && random_index=1

    random_colorscript="$(echo  "${list_colorscripts}" | sed -n ${random_index}p \
        | tr -d ' ' | tr '\t' ' ' | cut -d ' ' -f 2)"
    # echo "${random_colorscript}"
    exec "${DIR_COLORSCRIPTS}/${random_colorscript}"
}

function _random_animated() {
    declare -i random_index=$RANDOM%$length_colorscripts
    [[ $random_index -eq 0 ]] && random_index=1

    random_colorscript="$(echo  "${list_colorscripts}" | sed -n ${random_index}p \
        | tr -d ' ' | tr '\t' ' ' | cut -d ' ' -f 2)"
    # echo "${random_colorscript}"
    exec "${DIR_ANIMATED_COLORSCRIPTS}/${random_colorscript}"
}

function ifhascolorscipt() {
    [[ -e "${DIR_COLORSCRIPTS}/$1" ]] && echo "Has this color script."
}

function ifhascolorscipt_animated() {
    [[ -e "${DIR_ANIMATED_COLORSCRIPTS}/$1" ]] && echo "Has this color script."
}

function _run_by_name() {
    if [[ "$1" == "random" ]]; then
        _random
    elif [[ -n "$(ifhascolorscipt "$1")" ]]; then
        exec "${DIR_COLORSCRIPTS}/$1"
    else
        echo "Input error, Don't have color script named $1."
        exit 1
    fi
}

function _run_by_name_animated() {
    if [[ "$1" == "random" ]]; then
        _random
    elif [[ -n "$(ifhascolorscipt_animated "$1")" ]]; then
        exec "${DIR_ANIMATED_COLORSCRIPTS}/$1"
    else
        echo "Input error, Don't have color script named $1."
        exit 1
    fi
}

function _run_by_index() {
    if [[ "$1" -gt 0 && "$1" -le "${length_colorscripts}" ]]; then

        colorscript="$(echo  "${list_colorscripts}" | sed -n ${1}p \
            | tr -d ' ' | tr '\t' ' ' | cut -d ' ' -f 2)"
        exec "${DIR_COLORSCRIPTS}/${colorscript}"
    else
        echo "Input error, Don't have NON-ANIMATED color script indexed $1."
        exit 1
    fi
}

function _run_by_index_animated() {
    if [[ "$1" -gt 0 && "$1" -le "${length_colorscripts_animated}" ]]; then

        colorscript="$(echo  "${list_colorscripts_animated}" | sed -n ${1}p \
            | tr -d ' ' | tr '\t' ' ' | cut -d ' ' -f 2)"
        exec "${DIR_ANIMATED_COLORSCRIPTS}/${colorscript}"
    else
        echo "Input error, Don't have ANIMATED color script indexed $1."
        exit 1
    fi
}

function _run_colorscript() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        _run_by_index "$1"
    else
        _run_by_name "$1"
    fi
}

function _run_animated_colorscript() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        _run_by_index_animated "$1"
    else
        _run_by_name_animated "$1"
    fi
}

function _run_all() {
    for s in $DIR_COLORSCRIPTS/*
    do
        echo "$(echo $s | awk -F '/' '{print $NF}'):"
        echo "$($s)"
        echo
    done
}

function _blacklist_colorscript() { # by name only
    if [ ! -d "${DIR_COLORSCRIPTS}/blacklisted" ]; then
        sudo mkdir "${DIR_COLORSCRIPTS}/blacklisted"
    fi
    sudo mv "${DIR_COLORSCRIPTS}/$1" "${DIR_COLORSCRIPTS}/blacklisted"
}

case "$#" in
    0)
        _help
        ;;
    1)
        case "$1" in
            -h | --help | help)
                _help
                ;;
            -l | --list | list)
                _list
                ;;
            -r | --random-static | random)
                _random
                ;;
            -R | --random-animated | random-animated)
                _random_animated
                ;;
            -a | --all | all)
                _run_all
                ;;
            *)
                echo "Input error."
                exit 1
                ;;
        esac
        ;;
    2)
        if [[ "$1" == "-e" || "$1" == "--exec" || "$1" == "exec" ]]; then
            _run_colorscript "$2"
        elif [[ "$1" == "-E" || "$1" == "--exec-animated" || "$1" == "exec-animated" ]]; then
            _run_animated_colorscript "$2"
        elif [[ "$1" == "-b" || "$1" == "--blacklist" || "$1" == "blacklist" ]]; then
            _blacklist_colorscript "$2"
        else
            echo "Input error."
            exit 1
        fi
        ;;
    *)
        echo "Input error, too many arguments."
        exit 1
        ;;
esac

