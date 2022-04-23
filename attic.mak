# old targets I don't particularly care about
.PHONY: attic-all attic-clean
attic-all: \
	$(VOLS:.pdf=-toc.pdf) \
	combined-toc.pdf \
	win32api0.pdf \
	win32api1.pdf \
	win32api2.pdf
attic-clean:
	$(RM) $(VOLS) combined.pdf combined-toc.pdf \
		$(VOLS:.pdf=-toc.pdf) $(VOLS:.pdf=.tmp.pdf) \
		combined12.pdf combined345.pdf win32api0.pdf win32api1.pdf win32api2.pdf
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
win32api0.pdf: combined.num simplified.toc combined.pdf pdfstuff
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
