MAD_VERSION:=0.15.1b
MAD:=libmad-$(MAD_VERSION)

EMCC:=emcc
EXPORTED_FUNCTIONS:='["_mad_js_init", "_mad_js_id3_len", "_mad_js_fill_buffer", \
	"_mad_js_close", "_mad_js_after_read", "_mad_js_decode_frame", "_mad_js_pack_frame"]'
CFLAGS:=-I$(MAD) -O2 -s ASM_JS=1 -s USE_TYPED_ARRAYS=2
LINKFLAGS:=$(CFLAGS) -s EXPORTED_FUNCTIONS=$(EXPORTED_FUNCTIONS)
EMCONFIGURE:=emconfigure
EMMAKE:=emmake
MAD_URL:="ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz"
TAR:=tar
AUTORECONF:=$(shell which autoreconf)

all: dist/libmad.js

dist/libmad.js: $(MAD) src/mad-source.js src/wrapper.o src/pre.js src/post.js src/library.js
	$(EMCC) $(LINKFLAGS) --pre-js src/pre.js --post-js src/post.js --post-js src/mad-source.js --js-library src/library.js $(wildcard $(MAD)/*.o) src/wrapper.o -o $@

src/mad-source.js: src/mad-source.coffee
	coffee -c src/mad-source.coffee

$(MAD): $(MAD).tar.gz
	$(TAR) xzvf $@.tar.gz && \
	cd $@ && \
	touch NEWS AUTHORS ChangeLog && \
	([ ! -x $(AUTORECONF) ] || $(AUTORECONF) --install) && \
	$(EMCONFIGURE) ./configure --enable-fpm=no CFLAGS="$(CFLAGS)" && \
	$(EMMAKE) make

$(MAD).tar.gz:
	test -e "$@" || wget $(MAD_URL)

clean:
	$(RM) -rf $(MAD)

src/wrapper.o: src/wrapper.c
	$(EMCC) $(CFLAGS) -I$(MAD) -c $< -o $@

distclean: clean
	$(RM) $(MAD).tar.gz

.PHONY: clean distclean
