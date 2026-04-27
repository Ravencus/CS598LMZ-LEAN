TEX  = TEXINPUTS=./acm-template//:$(TEXINPUTS) pdflatex
BIB  = BSTINPUTS=./acm-template//:$(BSTINPUTS) bibtex
FILE = main

all:
	$(TEX) $(FILE)
	$(BIB) $(FILE)
	$(TEX) $(FILE)
	$(TEX) $(FILE)

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.pdf *.fdb_latexmk *.fls *.synctex.gz

.PHONY: all clean
