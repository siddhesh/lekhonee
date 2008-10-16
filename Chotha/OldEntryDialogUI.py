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
import xmlrpclib

#Setup dialogs
Ui_oldEntryDialog, throwaway = uic.loadUiType(os.path.join('ui','OldEntryDialog.ui'))

class OldEntryDialogUI(QtGui.QDialog, Ui_oldEntryDialog):
       def __init__(self,parent, server, username, password):
                QtGui.QDialog.__init__(self)
                self.setupUi(self)
                self.server = server
                self.username = username
                self.password = password
                self.layout().setSizeConstraint(QtGui.QLayout.SetFixedSize)
                self.show()
                self.getOldEntries()
                self.exec_()
                
       def getOldEntries(self):
                oldposts = self.server.metaWeblog.getRecentPosts(1, self.username, self.password, 5)
                for post in oldposts:
                        print post 