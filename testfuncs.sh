#!/bin/sh
# this is a just copy of what's used in simplified toc.sh
./getfuncs.sh \
	PREFIX=III- $(for i in $(seq 15); do echo expand/WIN32API/VOLIII/FUNC$i.PS; done) \
	PREFIX=IV- pageno=0 $(for i in $(seq 16); do echo expand/WIN32API/VOLIV/FUNC$i.PS; done) \
	PREFIX=V- pageno=8 $(for i in $(seq 6); do echo expand/WIN32API/VOLV/MSGS$i.PS; done) \
	PREFIX=V- pageno=302 $(for i in $(seq 7); do echo expand/WIN32API/VOLV/STRUCT$i.PS; done) \
	PREFIX=V- pageno=650 expand/WIN32API/VOLV/MACROS1.PS \
	PREFIX=V- pageno=670 expand/WIN32API/VOLV/DDE1.PS
