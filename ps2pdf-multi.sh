#!/bin/sh
# this exactly what ps2pdf13 does, except with multiple files (hence why the repeated options)
out=$1
shift
exec gs \
	-P- -dSAFER -dCompatibilityLevel=1.3 \
	-q -P- -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sstdout=%stderr -sOutputFile="$out" \
	-P- -dSAFER -dCompatibilityLevel=1.3 \
	"$@"
