# This file is part of mingw-cross-env.
# See doc/index.html for further information.

# GNU Guile
PKG             := guile
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.8.7
$(PKG)_CHECKSUM := 24cd2f06439c76d41d982a7384fe8a0fe5313b54
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_WEBSITE  := http://www.gnu.org/software/$(PKG)/
$(PKG)_URL      := http://ftp.gnu.org/gnu/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc libtool gmp libiconv gettext readline

define $(PKG)_UPDATE
    wget -q -O- 'http://git.savannah.gnu.org/gitweb/?p=$(PKG).git;a=tags' | \
    grep '<a class="list subject"' | \
    $(SED) -n 's,.*<a[^>]*>[^0-9>]*\([0-9][^< ]*\)\.<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # avoid running the autotools after patching
    find '$(1)' -name 'aclocal.m4'  -exec touch {} \;
    find '$(1)' -name 'configure'   -exec touch {} \;
    find '$(1)' -name 'Makefile.in' -exec touch {} \;
    find '$(1)' -name '*.h.in'      -exec touch {} \;
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-shared \
        --with-threads \
        LIBS='-lintl -liconv'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-guile.exe' \
        `'$(TARGET)-pkg-config' guile-1.8 --cflags --libs`
endef