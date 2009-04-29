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
    def __init__(self,parent, wallet):
        QtGui.QDialog.__init__(self)
        self.setupUi(self)
        self.wallet = wallet

        self.connect(self.saveBttn,QtCore.SIGNAL("clicked()"),self.save)
        self.connect(self.cancelBttn,QtCore.SIGNAL("clicked()"),self.hide)

        if not self.wallet.setFolder('lekhonee'):
            self.wallet.createFolder('lekhonee')
            self.wallet.setFolder('lekhonee')
            self.wallet.writeEntry('username','admin')
            self.wallet.writeEntry('site','http://yoursite.com/xmlrpc.php')
            self.wallet.writePassword('http://yoursite.com/xmlrpc.php','changeme')

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
        self.password = ''
        self.wallet.readPassword(self.server,self.password)
        self.serverTxt.setText(self.server)
        self.usernameTxt.setText(self.username)
        self.passwordTxt.setText(self.password)

    def save(self):
        """Don't know why this method is doing what it supposed to do"""
        self.username = str(self.usernameTxt.text())
        self.password = str(self.passwordTxt.text())
        self.server = str(self.serverTxt.text())
        self.wallet.writeEntry('username',self.username)
        self.wallet.writeEntry('site',self.server)
        self.wallet.writePassword(self.server,self.password)

        self.hide()
