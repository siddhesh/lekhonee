# configure.ac

AC_INIT([lekhonee-gnome], [0.9])
AC_CONFIG_SRCDIR([src/LekhoneeMain.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

# Enable silent rules is available
#m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.7.10])
AC_PROG_INSTALL
AC_PROG_INTLTOOL([0.35])

# check for LIBXML2
pkg_modules="libxml-2.0 >= 2.4.0"
PKG_CHECK_MODULES(LIBXML2, [$pkg_modules])
AC_SUBST(LIBXML2_CFLAGS)
AC_SUBST(LIBXML2_LIBS)

# check for GTKSOURCEVIEW
pkg_modules="gtksourceview-2.0"
PKG_CHECK_MODULES(GTKSOURCEVIEW, [$pkg_modules])
AC_SUBST(GTKSOURCEVIEW_CFLAGS)
AC_SUBST(GTKSOURCEVIEW_LIBS)

# check for WEBKIT
pkg_modules="webkit-1.0 >= 1.0"
PKG_CHECK_MODULES(WEBKIT, [$pkg_modules])
AC_SUBST(WEBKIT_CFLAGS)
AC_SUBST(WEBKIT_LIBS)

# check for WEBKIT
pkg_modules="gtkspell-2.0 >= 2.0"
PKG_CHECK_MODULES(GTKSPELL, [$pkg_modules])
AC_SUBST(GTKSPELL_CFLAGS)
AC_SUBST(GTKSPELL_LIBS)

# check for Libsoup
pkg_modules="libsoup-2.4 >= 2.4"
PKG_CHECK_MODULES(LIBSOUP, [$pkg_modules])
AC_SUBST(LIBSOUP_CFLAGS)
AC_SUBST(LIBSOUP_LIBS)




pkg_modules="gtk+-2.0 >= 2.14.0"
LEKHONEE_PACKAGES="--pkg libxml-2.0 --pkg gtk+-2.0 --pkg gmodule-2.0 --pkg gtksourceview-2.0 --pkg webkit-1.0 --pkg gio-2.0 --thread "
LEKHONEE_CFLAGS="`pkg-config --cflags libxml-2.0 gtk+-2.0 gmodule-2.0 gtksourceview-2.0 webkit-1.0 gio-2.0 gtkspell-2.0`"
LEKHONEE_LIBS="`pkg-config --libs libxml-2.0 gtk+-2.0 gmodule-2.0 gtksourceview-2.0 webkit-1.0 gio-2.0 gtkspell-2.0`"
PKG_CHECK_MODULES(LEKHONEE, [$pkg_modules])
AC_SUBST(LEKHONEE_CFLAGS)
AC_SUBST(LEKHONEE_LIBS)
AC_SUBST(LEKHONEE_PACKAGES)

GETTEXT_PACKAGE=lekhonee-gnome
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
ALL_LINGUAS="bn_IN bb da de es fr hi hu it nl pl ps pt_BR ru sr@latin sr uk zh_CN zh_TW"
AM_GLIB_GNU_GETTEXT


AC_CONFIG_FILES([
	Makefile
	data/lekhonee-gnome.desktop.in
	data/Makefile
        data/icons/Makefile
        ui/Makefile
	po/Makefile.in
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
