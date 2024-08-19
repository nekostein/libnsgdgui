#!/bin/bash

mkdir -p doc/{classes_meta,classes_def} doc/.data

listfn="doc/.data/classes_list.TEX"

function _step_exported_vars() {
    grep '@export ' "$gdfn" | sed 's|$|\n|' | pandoc -f gfm -t latex
}

function work_on_gd_file() {
    gdfn="$1"
    echo "gdfn=$gdfn"
    classname="$(basename "$gdfn" | cut -d. -f1)"
    ### Step: Establish classes_list.TEX
    printf '\section{%s}\n\n' "$classname" >> "$listfn"
    printf '\input{doc/classes_meta/%s.TEX}\n\n' "$classname" >> "$listfn"
    printf '\input{doc/classes_def/%s.TEX}\n\n' "$classname" >> "$listfn"
    touch "doc/classes_def/$classname.TEX"
    metafn="doc/classes_meta/$classname.TEX"
    ### Step: Extends
    grep 'extends ' "$gdfn" | sed 's|$|\n|' > "$metafn"
    ### Step: Exported variables
    _step_exported_vars >> "$metafn"
}




echo '' > "$listfn"

find src -type f -name '*.gd' | sort | while read -r gdfn; do
    work_on_gd_file "$gdfn"
done

