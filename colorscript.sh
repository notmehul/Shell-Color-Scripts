#!/usr/bin/env bash

# Simple CLI for shell-color-scripts

DIR_COLORSCRIPTS="./colorscripts"

LS_CMD="$(command -v find) ${DIR_COLORSCRIPTS} -maxdepth 1 -type f"


list_colorscripts="$($LS_CMD | xargs -I $ basename $ | cut -d ' ' -f 1 | nl)"
length_colorscripts="$($LS_CMD | wc -l)"

declare -i random_index=$RANDOM%$length_colorscripts
[[ $random_index -eq 1 ]] && random_index=1
random_colorscript="$(echo  "${list_colorscripts}" | sed -n ${random_index}p \
    | tr -d ' ' | tr '\t' ' ' | cut -d ' ' -f 2)"
echo "${random_colorscript}"
exec "./colorscripts/${random_colorscript}"
