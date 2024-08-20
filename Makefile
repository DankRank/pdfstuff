.PHONY: all all2 clean cleanfinal extract win103
.SUFFIXES:
VOL1 := \
	FRONT1   \
	INTRO1   \
	PART1    \
	WINDOWS  MSGQUEUE WNDCLASS WNDPROC  \
	INPUT    MOUSINP  TIMERS   HOOKS    \
	CONTROL  BUTTON   LBOX     EDIT     \
	COMBOBOX SCRLLBR  STATIC   MENUS    \
	ACCEL    DIALOG   RECTGLS  PAINT    \
	CURSORS  CARETS   ICONS    WINPROP  \
	CLIPBRD  DDE      MDI               \
	PART2    \
	DC       BITMAP   BRUSH    PEN      \
	REGIONS  LINES    FILLSHP  FONTS    \
	COLOR    PATH     CLIP     XFORM    \
	META     PRINT                      \
	CMPINDEX
VOL2 := \
	FRONT2   \
	INTRO2   \
	PART3    \
	MEMORY   PROCESS  SEMAPHOR FILEIO   \
	FILESYS  MAPFILE  HAND     SECURITY \
	DLL      RESOURCE REGISTRY STRUNICD \
	PIPES    MAILSLOT NETWORK  CONSOLE  \
	SERVICE  TAPE     TIME     ATOM     \
	DEBUG    ERRORS   SEH      EVENTS   \
	PERFMON  SYSINFO  COMM              \
	PART4    \
	MMINTRO  MEDCNTRL AUDINTRO HILEVEL  \
	LOLEVEL  MMTIMERS MMFILEIO          \
	PART5    \
	COMMDLG  DDEML    SHELL    SCRNSAV  \
	FILEINST LZEXPAND                   \
	PART6    \
	EXCTLPNL FMEXT    SHELLDDE IPC      \
	PART7    \
	ERRLIST  VKEYS    LOCALES  MANID    \
	MCICMD   RASTOPCD GLOSS             \
	CMPINDEX
VOL3 := \
	FRONT3   \
	INTRO3   \
	FUNC1    FUNC2    FUNC3    FUNC4    \
	FUNC5    FUNC6    FUNC7    FUNC8    \
	FUNC9    FUNC10   FUNC11   FUNC12   \
	FUNC13   FUNC14   FUNC15
VOL4 := \
	FRONT4   \
	INTRO4   \
	FUNC1    FUNC2    FUNC3    FUNC4    \
	FUNC5    FUNC6    FUNC7    FUNC8    \
	FUNC9    FUNC10   FUNC11   FUNC12   \
	FUNC13   FUNC14   FUNC15   FUNC16
VOL5 := \
	FRONT5   \
	INTRO5   \
	TYPES    \
	MSGS1    MSGS2    MSGS3    MSGS4    \
	MSGS5    MSGS6                      \
	STRUCT1  STRUCT2  STRUCT3  STRUCT4  \
	STRUCT5  STRUCT6  STRUCT7           \
	MACROS1  \
	DDE1

VOL1_FILES:=$(addsuffix .PS,$(addprefix nomarks/WIN32API/VOLI/,$(VOL1)))
VOL2_FILES:=$(addsuffix .PS,$(addprefix nomarks/WIN32API/VOLII/,$(VOL2)))
VOL3_FILES:=$(addsuffix .PS,$(addprefix nomarks/WIN32API/VOLIII/,$(VOL3)))
VOL4_FILES:=$(addsuffix .PS,$(addprefix nomarks/WIN32API/VOLIV/,$(VOL4)))
VOL5_FILES:=$(addsuffix .PS,$(addprefix nomarks/WIN32API/VOLV/,$(VOL5)))
VOLS_FILES:=$(VOL1_FILES) $(VOL2_FILES) $(VOL3_FILES) $(VOL4_FILES) $(VOL5_FILES)
VOLS:=vol1.pdf vol2.pdf vol3.pdf vol4.pdf vol5.pdf

# These are extracted by the expand.dir rule
	#expand/WIN32API/VOLI/MSICONS.PS
	#expand/WIN32API/VOLII/LINOVOL2.DOC
	#expand/WIN32API/VOLII/LINOVOL2.BAK
# Out of all of the following extra files only VOLI/691 seems to have an actual
# visible difference. (One of the special chars is missing in the original)
all: \
	pdfstuff \
	pdfbase/WIN32API/VOLI/II.PDF \
	pdfbase/WIN32API/VOLI/691.PDF \
	pdfbase/WIN32API/VOLII/II.PDF \
	pdfbase/WIN32API/VOLII/682.PDF \
	pdfbase/WIN32API/VOLII/TEST.PDF \
	pdfbase/WIN32API/VOLIII/II.PDF \
	pdfbase/WIN32API/VOLIV/II.PDF \
	pdfbase/WIN32API/VOLV/II.PDF \
	pdfbase/WIN32API/VOLV/565.PDF \
	pdfbase/WIN32API/VOLV/591.PDF \
	win32api.pdf

MEDIABOX=--box media 4050 7200 53100 64800
include attic.mak
include pdfstuff.mak
win32api.tmp.pdf: $(VOLS_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOLS_FILES)
win32api.pdf: combined.num simplified.toc win32api.tmp.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read win32api.tmp.pdf \
		$(MEDIABOX) \
		--num combined.num --toc simplified.toc \
		--title "Programmer's Reference" \
		--write $@
combined.toc: combinedtoc.sh $(VOLS:.pdf=.toc)
	@$(info GENTOC   $@)./combinedtoc.sh >$@
simplified.toc: simplifiedtoc.sh combined.toc expand.dir
	@$(info GENTOC   $@)./simplifiedtoc.sh >$@

.PRECIOUS: nomarks/%.PS pdfbase/%.PDF
nomarks/%.PS: nomarks.dir expand.dir
	@$(info NOMARKS  $@) \
	sed '/^DoCropMarks/d;/^DoPageBox/d' <$(patsubst nomarks/%,expand/%,$@) >$@
pdfbase/%.PDF: nomarks/%.PS pdfbase.dir
	@$(info PS2PDF   $@) \
	ps2pdf13 $< $@

MAKEDIRS=@$(info MAKEDIRS $(@:.dir=))mkdir -p \
		$(@:.dir=)/WIN32API/VOLI \
		$(@:.dir=)/WIN32API/VOLII \
		$(@:.dir=)/WIN32API/VOLIII \
		$(@:.dir=)/WIN32API/VOLIV \
		$(@:.dir=)/WIN32API/VOLV

# Recursive make considered useful for once?
# 1) I don't want to touch the extracted files to update their mtime, so it's
# actually a good thing that we don't let this makefile know about them.
# 2) Normally, Wine has an annoying delay when starting the application, and I
# want to make sure it's taken care of.
# 3) However, I don't want to use a regular shell script, since that won't
# take advantage of the -j option.
expand.dir: expand.mak
	$(MAKEDIRS)
	@-wineserver -p 5
	@$(MAKE) -f expand.mak
	@touch $@
nomarks.dir:
	$(MAKEDIRS)
	@touch $@
pdfbase.dir:
	$(MAKEDIRS)
	@touch $@

clean: cleanfinal
	$(RM) -r expand nomarks pdfbase
	$(RM) expand.dir nomarks.dir pdfbase.dir
cleanfinal:
	$(RM) pdfstuff combined.toc simplified.toc win32api.pdf \
		c90.pdf dos2.pdf ewd123.pdf knrc1.pdf \
		win103-1.pdf win103-2.pdf win103-3.pdf win103-4.pdf win103-5.pdf win103-6.pdf win103-7.pdf
extract:
	bsdtar -xf source/Disk01.iso -C source --strip-components=2 DOC/SDK/WIN32API

# Debian linked a version of podofo that doesn't support OpenSSL 3.0 against
# OpenSSL 3.0, and now we're stuck with it for two years, as usual.
# Also this config format is ridiculous.
STUPID_DEBIAN_12_FIX=OPENSSL_CONF=openssl.cnf

c90.pdf: source/ansi-iso-9899-1990-1.pdf c90.num c90.toc pdfstuff
	@$(info ADDTOC   $@)$(STUPID_DEBIAN_12_FIX) ./pdfstuff --read $< --num c90.num --toc c90.toc \
		--title "ANSI/ISO 9899-1990" \
		--write $@

win103-1.pdf: source/win103/1\ -\ Welcome.pdf win103-1.num win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-1.num --toc-clear --pagemode none \
		--title "$$(sed -n 1p win103.title)" --write $@
win103-2.pdf: source/win103/2\ -\ Microsoft\ Windows\ 1.03\ Update.pdf win103-2.num win103-2.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-2.num --toc-clear --toc win103-2.toc \
		--title "$$(sed -n 2p win103.title)" --write $@
win103-3.pdf: source/win103/3\ -\ Programmers\ Utility\ Guide.pdf win103-3.num win103-3.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-3.num --toc-clear --toc win103-3.toc \
		--title "$$(sed -n 3p win103.title)" --write $@
win103-4.pdf: source/win103/4\ -\ Quick\ Reference.pdf win103-4.num win103-4.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-4.num --toc-clear --toc win103-4.toc \
		--title "$$(sed -n 4p win103.title)" --write $@
win103-5.pdf: source/win103/5\ -\ Windows\ Programming\ Guide.pdf win103-5.num win103-5.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-5.num --toc-clear --toc win103-5.toc \
		--title "$$(sed -n 5p win103.title)" --write $@
win103-6.pdf: source/win103/6\ -\ Application\ Style\ Guide.pdf win103-6.num win103-6.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-6.num --toc-clear --toc win103-6.toc \
		--title "$$(sed -n 6p win103.title)" --write $@
win103-7.pdf: source/win103/7\ -\ Progammers\ Reference.pdf win103-7.num win103-7.toc win103.title pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num win103-7.num --toc-clear --toc win103-7.toc \
		--title "$$(sed -n 7p win103.title)" --write $@
win103: win103-1.pdf win103-2.pdf win103-3.pdf win103-4.pdf win103-5.pdf win103-6.pdf win103-7.pdf

dos2.pdf: source/Microsoft_Programmers_Reference_Manual_MSDOS_2.0.pdf dos2.num dos2.toc pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read $< --num dos2.num --toc dos2.toc \
		--title "MS-DOS Programmer's Reference Manual" \
		--write $@

ewd123.pdf: source/EWD123.PDF ewd123.num ewd123.toc pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read $< --num ewd123.num --toc ewd123.toc \
		--title "Cooperating sequential processes (EWD123)"\
		--write $@

knrc1.pdf: source/The\ C\ Programming\ Language\ First\ Edition\ [UA-07].pdf knrc1.num knrc1.toc pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read '$<' --num knrc1.num --toc knrc1.toc \
		--title "The C Programming Language (First Edition)" \
		--write $@

all2: all c90.pdf win103 dos2.pdf ewd123.pdf knrc1.pdf
