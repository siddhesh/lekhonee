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

#Setup dialogs
Ui_configureDialog, throwaway = uic.loadUiType(os.path.join('/usr/share/chotha','ui','ConfigureWin.ui'))


class ConfigureWinUI(QtGui.QDialog, Ui_configureDialog):
    def __init__(self,parent):
        QtGui.QDialog.__init__(self)
        self.setupUi(self)
        self.configPrefix = os.path.join(os.path.expanduser('~'), ".chotha")
        f = file(os.path.join(self.configPrefix,'chotha.data'))
        data = cPickle.load(f)
        f.close()
        self.connect(self.saveBttn,QtCore.SIGNAL("clicked()"),self.save)
        self.connect(self.cancelBttn,QtCore.SIGNAL("clicked()"),self.hide)
        self.connect(self.typeBox,QtCore.SIGNAL("currentIndexChanged(QString)"),self.changeView)
        self.username = data['username']
        self.password = data['password']
        self.server = data['server']
        self.serverType = data['serverType']
        if self.serverType == 'Wordpress':
            self.typeBox.setCurrentIndex(0)
        elif self.serverType == 'Livejournal':
            self.typeBox.setCurrentIndex(1)
        self.serverTxt.setText(self.server)
        self.usernameTxt.setText(self.username)
        self.passwordTxt.setText(self.password)
        self.show()
        self.exec_()
    
    def save(self):
        """Don't know why this method is doing what it supposed to do"""
        self.username = str(self.usernameTxt.text())
        self.password = str(self.passwordTxt.text())
        self.server = str(self.serverTxt.text())
        self.serverType = str(self.typeBox.currentText())
        data = {'username': self.username, 'password': self.password, 'serverType': self.serverType, 'server': self.server}
        f = file(os.path.join(self.configPrefix,'chotha.data'),'w')
        cPickle.dump(data, f)
        """Hide hide hide.... he is not hiding"""
        self.hide
        
    def changeView(self, text):
        """Just change the Server text field according to the server type selected"""
        if text == "Wordpress":
            self.serverTxt.setEnabled(True)
        elif text == 'Livejournal':
            self.serverTxt.setEnabled(False)
            self.serverTxt.setText('http://livejournal.com')
