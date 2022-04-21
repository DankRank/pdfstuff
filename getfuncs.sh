#!/bin/sh
# vim: ft=awk
awk '
BEGIN { OFS="\t" }
/ font$/ { is_heading = / 333 333 / }
/^%%Page:/ { pageno++ }
/\([^ ]*\) [0-9]+ SB$/ && is_heading {
	print "",gensub(/^.*\((.*)\).*$/, "\\1", 1),PREFIX pageno
}
' "$@"
