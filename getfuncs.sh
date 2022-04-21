#!/bin/sh
# vim: ft=awk
awk '
BEGIN { OFS="\t" }
/ font
/^%%Page:/ { pageno++ }
/\([^ ]*\) [0-9]+ SB
	print "",gensub(/^.*\((.*)\).*$/, "\\1", 1),PREFIX pageno
}
' "$@"