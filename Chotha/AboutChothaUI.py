#####################################################################
#
#       Author : Kushal Das
#       Copyright (c)  2007 Kushal Das
#       kushal@fedoraproject.org
#       
#       Copyright: See COPYING file that comes with this distribution
#
#
#####################################################################

from PyQt4 import QtCore, QtGui
from PyQt4 import uic
import os

#Setup dialogs
Ui_AboutDialog, throwaway = uic.loadUiType(os.path.join('/usr/share/chotha','ui','AboutChothaUI.ui'))

class AboutChothaUI(QtGui.QDialog, Ui_AboutDialog):
    def __init__(self,parent):
        QtGui.QDialog.__init__(self)
        self.setupUi(self)
        self.show()
        self.exec_()
