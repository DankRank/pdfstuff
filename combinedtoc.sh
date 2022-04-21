#!/bin/sh
prefix() {
	awk <$1 'BEGIN{FS=OFS="\t"} {$NF = "'"$2"'"$NF; $1 = "\t"$1; print}'
}
echo 'Volume 1    Window Management	I-i'
prefix vol1.toc I-
echo 'Volume 2    System Services, Multimedia, Extensions, and Application Notes	II-i'
prefix vol2.toc II-
echo 'Volume 3    Functions A-H	III-i'
prefix vol3.toc III-
echo 'Volume 4    Functions H-Z	IV-i'
prefix vol4.toc IV-
echo 'Volume 5    Messages, Structures, and Macros	V-i'
prefix vol5.toc V-
