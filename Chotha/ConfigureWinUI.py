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
import cPickle
from resource_rc import *
from ConfigureWinui import *

#Setup dialogs
#Ui_configureDialog, throwaway = uic.loadUiType(os.path.join('/usr/share/chotha','ui','ConfigureWin.ui'))


class ConfigureWinUI(QtGui.QDialog, Ui_ConfigureWin):
    def __init__(self,parent, start=0):
        QtGui.QDialog.__init__(self)
        self.setupUi(self)
        if start != 0:
            self.cancelBttn.setEnabled(False)
        self.parent = parent
        self.connect(self.saveBttn,QtCore.SIGNAL("clicked()"),self.save)
        self.connect(self.cancelBttn,QtCore.SIGNAL("clicked()"),self.hide)
        self.serverTxt.setText(self.parent.Server)
        self.usernameTxt.setText(self.parent.username)
        self.passwordTxt.setText(self.parent.password)


    def save(self):
        """save details if using kwallet"""
        self.username = str(self.usernameTxt.text())
        self.password = str(self.passwordTxt.text())
        self.server = str(self.serverTxt.text())

        self.hide()
        self.emit(QtCore.SIGNAL("saved()"))
