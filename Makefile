.PHONY: all clean cleanfinal extract
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
	$(VOLS:.pdf=-toc.pdf) \
	combined-toc.pdf \
	win32api.pdf \
	win32api1.pdf \
	win32api2.pdf

# This is fairly slow, so don't redo it on every pdfstuff update.
combined.pdf: $(VOLS) | pdfstuff
	@$(info CONCAT   $@) \
	./pdfstuff $(addprefix --append ,$(VOLS)) \
		--title "Programmer's Reference" \
		--write $@
combined12.pdf: vol1.pdf vol2.pdf | pdfstuff
	@$(info CONCAT   $@) \
	./pdfstuff $(addprefix --append ,vol1.pdf vol2.pdf) \
		--title "Programmer's Reference, Volumes 1 & 2" \
		--write $@
combined345.pdf: vol3.pdf vol4.pdf vol5.pdf | pdfstuff
	@$(info CONCAT   $@) \
	./pdfstuff $(addprefix --append ,vol3.pdf vol4.pdf vol5.pdf) \
		--title "Programmer's Reference, Volumes 3, 4 & 5" \
		--write $@
MEDIABOX=--box media 4050 7200 53100 64800
vol1.tmp.pdf: $(VOL1_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOL1_FILES)
vol2.tmp.pdf: $(VOL2_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOL2_FILES)
vol3.tmp.pdf: $(VOL3_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOL3_FILES)
vol4.tmp.pdf: $(VOL4_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOL4_FILES)
vol5.tmp.pdf: $(VOL5_FILES) ps2pdf-multi.sh
	@$(info PS2PDFM  $@) ./ps2pdf-multi.sh $@ $(VOL5_FILES)
vol1.pdf: vol1.tmp.pdf pdfstuff
	@$(info TWEAK    $@) \
	./pdfstuff --read $< $(MEDIABOX) --title "Programmer's Reference, Volume 1" --write $@
vol2.pdf: vol2.tmp.pdf pdfstuff
	@$(info TWEAK    $@) \
	./pdfstuff --read $< $(MEDIABOX) --title "Programmer's Reference, Volume 2" --write $@
vol3.pdf: vol3.tmp.pdf pdfstuff
	@$(info TWEAK    $@) \
	./pdfstuff --read $< $(MEDIABOX) --title "Programmer's Reference, Volume 3" --write $@
vol4.pdf: vol4.tmp.pdf pdfstuff
	@$(info TWEAK    $@) \
	./pdfstuff --read $< $(MEDIABOX) --title "Programmer's Reference, Volume 4" --write $@
vol5.pdf: vol5.tmp.pdf pdfstuff
	@$(info TWEAK    $@) \
	./pdfstuff --read $< $(MEDIABOX) --title "Programmer's Reference, Volume 5" --write $@

CXXFLAGS=-std=c++17 -O2 -Wall -Wextra
LDLIBS=-lpodofo
pdfstuff: pdfstuff.cc
	@$(info CXX      $@)$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

vol1-toc.pdf: vol1.num vol1.toc vol1.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read vol1.pdf --num vol1.num --toc vol1.toc --write $@
vol2-toc.pdf: vol2.num vol2.toc vol2.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read vol2.pdf --num vol2.num --toc vol2.toc --write $@
vol3-toc.pdf: vol3.num vol3.toc vol3.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read vol3.pdf --num vol3.num --toc vol3.toc --write $@
vol4-toc.pdf: vol4.num vol4.toc vol4.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read vol4.pdf --num vol4.num --toc vol4.toc --write $@
vol5-toc.pdf: vol5.num vol5.toc vol5.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read vol5.pdf --num vol5.num --toc vol5.toc --write $@
combined-toc.pdf: combined.num combined.toc combined.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read combined.pdf --num combined.num --toc combined.toc --write $@
win32api.pdf: combined.num simplified.toc combined.pdf pdfstuff
	@$(info ADDTOC   $@) \
	./pdfstuff --read combined.pdf --num combined.num --toc simplified.toc --write $@
win32api1.pdf: combined12.num simplified.toc combined12.pdf pdfstuff
	@$(info ADDTOC   $@) \
	sed '/III-1$$/,$$d' <simplified.toc | \
	./pdfstuff --read combined12.pdf --num combined12.num --toc /dev/stdin --write $@
win32api2.pdf: combined345.num simplified.toc combined345.pdf pdfstuff
	@$(info ADDTOC   $@) \
	sed -n '/III-1$$/,$$p' <simplified.toc | \
	./pdfstuff --read combined345.pdf --num combined345.num --toc /dev/stdin --write $@

combined.toc: combinedtoc.sh $(VOLS:.pdf=.toc)
	@$(info GENTOC   $@)./combinedtoc.sh >$@
simplified.toc: simplifiedtoc.sh combined.toc expand.dir
	@$(info GENTOC   $@)./simplifiedtoc.sh >$@

.PRECIOUS: nomarks/%.PS pdfbase/%.PDF
nomarks/%.PS: nomarks.dir expand.dir
	@$(info NOMARKS  $@) \
	sed '/^DoCropMarks/d;/^DoPageBox/d' <$(patsubst nomarks/%,expand/%,$@) >$@
pdfbase/%.PDF: nomarks/%.PS pdfbase.dir
	@$(info PDF2PS   $@) \
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
	$(RM) pdfstuff combined.pdf $(VOLS) combined.toc combined-toc.pdf win32api.pdf \
		$(VOLS:.pdf=-toc.pdf) $(VOLS:.pdf=.tmp.pdf) \
		combined12.pdf combined345.pdf win32api1.pdf win32api2.pdf \
		c90.pdf
extract:
	bsdtar -xf source/Disk01.iso -C source --strip-components=2 DOC/SDK/WIN32API

c90.pdf: source/ansi-iso-9899-1990-1.pdf c90.num c90.toc pdfstuff
	@$(info ADDTOC   $@)./pdfstuff --read $< --num c90.num --toc c90.toc \
		--title "ANSI/ISO 9899-1990" \
		--write $@
