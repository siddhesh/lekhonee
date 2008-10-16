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
import xmlrpclib

class BlogServer:
    """The main Server class, all other will come from it"""
    def __init__(self, server, username, password):
        self.server = xmlrpclib.Server(server)
        self.username = username
        self.password = password

    def post(self, content, publish):
        pass

    def getCategories(self):
        pass

