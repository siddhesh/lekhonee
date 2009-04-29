# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file '../ui/ConfigureWin.ui'
#
# Created: Wed Apr 29 00:39:14 2009
#      by: PyQt4 UI code generator 4.4.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_ConfigureWin(object):
    def setupUi(self, ConfigureWin):
        ConfigureWin.setObjectName("ConfigureWin")
        ConfigureWin.setWindowModality(QtCore.Qt.ApplicationModal)
        ConfigureWin.resize(443, 153)
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap(":/pixmaps/lekhonee.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        ConfigureWin.setWindowIcon(icon)
        self.verticalLayout = QtGui.QVBoxLayout(ConfigureWin)
        self.verticalLayout.setObjectName("verticalLayout")
        self.hboxlayout = QtGui.QHBoxLayout()
        self.hboxlayout.setObjectName("hboxlayout")
        self.vboxlayout = QtGui.QVBoxLayout()
        self.vboxlayout.setObjectName("vboxlayout")
        self.label = QtGui.QLabel(ConfigureWin)
        self.label.setObjectName("label")
        self.vboxlayout.addWidget(self.label)
        self.label_2 = QtGui.QLabel(ConfigureWin)
        self.label_2.setObjectName("label_2")
        self.vboxlayout.addWidget(self.label_2)
        self.label_3 = QtGui.QLabel(ConfigureWin)
        self.label_3.setObjectName("label_3")
        self.vboxlayout.addWidget(self.label_3)
        self.hboxlayout.addLayout(self.vboxlayout)
        self.vboxlayout1 = QtGui.QVBoxLayout()
        self.vboxlayout1.setObjectName("vboxlayout1")
        self.serverTxt = QtGui.QLineEdit(ConfigureWin)
        self.serverTxt.setObjectName("serverTxt")
        self.vboxlayout1.addWidget(self.serverTxt)
        self.usernameTxt = QtGui.QLineEdit(ConfigureWin)
        self.usernameTxt.setObjectName("usernameTxt")
        self.vboxlayout1.addWidget(self.usernameTxt)
        self.passwordTxt = QtGui.QLineEdit(ConfigureWin)
        self.passwordTxt.setEchoMode(QtGui.QLineEdit.Password)
        self.passwordTxt.setObjectName("passwordTxt")
        self.vboxlayout1.addWidget(self.passwordTxt)
        self.hboxlayout.addLayout(self.vboxlayout1)
        self.verticalLayout.addLayout(self.hboxlayout)
        self.hboxlayout1 = QtGui.QHBoxLayout()
        self.hboxlayout1.setObjectName("hboxlayout1")
        self.saveBttn = QtGui.QPushButton(ConfigureWin)
        icon1 = QtGui.QIcon()
        icon1.addPixmap(QtGui.QPixmap(":/icons/document-save.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.saveBttn.setIcon(icon1)
        self.saveBttn.setObjectName("saveBttn")
        self.hboxlayout1.addWidget(self.saveBttn)
        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.hboxlayout1.addItem(spacerItem)
        self.cancelBttn = QtGui.QPushButton(ConfigureWin)
        icon2 = QtGui.QIcon()
        icon2.addPixmap(QtGui.QPixmap(":/icons/dialog-cancel.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.cancelBttn.setIcon(icon2)
        self.cancelBttn.setObjectName("cancelBttn")
        self.hboxlayout1.addWidget(self.cancelBttn)
        self.verticalLayout.addLayout(self.hboxlayout1)

        self.retranslateUi(ConfigureWin)
        QtCore.QMetaObject.connectSlotsByName(ConfigureWin)

    def retranslateUi(self, ConfigureWin):
        ConfigureWin.setWindowTitle(QtGui.QApplication.translate("ConfigureWin", "Configure Lekhonee", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("ConfigureWin", "Server", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("ConfigureWin", "Username", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setText(QtGui.QApplication.translate("ConfigureWin", "Password", None, QtGui.QApplication.UnicodeUTF8))
        self.saveBttn.setText(QtGui.QApplication.translate("ConfigureWin", "Save", None, QtGui.QApplication.UnicodeUTF8))
        self.cancelBttn.setText(QtGui.QApplication.translate("ConfigureWin", "Cancel", None, QtGui.QApplication.UnicodeUTF8))

import resource_rc
