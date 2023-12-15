# Makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXAUTO    = sphinx-autobuild
SRC           = srcs
PUBLISH       = docs

.PHONY: help clean serve

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  serve    to run all doctests embedded in the documentation (if enabled)"

clean:
	-rm -rf $(PUBLISH)/*

serve:
	$(SPHINXAUTO) $(SRC) $(PUBLISH)
	
	@echo
	@echo "Build finished. The HTML pages are in $(PUBLISH)."

publish:
	cd $(PUBLISH) && echo "cs102doc.stickmind.com" > CNAME
