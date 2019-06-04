# This Makefile is only used for packaging, and should not be used in any other
# context

.PHONY: all clean install

all:
	@# Do nothing

clean:
	@# Do nothing

install:
	package-scripts/install.sh $(DESTDIR)
