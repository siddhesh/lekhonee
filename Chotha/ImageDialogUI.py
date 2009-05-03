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
from ImageDialogui import Ui_imageDialog

class ImageDialogUI(QtGui.QDialog, Ui_imageDialog):
       def __init__(self,parent):
                QtGui.QDialog.__init__(self)
                self.setupUi(self)
                self.ans = False
                self.layout().setSizeConstraint(QtGui.QLayout.SetFixedSize)
                self.connect(self.cancelBttn,QtCore.SIGNAL("clicked()"),self.hide)
                self.connect(self.insertBttn,QtCore.SIGNAL("clicked()"),self.insertYes)
                self.show()
                self.exec_()
                
       def getValues(self):
                if self.ans:
                        url = unicode(self.txtURL.text())
                        desc = unicode(self.txtDesc.text())
                        alignment = str(self.comboAlignment.currentText())
                        spinX = int(self.spinX.value())
                        spinY = int(self.spinY.value())
                        self.ans = False
                        return [True, [url, desc, alignment, spinX, spinY]]
                else:
                        return [False,[]]
       
       def insertYes(self):
                self.ans = True
                self.hide()
