VERSION := $(shell sed -n 's/^M.version *= *"\(.*\)"/\1/p' tex/singlish.lua)
export TEXINPUTS := $(CURDIR)/tex:
export LUAINPUTS := $(CURDIR)/tex:

.PHONY: test sample ctan overleaf clean

test:
	texlua tests/run.lua

overleaf:
	rm -f singlish-overleaf.zip
	zip -qj singlish-overleaf.zip overleaf/main.tex overleaf/latexmkrc tex/singlish.sty tex/singlish.lua fonts/*
	@echo "built singlish-overleaf.zip"

sample:
	cd doc && lualatex -interaction=nonstopmode -halt-on-error singlish-sample.tex

# CTAN wants a single top-level directory named after the package
ctan: test sample
	rm -rf build && mkdir -p build/singlish
	cp README.md tex/singlish.sty tex/singlish.lua build/singlish/
	cp doc/singlish-sample.tex doc/singlish-sample.pdf doc/mapping.md build/singlish/
	mkdir -p build/singlish/fonts && cp fonts/* build/singlish/fonts/
	cd build && zip -qr ../singlish-$(VERSION).zip singlish
	@echo "built singlish-$(VERSION).zip"

clean:
	rm -rf build singlish-*.zip doc/*.aux doc/*.log doc/*.out
