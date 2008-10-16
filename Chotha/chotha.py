#!/usr/bin/env python
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
from mx.DateTime import now
import sys
import os
import xmlrpclib
import cPickle
from Chotha.syntax import ResourceHighlighter
from Chotha.ImageDialogUI import ImageDialogUI
from Chotha.ConfigureWinUI import ConfigureWinUI
#from OldEntryDialogUI import OldEntryDialogUI
from resource import *
import time

#Setup Ui
Ui_Lekhonee, throwaway = uic.loadUiType(os.path.join('/usr/share/chotha','ui','Lekhonee.ui'))

class LekhoneeApp(QtGui.QApplication):
        """Main application class"""
        def __init__(self,args=None):
                QtGui.QApplication.__init__(self,args)
                pixmap = QtGui.QPixmap("/usr/share/pixmaps/chothasplash.png",'png')
                self.splash = QtGui.QSplashScreen(pixmap)
                self.splash.show()
                QtCore.QTimer.singleShot(2000,self.splash,QtCore.SLOT("hide()"))
                self.mywindow = LekhoneeUI()
                self.mywindow.show()
                self.exec_()

class LekhoneeUI(Ui_Lekhonee, QtGui.QMainWindow):
        """My class"""
        def __init__(self):
                QtGui.QMainWindow.__init__(self)
                self.setupUi(self)
                #self.boldBttn.setCheckable(True)
                #self.italicBttn.setCheckable(True)
                self.stateBttn.setCheckable(True)
                self.connectslots()
                #time = str(now())
                #date = time.split(' ')[0].split('-')
                #date = QtCore.QDateTime(QtCore.QDate(int(date[0]),int(date[1]),int(date[2])))
                #time = time.split(' ')[1].split(':')
                #time = QtCore.QTime(int(time[0]),int(time[1]),int(time[2].split('.')[0]))
                #datetime = QtCore.QDateTime(date)
                #datetime.setTime(time)
                #self.timeStamp.setDateTime(datetime)
                self.filename = ''
                self.configPrefix = os.path.join(os.path.expanduser('~'), ".chotha")
                if not os.path.exists(self.configPrefix):
                        os.mkdir(self.configPrefix)
                        tempStr = 'cp /etc/chotha.data ' + self.configPrefix
                        os.popen(tempStr)
                f = file(os.path.join(self.configPrefix,'chotha.data'))
                data = cPickle.load(f)
                f.close()
                self.username = data['username']
                self.password = data['password']
                self.server = xmlrpclib.Server('http://kushaldas.in/xmlrpc.php')
                self.content = ''
                self.categoriesDict = {}
                self.getCategories()
                self.highlighter = ResourceHighlighter(self.blogTxt.document())

        def connectslots(self):
                self.connect(self.boldBttn,QtCore.SIGNAL("clicked()"),self.textBold)
                self.connect(self.italicBttn,QtCore.SIGNAL("clicked()"),self.textItalic)
                #self.connect(self.blogTxt,QtCore.SIGNAL("currentCharFormatChanged(QTextCharFormat)"),self.currentCharFormatChanged)
                self.connect(self.publishBttn,QtCore.SIGNAL("clicked()"),self.publishPost)
                self.connect(self.draftBttn,QtCore.SIGNAL("clicked()"),self.draftPost)
                self.connect(self.stateBttn,QtCore.SIGNAL("clicked()"),self.changeState)
                self.connect(self.linkBttn,QtCore.SIGNAL("clicked()"),self.insertLink)
                self.connect(self.action_Save,QtCore.SIGNAL("triggered()"),self.fileSave)
                self.connect(self.action_Open,QtCore.SIGNAL("triggered()"),self.fileOpen)
                self.connect(self.actionBold,QtCore.SIGNAL("triggered()"),self.textBold)
                self.connect(self.actionItalic,QtCore.SIGNAL("triggered()"),self.textItalic)
                self.connect(self.actionUnderline,QtCore.SIGNAL("triggered()"),self.textUnderline)
                self.connect(self.actionSuperscript,QtCore.SIGNAL("triggered()"),self.textSuperscript)
                self.connect(self.actionSubscript,QtCore.SIGNAL("triggered()"),self.textSubscript)
                self.connect(self.actionInsert_link,QtCore.SIGNAL("triggered()"),self.insertLink)
                self.connect(self.actionInsert_Image,QtCore.SIGNAL("triggered()"),self.insertImage)
                self.connect(self.actionIn_FireFox,QtCore.SIGNAL("triggered()"),self.previewFF)
                self.connect(self.actionIn_Konqueror,QtCore.SIGNAL("triggered()"),self.previewKq)
                self.connect(self.actionPreferences,QtCore.SIGNAL("triggered()"),self.configure)
 #               self.connect(self.actionPrevious_Entries,QtCore.SIGNAL("triggered()"),self.previousEntries)
                
        def textBold(self):
                """To make a text BOLD"""
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.insertText('<strong></strong>')
                else:
                        cur.insertText('<strong>%s</strong>' % (cur.selectedText()))
        
        def textItalic(self):
                """To make a text Italic"""
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.insertText('<i></i>')
                else:
                        cur.insertText('<i>%s</i>' % (cur.selectedText()))
                
        def textUnderline(self):
                """To make a text Underline"""
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.insertText('<u></u>')
                else:
                        cur.insertText('<u>%s</u>' % (cur.selectedText()))
        
        def textSuperscript(self):
                """To make a text Superscript"""
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.insertText('<sup></sup>')
                else:
                        cur.insertText('<sup>%s</sup>' % (cur.selectedText()))
         
        def textSubscript(self):
                """To make a text Subscript"""
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.insertText('<sub></sub>')
                else:
                        cur.insertText('<sub>%s</sub>' % (cur.selectedText()))
        
        def mergeFormatOnWordOrSelection(self,fmt):
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        cur.select(QtGui.QTextCursor.WordUnderCursor)
                cur.mergeCharFormat(fmt)
                self.blogTxt.mergeCurrentCharFormat(fmt)
        
        #def currentCharFormatChanged(self,fmt):
                #font = fmt.font()
                #self.boldBttn.setChecked(font.bold())
                #self.italicBttn.setChecked(font.italic())
        
        def publishPost(self):
                self.messagePost(True)
        
        def draftPost(self):
                self.messagePost(False)
                
        def changeState(self):
                if self.stateBttn.isChecked():
                        self.stateBttn.setText('VISUAL')
                        self.content = self.blogTxt.toPlainText()
                        self.blogTxt.setHtml(self.content)
                        self.disableBttns()
                else:
                        self.stateBttn.setText('code')
                        self.blogTxt.setHtml('<p></p>')
                        self.blogTxt.setPlainText(self.content)
                        self.enableBttns()
                        
        def messagePost(self,publish):
                #print str(self.timeStamp.dateTime().toString('yyyy-mm-dd hh:mm:ss'))
                clist = self.categoryList.selectedItems()
                categories = []
                for item in clist:
                        categories.append(str(item.text()))
                if self.commentCheckBox.checkState():
                        comment = 1
                else:
                        comment = 0
                #self.content = {'title':str(self.titleTxt.text()),'description':str(self.blogTxt.toHtml())[214:-14],'categories':categories,'dateCreated': str(self.timeStamp.dateTime().toString('yyyymmddThh:mm:ss')),'mt_allow_comments':comment}
                desc = str(self.blogTxt.toPlainText())
                self.content = {'title':str(self.titleTxt.text()),'description':desc,'categories':categories,'mt_allow_comments':comment}
                
                try:
                        postid = self.server.metaWeblog.newPost(1,self.username,self.password,self.content,publish)
                        qm = QtGui.QMessageBox.information(self,'Done:)','Blog updated with postid %s' % (postid))
                        self.clearAll()
                except xmlrpclib.Fault, e:
                        qm = QtGui.QErrorMessage(self)
                        qm.showMessage(e.faultString)
                
        def disableBttns(self):
                self.boldBttn.setEnabled(False)
                self.italicBttn.setEnabled(False)
                self.linkBttn.setEnabled(False)
                self.draftBttn.setEnabled(False)
                self.publishBttn.setEnabled(False)
                
        def enableBttns(self):
                self.boldBttn.setEnabled(True)
                self.italicBttn.setEnabled(True)
                self.linkBttn.setEnabled(True)
                self.draftBttn.setEnabled(True)
                self.publishBttn.setEnabled(True)
        
        def insertLink(self):
                cur = self.blogTxt.textCursor()
                if (not cur.hasSelection()):
                        qm = QtGui.QErrorMessage(self)
                        qm.showMessage('Please select some text first')
                else:
                        result = QtGui.QInputDialog.getText(self,'Insert the link','Link:',QtGui.QLineEdit.Normal,'http://')
                        if result[1]:
                                self.blogTxt.insertPlainText('<a href="%s">%s</a>' %(str(result[0]),str(cur.selectedText())))
        
        def getCategories(self):
                self.categoryList.clear()
                try:
                        categories = self.server.metaWeblog.getCategories(1,self.username,self.password)
                        i = 0
                        for cate in categories:
                                self.categoriesDict[cate['categoryName']] = i
                                i = i + 1
                                self.categoryList.addItem(cate['categoryName'])
                                if cate['categoryName'] == 'Uncategorized':
                                        self.categoryList.setCurrentRow(self.categoryList.count() - 1 )
                except:
                        self.categoryList.addItem('Uncategorized')
                        self.categoryList.setCurrentRow(self.categoryList.count() - 1 )

        def fileSaveAs(self):
                fn = QtGui.QFileDialog.getSaveFileName(self, "Save blog as...",
                                              '', "chotha files (*.chotha);;All Files (*)")
                if fn.isEmpty():
                        return False
                self.filename = str(fn)
                return self.fileSave()
                        
        def fileSave(self):
                if self.filename == '':
                        return self.fileSaveAs()
                if self.commentCheckBox.checkState():
                        comment = 1
                else:
                        comment = 0
                content = {'title':str(self.titleTxt.text()),'description':str(self.blogTxt.toPlainText())}
                f = file(self.filename,'w')
                cPickle.dump(content,f)
                f.close()
                self.blogTxt.document().setModified(False)
                return True
         
        def fileOpen(self):
                fn = QtGui.QFileDialog.getOpenFileName(self,'Open saved blog...','',"chotha files (*.chotha);;All Files (*)")
                f = file(str(fn))
                data = cPickle.load(f)
                f.close()
                if self.stateBttn.isChecked():
                        self.blogTxt.setHtml(data['description'])
                else:
                        self.blogTxt.setPlainText(data['description'])
                self.content = data['description']
                self.titleTxt.setText(data['title'])
        
        def clearAll(self):
                self.blogTxt.clear()
                self.titleTxt.clear()
                
        def insertImage(self):
                align = {'-- Not Set --': '', 'Baseline': 'baseline', 'Top': 'top', 'Middle': 'middle', 'Bottom': 'bottom', 'Text Top': 'texttop', 'Absolute Middle': 'absmiddle', 'Absolute bottom': 'abcbttom', 'Left': 'left', 'Right': 'right'}
                result = ImageDialogUI(self).getValues()
                if result[0]:
                        src = result[1][0]
                        desc = result[1][1]
                        alignment = align[result[1][2]]
                        x = result[1][3]
                        y = result[1][4]
                        if x ==0 or y == 0:
                                if alignment == '':
                                        imgString = '<img src="%s" title="%s" alt="%s" />' % (src, desc, desc)
                                else:
                                        imgString = '<img src="%s" title="%s" alt="%s" align="%s" />' % (src, desc, desc, alignment)
                        else:
                                if alignment == '':
                                        imgString = '<img src="%s" title="%s" alt="%s" height="%s" width="%s" />' % (src, desc, desc, x, y)
                                else:
                                        imgString = '<img src="%s" title="%s" alt="%s" align="%s" height="%s" width="%s" />' % (src, desc, desc, alignment, x, y)
                        self.blogTxt.insertPlainText(imgString)
                        
        def previewFF(self):
                mes = str(self.blogTxt.toPlainText())
                f = file(os.path.join('/tmp','chothatmp.html'),'w')
                f.write(mes)
                f.close()
                os.system('firefox -remote "openurl(file://%s,new-tab)"' % (os.path.join('/tmp','chothatmp.html')))
                 
        def previewKq(self):
                mes = str(self.blogTxt.toPlainText())
                f = file(os.path.join('/tmp','chothatmp.html'),'w')
                f.write(mes)
                f.close()
                os.system('konqueror file://%s' % (os.path.join('/tmp','chothatmp.html')))
                
        def configure(self):
                conf = ConfigureWinUI(self)
        #def previousEntries(self):
                #self.getCategories()
                #oldEntries = OldEntryDialogUI(self, self.server, self.username, self.password)
                
if __name__ == '__main__':
        kApp = LekhoneeApp(sys.argv)
