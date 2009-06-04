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
    def __init__(self,parent, wallet, start=0):
        QtGui.QDialog.__init__(self)
        self.setupUi(self)
        if start != 0:
            self.cancelBttn.setEnabled(False)
        self.wallet = wallet
        self.parent = parent
        self.connect(self.saveBttn,QtCore.SIGNAL("clicked()"),self.save)
        self.connect(self.cancelBttn,QtCore.SIGNAL("clicked()"),self.hide)
        if self.wallet:
            if not self.wallet.setFolder('lekhonee'):
                self.wallet.createFolder('lekhonee')
                self.wallet.setFolder('lekhonee')
                self.wallet.writeEntry('username','admin')
                self.wallet.writeEntry('site','http://yoursite.com/xmlrpc.php')
                self.wallet.writePassword('password','changeme')

            x = QtCore.QByteArray()
            try:
                self.wallet.readEntry('username',x)
            except:
                self.wallet.writeEntry('username','admin')
                self.wallet.readEntry('username',x)
            self.username = str(x)
            server = QtCore.QByteArray()
            try:
                self.wallet.readEntry('site',server)
            except:
                self.wallet.writeEntry('site','http://yoursite.com/xmlrpc.php')
                self.wallet.readEntry('site',server)
            self.server = str(server)
            self.password = QtCore.QString()
            self.wallet.readPassword('password',self.password)
            self.serverTxt.setText(self.server)
            self.usernameTxt.setText(self.username)
            self.passwordTxt.setText(self.password)
        else:
            self.serverTxt.setText(self.parent.Server)
            self.usernameTxt.setText(self.parent.username)
            self.passwordTxt.setText(self.parent.password)


    def save(self):
        """save details if using kwallet"""
        self.username = str(self.usernameTxt.text())
        self.password = str(self.passwordTxt.text())
        self.server = str(self.serverTxt.text())
        if self.wallet:
            self.wallet.writeEntry('username',self.username)
            self.wallet.writeEntry('site',self.server)
            self.wallet.writePassword('password',self.password)
            self.parent.reloadInfo()
        else:
            self.parent.username = self.username
            self.parent.password = self.password
            self.parent.Server = self.server
            self.parent.makeServer()
            self.parent.getCategories()

        self.hide()
        self.emit(QtCore.SIGNAL("saved()"))
