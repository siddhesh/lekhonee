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

from BlogServer import BlogServer
from lj import *

class Livejournal(BlogServer):
    """Implementation for Livejornal server"""
    def __init__(self, server, username, password):
        BlogServer.__init__(self, server, username, password)
        self.LJ = LJServer('Chotha; kushaldas@gmail.com', 'Qt-chotha/0.2')
        try:
            login = self.LJ.login(username, password)
        except:
            print "Wrong password"

    def post(self, content, publish):
        """Post the content"""
        self.LJ.postevent(content['description'], content['title'], props = content['props'])
        return "Journal posted"
    
    def getCategories(self):
        """NO categories"""
        return ['Sorry, but no categories', ]

