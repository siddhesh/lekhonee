
VALAC = valac

SOURCES = LekhoneeMain.vala Wordpress.vala
 
PACKAGES =  --pkg libxml-2.0 --pkg gtk+-2.0 --pkg gmodule-2.0 --pkg gtksourceview-2.0 --pkg webkit-1.0 --thread

OUTPUTS = lekhonee-gnome

DIST_FILES = $(SOURCES) \
             Makefile \
             gedit-2.20.deps gedit-2.20.vapi valencia.gedit-plugin \
             AUTHORS COPYING INSTALL NEWS README THANKS
DIST_TAR = $(PLUGIN)-$(VERSION).tar
DIST_TAR_BZ2 = $(DIST_TAR).bz2

lekhonee-gnome: $(SOURCES)
	$(VALAC) -g $(PACKAGES) $^ -o $@


$(DIST_TAR_BZ2): $(DIST_FILES)
	tar -cv $(DIST_FILES) > $(DIST_TAR)
	bzip2 $(DIST_TAR)

dist: $(DIST_TAR_BZ2)

clean:
	rm -f $(SOURCES:.vala=.c) $(SOURCES:.vala=.h) lekhonee-gnome

