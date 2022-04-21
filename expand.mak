FILES := \
	VOLI/691.PS \
	VOLI/ACCEL.PS \
	VOLI/BITMAP.PS \
	VOLI/BRUSH.PS \
	VOLI/BUTTON.PS \
	VOLI/CARETS.PS \
	VOLI/CLIP.PS \
	VOLI/CLIPBRD.PS \
	VOLI/CMPINDEX.PS \
	VOLI/COLOR.PS \
	VOLI/COMBOBOX.PS \
	VOLI/CONTROL.PS \
	VOLI/CURSORS.PS \
	VOLI/DC.PS \
	VOLI/DDE.PS \
	VOLI/DIALOG.PS \
	VOLI/EDIT.PS \
	VOLI/FILLSHP.PS \
	VOLI/FONTS.PS \
	VOLI/FRONT1.PS \
	VOLI/HOOKS.PS \
	VOLI/ICONS.PS \
	VOLI/II.PS \
	VOLI/INPUT.PS \
	VOLI/INTRO1.PS \
	VOLI/LBOX.PS \
	VOLI/LINES.PS \
	VOLI/MDI.PS \
	VOLI/MENUS.PS \
	VOLI/META.PS \
	VOLI/MOUSINP.PS \
	VOLI/MSGQUEUE.PS \
	VOLI/MSICONS.PS \
	VOLI/PAINT.PS \
	VOLI/PART1.PS \
	VOLI/PART2.PS \
	VOLI/PATH.PS \
	VOLI/PEN.PS \
	VOLI/PRINT.PS \
	VOLI/RECTGLS.PS \
	VOLI/REGIONS.PS \
	VOLI/SCRLLBR.PS \
	VOLI/STATIC.PS \
	VOLI/TIMERS.PS \
	VOLI/WINDOWS.PS \
	VOLI/WINPROP.PS \
	VOLI/WNDCLASS.PS \
	VOLI/WNDPROC.PS \
	VOLI/XFORM.PS \
	VOLII/682.PS \
	VOLII/ATOM.PS \
	VOLII/AUDINTRO.PS \
	VOLII/CMPINDEX.PS \
	VOLII/COMM.PS \
	VOLII/COMMDLG.PS \
	VOLII/CONSOLE.PS \
	VOLII/DDEML.PS \
	VOLII/DEBUG.PS \
	VOLII/DLL.PS \
	VOLII/ERRLIST.PS \
	VOLII/ERRORS.PS \
	VOLII/EVENTS.PS \
	VOLII/EXCTLPNL.PS \
	VOLII/FILEINST.PS \
	VOLII/FILEIO.PS \
	VOLII/FILESYS.PS \
	VOLII/FMEXT.PS \
	VOLII/FRONT2.PS \
	VOLII/GLOSS.PS \
	VOLII/HAND.PS \
	VOLII/HILEVEL.PS \
	VOLII/II.PS \
	VOLII/INTRO2.PS \
	VOLII/IPC.PS \
	VOLII/LINOVOL2.BAK \
	VOLII/LINOVOL2.DOC \
	VOLII/LOCALES.PS \
	VOLII/LOLEVEL.PS \
	VOLII/LZEXPAND.PS \
	VOLII/MAILSLOT.PS \
	VOLII/MANID.PS \
	VOLII/MAPFILE.PS \
	VOLII/MCICMD.PS \
	VOLII/MEDCNTRL.PS \
	VOLII/MEMORY.PS \
	VOLII/MMFILEIO.PS \
	VOLII/MMINTRO.PS \
	VOLII/MMTIMERS.PS \
	VOLII/NETWORK.PS \
	VOLII/PART3.PS \
	VOLII/PART4.PS \
	VOLII/PART5.PS \
	VOLII/PART6.PS \
	VOLII/PART7.PS \
	VOLII/PERFMON.PS \
	VOLII/PIPES.PS \
	VOLII/PROCESS.PS \
	VOLII/RASTOPCD.PS \
	VOLII/REGISTRY.PS \
	VOLII/RESOURCE.PS \
	VOLII/SCRNSAV.PS \
	VOLII/SECURITY.PS \
	VOLII/SEH.PS \
	VOLII/SEMAPHOR.PS \
	VOLII/SERVICE.PS \
	VOLII/SHELL.PS \
	VOLII/SHELLDDE.PS \
	VOLII/STRUNICD.PS \
	VOLII/SYSINFO.PS \
	VOLII/TAPE.PS \
	VOLII/TEST.PS \
	VOLII/TIME.PS \
	VOLII/VKEYS.PS \
	VOLIII/FRONT3.PS \
	VOLIII/FUNC1.PS \
	VOLIII/FUNC10.PS \
	VOLIII/FUNC11.PS \
	VOLIII/FUNC12.PS \
	VOLIII/FUNC13.PS \
	VOLIII/FUNC14.PS \
	VOLIII/FUNC15.PS \
	VOLIII/FUNC2.PS \
	VOLIII/FUNC3.PS \
	VOLIII/FUNC4.PS \
	VOLIII/FUNC5.PS \
	VOLIII/FUNC6.PS \
	VOLIII/FUNC7.PS \
	VOLIII/FUNC8.PS \
	VOLIII/FUNC9.PS \
	VOLIII/II.PS \
	VOLIII/INTRO3.PS \
	VOLIV/FRONT4.PS \
	VOLIV/FUNC1.PS \
	VOLIV/FUNC10.PS \
	VOLIV/FUNC11.PS \
	VOLIV/FUNC12.PS \
	VOLIV/FUNC13.PS \
	VOLIV/FUNC14.PS \
	VOLIV/FUNC15.PS \
	VOLIV/FUNC16.PS \
	VOLIV/FUNC2.PS \
	VOLIV/FUNC3.PS \
	VOLIV/FUNC4.PS \
	VOLIV/FUNC5.PS \
	VOLIV/FUNC6.PS \
	VOLIV/FUNC7.PS \
	VOLIV/FUNC8.PS \
	VOLIV/FUNC9.PS \
	VOLIV/II.PS \
	VOLIV/INTRO4.PS \
	VOLV/565.PS \
	VOLV/591.PS \
	VOLV/DDE1.PS \
	VOLV/FRONT5.PS \
	VOLV/II.PS \
	VOLV/INTRO5.PS \
	VOLV/MACROS1.PS \
	VOLV/MSGS1.PS \
	VOLV/MSGS2.PS \
	VOLV/MSGS3.PS \
	VOLV/MSGS4.PS \
	VOLV/MSGS5.PS \
	VOLV/MSGS6.PS \
	VOLV/STRUCT1.PS \
	VOLV/STRUCT2.PS \
	VOLV/STRUCT3.PS \
	VOLV/STRUCT4.PS \
	VOLV/STRUCT5.PS \
	VOLV/STRUCT6.PS \
	VOLV/STRUCT7.PS \
	VOLV/TYPES.PS
all: $(addprefix expand/WIN32API/,$(FILES))
expand/%.PS: source/%.PS_
	@$(info EXPAND $@)wine expand $< $@
expand/%.DOC: source/%.DO_
	@$(info EXPAND $@)wine expand $< $@
expand/%.BAK: source/%.BA_
	@$(info EXPAND $@)wine expand $< $@
