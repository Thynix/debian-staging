#!/bin/sh
# Customise a service-wrapper init.d script, either an upstream-type sh.script,
# or a truncated init.d as generated by build-wrapper-sh.sh
#
# NB: currently, property values cannot contain the character "|"

PARAM_FILE="$1"
PREINIT_SH="$2"
INITD_TMPL="$3"

if [ -z "$INITD_TMPL" ]; then INITD_TMPL=init.d; fi
if [ ! -f "$INITD_TMPL" ]; then echo >&2 "not found: $INITD_TMPL"; exit 1; fi

# splice params

SED_ARGS=""
push_sed_expr() { SED_ARGS="$SED_ARGS -e '$1'"; }

cat "$PARAM_FILE" | {

read APP_NAME
push_sed_expr "s/@app.name@/$APP_NAME/g"

read APP_LONG_NAME
push_sed_expr "s/@app.long.name@/$APP_LONG_NAME/g"

read APP_DESCRIPTION
push_sed_expr "s/@app.description@/$APP_DESCRIPTION/g"

while read ARG VAL; do
	push_sed_expr 's|^\s*#\?\s*\('"$ARG"'=\).*|\1"'"$VAL"'"|g'
done

eval sed -i $SED_ARGS "$INITD_TMPL"

}

# splice preinit snippets

LINE="$(sed -n "/WRAPPER_PREINIT START/=" "$INITD_TMPL")"
#sed -i -e "${LINE}{x;p;x;}" "$INITD_TMPL"
sed -i -e "${LINE}r $PREINIT_SH" "$INITD_TMPL"
