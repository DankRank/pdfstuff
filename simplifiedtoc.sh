#/bin/sh
# vim: ft=awk
awk <combined.toc '
BEGIN{FS=OFS="\t"}
{
	title = $(NF-1)
	page = $NF
	if(page ~ /^I-/) { vol = 1 }
	else if (page ~ /^II-/) { vol = 2 }
	else if (page ~ /^III-/) { vol = 3 }
	else if (page ~ /^IV-/) { vol = 4 }
	else if (page ~ /^V-/) { vol = 5 }

	if (page ~ /-[ivx]/) { in_intro = 1 }
	if (page ~ /-1$/) { in_intro = 0 }

	if (in_intro && vol != 1)
		next
	if (NF == 2)
		next
	if (vol == 1 && title == "Index")
		next
	if (vol == 3 && title == "Alphabetic Reference (A–G)") {
		$(NF-1) = "Functions"
		do_funcs = 1
	}
	if (vol == 4 && title == "Alphabetic Reference (H–Z)")
		next
	if (vol == 5) {
		if (title == "Alphabetic Reference" || title == "1.1  Data Types")
			next
		if (title == "Chapter 2    Messages") do_messages = 1;
		if (title == "Chapter 3    Structures") do_structs = 1;
		if (title == "Chapter 4    Macros") do_macros = 1;
		if (title == "Chapter 5    Dynamic Data Exchange Transactions") do_dde = 1;
	}
	
	for (i = 1; i < NF; i++)
		$i = $(i+1)
	NF--
	gsub(/^.+  +/, "", $(NF-1))
	print
	if (do_funcs) {
		system("./getfuncs.sh " \
			"PREFIX=III- $(for i in $(seq 15); do echo expand/WIN32API/VOLIII/FUNC$i.PS; done) " \
			"PREFIX=IV- pageno=0 $(for i in $(seq 16); do echo expand/WIN32API/VOLIV/FUNC$i.PS; done)")
		do_funcs = 0
	}
	if (do_messages) {
		system("./getfuncs.sh PREFIX=V- pageno=8 $(for i in $(seq 6); do echo expand/WIN32API/VOLV/MSGS$i.PS; done)")
		do_messages = 0
	}
	if (do_structs) {
		system("./getfuncs.sh PREFIX=V- pageno=302 $(for i in $(seq 7); do echo expand/WIN32API/VOLV/STRUCT$i.PS; done)")
		do_structs = 0
	}
	if (do_macros) {
		system("./getfuncs.sh PREFIX=V- pageno=650 expand/WIN32API/VOLV/MACROS1.PS")
		do_macros = 0
	}
	if (do_dde) {
		system("./getfuncs.sh PREFIX=V- pageno=670 expand/WIN32API/VOLV/DDE1.PS")
		do_dde = 0
	}
}
'
