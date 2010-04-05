bin_PROGRAMS = lekhonee-gnome

lekhonee_gnome_SOURCES = \
	LekhoneeDialogs.vala \
	LekhoneeOperations.vala \
	Wordpress.vala \
	LekhoneeMain.vala 

INCLUDES = \
	-include config.h \
	$(LEKHONEE_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	--vapidir=$(srcdir)/../vapi --pkg gtkspell-2.0 \
	@LEKHONEE_PACKAGES@

lekhonee_gnome_LDADD = \
	$(LEKHONEE_LIBS)
