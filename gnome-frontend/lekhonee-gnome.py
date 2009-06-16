#####################################################################
#
#       Author : Kushal Das
#       Copyright (c)  2009 Kushal Das
#       kushal@fedoraproject.org
#
#####################################################################


import sys
import os
import codecs
try:
    import pygtk
    pygtk.require("2.0")
except:
    pass
import gtk
import gtk.glade
import gtkhtml2
import gobject
import gtksourceview2
import webkit
import cPickle
import xmlrpclib
import gtkspell
from Chotha.Wordpress import Wordpress



class LekhoneeGTK:
    """GUI for gnome"""

    def __init__(self):
        gobject.threads_init()
        #Set the Glade file
        self.gladefile = "lekhonee-gnome.glade"
        self.wTree = gtk.glade.XML(self.gladefile)
        #Get the Main Window, and connect the "destroy" event
        self.window = self.wTree.get_widget("MainWindow")
        self.categoryList = self.wTree.get_widget("categoryList")
        self.titleTxt = self.wTree.get_widget("titleTxt")
        self.scw = self.wTree.get_widget("scw")
        self.scw2 = self.wTree.get_widget("scw2")


        dic = {'on_MainWindow_destroy': gtk.main_quit,
               'on_boldBttn_clicked':self.boldBttn_cb,
               'on_linkBttn_clicked':self.linkBttn_cb,
               'on_imageBttn_clicked':self.imageBttn_cb,
               'on_publishBttn_clicked':self.publishBttn_cb,
               'on_bold_activate':self.boldBttn_cb,
               'on_underline_activate':self.underlineBttn_cb,
               'on_italic_activate':self.italicBttn_cb,
               'on_save_activate':self.save_cb,
               'on_new_activate':self.new_cb,
               'on_open_activate':self.open_cb,
               'on_last_entry_activate':self.lastEntry_cb,
               'on_lekhonee_msg_activate': self.advertise_cb,
               'on_quit_activate':gtk.main_quit,
               'on_about_activate':self.show_about,
               'on_preference_activate':self.preference_cb,
               'on_previewBttn_toggled': self.previewBttn_cb,
               'on_spellCheckBox_toggled': self.spellCheck_cb,
               'on_italicBttn_clicked':self.italicBttn_cb}

        self.wTree.signal_autoconnect(dic)
        self.column = gtk.TreeViewColumn("Categories", gtk.CellRendererText(), text=0)
        self.categoryList.append_column(self.column)
        self.liststore = gtk.ListStore(gobject.TYPE_STRING)
        self.categoryList.set_model(self.liststore)
        treeselection = self.categoryList.get_selection()
        treeselection.set_mode(gtk.SELECTION_MULTIPLE)

        #Add the gtksourceview2 for editing
        self.blogTxt =  gtksourceview2.Buffer()
        lm = gtksourceview2.LanguageManager()
        lang = lm.get_language('html')
        self.blogTxt.set_language(lang)
        self.sourceview = gtksourceview2.View(self.blogTxt)
        self.scw.add(self.sourceview)
        self.sourceview.set_wrap_mode(gtk.WRAP_WORD)

        #Add webkit for preview
        self.web = webkit.WebView()
        self.scw2.add(self.web)


        self.filename = ''
        self.server = None
        self.editFlag = False
        self.entry = None
        self.advertisement = True

        self.window.show_all()

        self.scw2.hide_all()
        self.configureDialog = self.wTree.get_widget('configureDialog')
        self.configureDialog.connect('response',self.configure_cb)
        self.linkDialog = self.wTree.get_widget('getlinksDialog')
        self.linkDialog.connect('response',self.link_dialog_cb)
        self.linkTxt = self.wTree.get_widget('linkTxt')
        self.imageDialog = self.wTree.get_widget('imageDialog')
        self.imageDialog.connect('response',self.image_dialog_cb)

        #for spell checking
        self.spell = None

        self.configurepath = os.path.join(os.path.expanduser("~"),'.lekhonee')
        if os.path.exists(self.configurepath):
            f = file(self.configurepath)
            data = cPickle.load(f)
            f.close()
            self.wTree.get_widget('serverTxt').set_text(data['server'])
            self.wTree.get_widget('usernameTxt').set_text(data['username'])
            try:
                if data['advertisement']:
                    print "There"
                else:
                    print "Not there"
                    widget = self.wTree.get_widget('lekhonee_msg')
                    widget.set_active(False)
            except:
                pass

    def show_about(self, widget):
        """
        Show the about dialog
        """
        dialog = gtk.AboutDialog()
        dialog.set_name('lekhonee')
        dialog.set_copyright('(c) 2009 Kushal Das')
        dialog.set_website('http://fedorahosted.org/lekhonee')
        dialog.set_authors(['Kushal Das kushal@fedoraproject.org',])
        dialog.set_program_name('lekhonee')
        dialog.run()
        dialog.destroy()

    def advertise_cb(self, widget):
        if widget.get_active():
            self.advertisement = True
        else:
            self.advertisement = False
        f = file(self.configurepath)
        data = cPickle.load(f)
        f.close()
        data['advertisement'] = self.advertisement
        f = file(self.configurepath,'w')
        cPickle.dump(data,f)
        f.close()


    def save_cb(self, widget):
        """
        Save the current blog entry to disk
        """
        if self.filename != '':
            self.save()
            return True

        chooser = gtk.FileChooserDialog(title='Save Blog',action=gtk.FILE_CHOOSER_ACTION_SAVE,
            buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
        filter = gtk.FileFilter()
        filter.set_name("Lekhonee files")
        filter.add_pattern("*.chotha")
        chooser.add_filter(filter)
        response = chooser.run()

        if  response == gtk.RESPONSE_OK:
            self.filename = chooser.get_filename()
            self.save()
        chooser.destroy()

    def save(self):
        start, end = self.blogTxt.get_bounds()
        text = unicode(self.blogTxt.get_text(start, end))
        title = unicode(self.titleTxt.get_text())
        content = {'title':title,'description':text, 'advertisement':self.advertisement}
        f = file(self.filename,'w')
        cPickle.dump(content,f)
        f.close()



    def open_cb(self, widget):
        """
        Open an old blog entry from disk
        """
        chooser = gtk.FileChooserDialog(title='Open Blog',action=gtk.FILE_CHOOSER_ACTION_OPEN,
            buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_OPEN,gtk.RESPONSE_OK))
        filter = gtk.FileFilter()
        filter.set_name("Lekhonee files")
        filter.add_pattern("*.chotha")
        chooser.add_filter(filter)
        response = chooser.run()

        if  response == gtk.RESPONSE_OK:
            self.filename = chooser.get_filename()
            f = file(unicode(self.filename))
            content = cPickle.load(f)
            f.close()
            self.blogTxt.set_text(content['description'])
            self.titleTxt.set_text(content['title'])

        chooser.destroy()


    def lastEntry_cb(self, widget):
        """
        show the last entry
        """
        try:
            self.entry = self.server.getLastPost()[0]
        except Exception, e:
            dm = gtk.MessageDialog(self.window, gtk.DIALOG_MODAL, gtk.MESSAGE_ERROR, gtk.BUTTONS_OK, e.faultString)
            dm.run()
            dm.destroy()
            return

        self.blogTxt.set_text(self.entry['description'])
        self.titleTxt.set_text(self.entry['title'])
        categories = self.entry['categories']
        self.getCategories()

        ts = self.categoryList.get_selection()
        for category in categories:
            for x in range(0,len(self.liststore)):
                iter = self.liststore.get_iter(str(x))
                if category == self.liststore.get_value(iter,0):
                    ts.select_iter(iter)
                    print category
        self.editFlag = True



    def new_cb(self, widget):
        """
        clear
        """
        self.blogTxt.set_text('')
        self.titleTxt.set_text('')
        self.filename = ''
        self.editFlag = False
        self.getCategories()


    def configure_cb(self, widget, response_id):
        """
        To callback to handle server details
        """
        self.configureDialog.hide()
        if response_id == gtk.RESPONSE_OK:
            data = {'server':self.wTree.get_widget('serverTxt').get_text(),
                    'username':self.wTree.get_widget('usernameTxt').get_text()}
            f = file(self.configurepath, 'w')
            cPickle.dump(data, f)
            f.close()
            password = self.wTree.get_widget('passwordTxt').get_text()
            self.server = Wordpress(data['server'], data['username'], password)
            self.getCategories()

    def getCategories(self):
        """
        Get categories from wordpress
        """
        self.liststore.clear()
        try:
            categories = self.server.getCategories()
            for cate in categories:
                self.liststore.append((cate['categoryName'],))
        except:
            self.liststore.append(('Uncategorized',))

    def preference_cb(self, widget):
        """
        get the configuration file if available
        """

        if os.path.exists(self.configurepath):
            f = file(self.configurepath)
            data = cPickle.load(f)
            f.close()
            self.wTree.get_widget('serverTxt').set_text(data['server'])
            self.wTree.get_widget('usernameTxt').set_text(data['username'])
        self.configureDialog.show()

    def link_dialog_cb(self, widget, response_id):
        """
        Get the link
        """
        self.linkDialog.hide()
        if response_id == gtk.RESPONSE_OK:
            link = self.linkTxt.get_text()
            if link:
                iter = self.blogTxt.get_selection_bounds()
                if iter:
                    text =  self.blogTxt.get_text(iter[0],iter[1])
                    self.blogTxt.delete(iter[0],iter[1])
                else:
                    text = ''
                self.blogTxt.insert_at_cursor('<a href="'+link+'">'+text+'</a>')

    def image_dialog_cb(self, widget, response_id):
        """
        Get the imade details
        """
        align = {None: '','-- Not Set --': '', 'Baseline': 'baseline', 'Top': 'top', 'Middle': 'middle', 'Bottom': 'bottom', 'Text Top': 'texttop', 'Absolute Middle': 'absmiddle', 'Absolute bottom': 'abcbttom', 'Left': 'left', 'Right': 'right'}
        self.imageDialog.hide()
        if response_id == gtk.RESPONSE_OK:
            src = self.wTree.get_widget('imageurlTxt').get_text()
            desc = self.wTree.get_widget('imagedescriptionTxt').get_text()
            alignment = align[self.wTree.get_widget('imagealignmentBox').get_active_text()]
            x = self.wTree.get_widget('xspin').get_value()
            y = self.wTree.get_widget('yspin').get_value()
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
            self.blogTxt.insert_at_cursor(imgString)




    def imageBttn_cb(self, widget):
        """
        Insert Image dialog
        """
        self.imageDialog.show()

    def linkBttn_cb(self, widget):
        """
        Insert Link dialog
        """
        self.linkDialog.show()

    def italicBttn_cb(self, widget):
        iter = self.blogTxt.get_selection_bounds()
        if iter:
            text =  self.blogTxt.get_text(iter[0],iter[1])
            self.blogTxt.delete(iter[0],iter[1])
        else:
            text = ''
        text = '<i>%s</i>' % text
        self.blogTxt.insert_at_cursor(text)

    def underlineBttn_cb(self, widget):
        iter = self.blogTxt.get_selection_bounds()
        if iter:
            text =  self.blogTxt.get_text(iter[0],iter[1])
            self.blogTxt.delete(iter[0],iter[1])
        else:
            text = ''
        text = '<u>%s</u>' % text
        self.blogTxt.insert_at_cursor(text)



    def boldBttn_cb(self, widget):
        iter = self.blogTxt.get_selection_bounds()
        if iter:
            text =  self.blogTxt.get_text(iter[0],iter[1])
            self.blogTxt.delete(iter[0],iter[1])
        else:
            text = ''
        text = '<strong>%s</strong>' % text
        self.blogTxt.insert_at_cursor(text)

    def previewBttn_cb(self, widget):
        """
        Show or hide preview button accordingly
        """
        text = """<html><head><title>%s</title></head><body>%s</body></html>"""
        if widget.get_active():
            self.scw.hide_all()
            start, end = self.blogTxt.get_bounds()
            text = text % (self.titleTxt.get_text(), self.blogTxt.get_text(start, end))
            text = text.replace('\n','<br>')
            self.web.load_string(text,'text/html','utf-8','preview')
            self.scw2.show_all()
        else:
            self.scw2.hide_all()
            self.scw.show_all()

    def spellCheck_cb(self, widget):
        """
        Enable/Disable the spellchecking
        """
        if widget.get_active():
            self.spell = gtkspell.Spell(self.sourceview)
            self.spell.recheck_all()
        else:
            self.spell.detach()

    def publishBttn_cb(self, widget):
        self.messagePost(True)


    def draftBttn_cb(self, widget):
        self.messagePost(False)


    def messagePost(self, publish):
        """
        Post the message to the server
        """
        selection = self.categoryList.get_selection()
        model, selected = selection.get_selected_rows()
        categories = [model[sec][0] for sec in selected]
        if self.wTree.get_widget("commentCheckBox").get_active():
            comment = 1
        else:
            comment = 0
        start, end = self.blogTxt.get_bounds()
        desc = unicode(self.blogTxt.get_text(start, end))
        title = unicode(self.titleTxt.get_text())
        if self.advertisement:
            mes = 'The post is bought to you by <a href="http://fedorahosted.org/lekhonee">lekhonee</a>'
            if desc.find(mes) != -1:
                desc += '\n\n' + mes
        content = {'title':unicode(self.titleTxt.get_text()),'description':desc, 'categories':categories, 'mt_allow_comments':comment}
        try:
            if not self.editFlag:
                mes = self.server.post(content, publish)
            else:
                mes = self.server.edit(self.entry['postid'], content, publish)
            self.editFlag = False
            self.clearAll()
            dm = gtk.MessageDialog(self.window, gtk.DIALOG_MODAL, gtk.MESSAGE_INFO, gtk.BUTTONS_OK, mes)
        except Exception, e:
            dm = gtk.MessageDialog(self.window, gtk.DIALOG_MODAL, gtk.MESSAGE_ERROR, gtk.BUTTONS_OK, e.faultString)
        dm.run()
        dm.destroy()

    def clearAll(self):
        self.new_cb(True)

    def dirBttn_cb(self,widget):
        """
        Open a dir chooser and get the directory name
        """
        self.chooser = gtk.FileChooserDialog(title='Select Folder',action=gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER,
            buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_OPEN,gtk.RESPONSE_OK))
        response = self.chooser.run()
        if  response == gtk.RESPONSE_OK:
            self.path = self.chooser.get_filename()

        self.chooser.destroy()

    def selectBttn_cb(self, widget):
        """
        To handle selectBttn callback
        """
        dialog = gtk.FileChooserDialog("Open..",None,
                gtk.FILE_CHOOSER_ACTION_OPEN,
                buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_OPEN,gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)

        filter = gtk.FileFilter()
        filter.set_name("Po files")
        filter.add_pattern("*.po")
        dialog.add_filter(filter)

        response = dialog.run()
        if response == gtk.RESPONSE_OK:
            filename = dialog.get_filename()
            self.filepath.set_text(filename)
        dialog.destroy()


    def addBttn_cb(self, widget):
        """
        To handle addBttn callback
        """
        path = self.filepath.get_text()
        path = path.strip()
        if path:
            self.liststore.append((path,))
            self.filepath.set_text('')
            self.pofilesave()
            self.dirBttn.set_sensitive(False)


    def removeBttn_cb(self, widget):
        """
        To handle removeBttn callback
        """
        x, y = self.listbox.get_selection().get_selected()
        if y:
            self.liststore.remove(y)
            self.pofilesave()
            if len(self.liststore) == 0:
                self.dirBttn.set_sensitive(True)




if __name__=='__main__':
    tfg = LekhoneeGTK()
    gtk.main()
