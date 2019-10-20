#!/usr/bin/bash
# If a translations in def.po is duplicated with
# ref.po's, it will remove the original translation,
# and use ref.po's translations.
# Author:  pan93412.
# Version: v1.0.0-Beta.

. gettext.sh

USAGE() {
    GitURL="https://www.github.com/l10n_tw/msgapply"
    USAGE_DESC=$(eval_gettext "If a translations in def.po is duplicated with
ref.po's, it will remove the original translation,
and use ref.po's translations.")
    USAGE=$(eval_gettext "USAGE: $0 [-o OUT] def.po ref.po")
    USAGE_COMOPT=$(eval_gettext " def.po:    The PO file to be replaced.
 ref.po:    The PO file to replace.
 -o OUT:    Write the processed file to OUT.
           It will write to standard output
           if you don't specify '-o', or
           OUT is '-'.")
    USAGE_REPORT=$(eval_gettext "Please report bugs to <$GitURL>.")
    
    echo -ne "$USAGE_DESC\n$USAGE\n$USAGE_COMOPT\n$USAGE_REPORT\n"
}


if [[ $# -lt 2 ]] || [[ $# -gt 4 ]] 
then
    USAGE
    exit 1
fi

# Get arguments and check whether the arguments is vaild.
out="/dev/stdout"

if [ $1 == "-o" ]
then
    shift
    out=$1
    shift
fi

def=$1
def_bn=$(basename $def)
ref=$2

if [[ "$def" == "$out" ]] || [[ "$def" == "$ref" ]] || [[ "$ref" == "$out" ]]
then
    echo $(eval_gettext "ERROR: One of def.po, ref.po and OUT is same as another.") >/dev/stderr
fi

# Create TMP directory first.
tmpdir="~/.cache/msgapply_$RANDOM$RANDOM"
mkdir -p "$tmpdir"

# First Step: Remove obsoleted strings first.
msgattrib --no-obsolete -o "$tmpdir/${def_bn}.step1" "$def"

# Second Step: Merge ref.po into def.po
msgcat --use-first -o "$tmpdir/${def_bn}.step2" "$ref" "$tmpdir/${def_bn}.step1"

# Third Step: Remove the strings which is added from ref.po (Just preserve def.po's).
msgcomm -o "$out" "$tmpdir/${def_bn}.step2" "$def"

# Forth step: remove the useless ^M characters.
sed -i -e "s/\r//g" "$out"

# Fivth Step: Done.
if [[ "$tmpdir" == "" ]]
then
    echo $(eval_gettext "Program ERROR: Variable 'TMPDIR' isn't exist.
    Please report this bug to this program's author.") >/dev/stderr
    exit 2
else
    rm -rf "$tmpdir"
fi

echo $(eval_gettext "Please copy the copyright holder, and the PO information
of the def.po, to the processed file.") >/dev/stderr
exit 0
