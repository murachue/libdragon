INSTALLDIR = $(N64_INST)
CFLAGS = -m32 -std=gnu99 -O2 -Wall -Werror -I../../include

all: mkdfs

mkdfs: mkdfs.c

install: mkdfs
	install -D --mode=755 mkdfs $(INSTALLDIR)/bin

.PHONY: clean install

clean:
	rm -rf mkdfs
