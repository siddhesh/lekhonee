#!/usr/bin/env python
"""Lekhonee is a desktop Wordpress blog client. It is usefull for low bandwidth based connections"""
from distutils.core import setup

doclines = __doc__.split("\n")
setup(name='lekhonee',
      version='0.4.1',
      description=doclines[0],
      long_description = "\n".join(doclines[:]),
      platforms = ["Linux"],
      author='Kushal Das',
      author_email='kushal@fedoraproject.org',
      url='http://fedorahosted.org/lekhonee',
      license = 'http://www.gnu.org/copyleft/gpl.html',
      packages=['Chotha'],
      data_files=[('/usr/share/applications',['pixmaps/lekhonee.desktop','pixmaps/lekhonee-gnome.desktop']),
		  ('/etc',['Chotha/chotha.data']),
		  ('/usr/bin',['lekhonee','lekhonee-gnome']),
		  ('/usr/share/pixmaps',['pixmaps/lekhonee.png','pixmaps/lekhonee-gnome.png', 'pixmaps/chothasplash.png']),
		  ('/usr/share/chotha/docs',['docs/README','docs/LICENSE','docs/COPYING','docs/ChangeLog']),
          ('/usr/share/chotha/ui',['ui/ConfigureWin.ui', 'ui/ImageDialog.ui', 'ui/Lekhonee.ui', 'ui/OldEntryDialog.ui' ]),
          ('/usr/share/pixmaps/chotha',['icons/application-exit.png', 'icons/bold.png', 'icons/configure.png', 'icons/dialog-cancel.png', 'icons/document-open.png', 'icons/document-save.png', 'icons/draft.png', 'icons/insert-image.png', 'icons/internet.png', 'icons/italic.png', 'icons/konqueror.png', 'icons/ok.png', 'icons/subscript.png', 'icons/superscript.png', 'icons/underline.png', 'icons/document-new.png', 'icons/addpage.png']),
          ('/usr/share/chotha/gnome-frontend',['gnome-frontend/lekhonee-gnome.py','gnome-frontend/lekhonee-gnome.glade','gnome-frontend/lekhonee-gnome.gladep','gnome-frontend/draft.png','gnome-frontend/insert-image.png','gnome-frontend/internet.png'])]
      )
