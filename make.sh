#!/bin/bash

function try_make_guessed_line() {
    line="$1"
    filepath="$(tr -d ' ' <<< "$line" | sed 's/)//g')"
    if [[ -e "$filepath" ]]; then
        ./make.sh "$filepath"
    fi
}


echo '$' make.sh "$@"
case $1 in
    doc/MANUAL.tex)
        bash sh/classes-tex.sh
        ntex doc/MANUAL.tex
        ;;
    all | '')
        while read -r line; do
            try_make_guessed_line "$line"
        done < make.sh
        ;;
esac
