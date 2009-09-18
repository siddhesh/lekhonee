#!/usr/bin/env python
"""Lekhonee is a desktop Wordpress blog client. It is usefull for low bandwidth based connections
lekhonee-gnome is the gnome frontend"""
from distutils.core import setup
from DistUtilsExtra.command import *

doclines = __doc__.split("\n")
setup(name='lekhonee-gnome',
      version='0.7',
      description=doclines[0],
      long_description = "\n".join(doclines[:]),
      platforms = ["Linux"],
      author='Kushal Das',
      author_email='kushal@fedoraproject.org',
      url='http://fedorahosted.org/lekhonee',
      license = 'http://www.gnu.org/copyleft/gpl.html',
      data_files=[('/usr/share/applications',['pixmaps/lekhonee-gnome.desktop']),
		  ('/usr/bin',['lekhonee-gnome']),
		  ('/usr/share/pixmaps',['pixmaps/lekhonee-gnome.png']),
          ('/usr/share/chotha/gnome-frontend',['lekhonee-gnome.py','lekhonee-gnome.glade','lekhonee-gnome.gladep','draft.png','insert-image.png','internet.png'])],

        cmdclass = { "build" : build_extra.build_extra,
                     "build_i18n" : build_i18n.build_i18n },
      )
