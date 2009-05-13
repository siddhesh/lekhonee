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

class Wordpress(BlogServer):
    """Implementation for Wordpress server"""
    def __init__(self, server, username, password):
        BlogServer.__init__(self, server, username, password)

    def post(self, content, publish):
        """Post the content"""
        postid = self.server.metaWeblog.newPost(1, self.username, self.password, content, publish)
        res = "The blog is updated with postid " + str(postid)
        return res

    def edit(self, postid, content, publish):
        """Edit content"""
        res = self.server.metaWeblog.editPost(postid, self.username, self.password, content, publish)
        if res == True:
            return "Post updated"
        else:
            return res


    def getCategories(self):
        """return the list of categories or tags"""
        return self.server.metaWeblog.getCategories(1, self.username, self.password)

    def addPage(self, content, publish):
        """Add a new page with content"""
        self.server.wp.newPage(1, self.username, self.password, content, publish)

    def addCategory(self,category):
        """Add a new category"""
        self.server.wp.newCategory(1,self.username, self.password, category)

    def getLastPost(self):
        """Get the last post"""
        return self.server.metaWeblog.getRecentPosts(1,self.username,self.password,1)
