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
from Wordpress import Wordpress

def serverfactory(type, server='', username='', password=''):
    """This will return the correct server type object"""
    if type == 'wp':
        return Wordpress(server, username, password)
    else:
        return None
