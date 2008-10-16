#####################################################################
#
#       Author : Dave Fancella, Kushal Das
#       Copyright (c)  2007 Dave Fancella
#       dave@davefancella.com
#
#       Copyright: See COPYING file that comes with this distribution
#
#
#####################################################################

from PyQt4 import QtCore, QtGui
sourceState = { 'comment' : 1, 'normal' : 0, 'element' : 2, 'attribute' : 3 }

class ResourceHighlighter(QtGui.QSyntaxHighlighter):
    def CommentHighlight(self):
        theFormat = QtGui.QTextCharFormat()
        theFormat.setForeground(QtGui.QColor(100,100,100) )
        theFormat.setFontItalic(True)
        
        return theFormat
        
    def AttributeHighlight(self):
        theFormat = QtGui.QTextCharFormat()
        theFormat.setForeground(QtGui.QColor(200,0,0) )
        #theFormat.setFontItalic(True)
        
        return theFormat

    def ElementHighlight(self):
        theFormat = QtGui.QTextCharFormat()
        theFormat.setForeground(QtGui.QColor(50,50,200) )
        #theFormat.setFontItalic(True)
        
        return theFormat

    def highlightBlock(self, text):
        global sourceState
        
        currentPos = 0
        theBlock = unicode(text)
        stopTime = len(theBlock)
        
        self.setCurrentBlockState(self.previousBlockState() )
        
        while(currentPos < stopTime ):
            # First see if we're coming in from a comment and find the end of the comment
            if self.currentBlockState() == sourceState['comment']:
                endMark = theBlock.find('-->', currentPos)
                if endMark > -1:
                    self.setFormat(currentPos, endMark+3-currentPos, self.CommentHighlight() )
                    currentPos = endMark+4
                    self.setCurrentBlockState(sourceState['normal'])
                else:
                    # It's a big multi-line comment
                    self.setFormat(currentPos, stopTime-currentPos, self.CommentHighlight() )
                    currentPos = stopTime
            else:
                # Now see if we're coming in from an element and need to find attributes
                if self.currentBlockState() == sourceState['element']:
                    # Find out if the element ends on this line or not
                    endMark = theBlock.find(">", currentPos)
                    if endMark > -1:
                        # Since endMark appears, we'll go ahead and set to normal
                        self.setCurrentBlockState(sourceState['normal'])
                    else:
                        # We don't touch state because it's already set to element, but since the end mark
                        # doesn't appear, we set endMark to the end of the line to make the loop work
                        # When this while loop ends, the root while loop should end too
                        endMark = stopTime
                        self.setCurrentBlockState(sourceState['element'])
                    # We go ahead and format for this now
                    self.setFormat(currentPos+1, endMark-currentPos-1, self.ElementHighlight() )
                    while(currentPos < endMark):
                        foundAttr = False
                        matchPair = ""
                        startMark = theBlock.find("'", currentPos)
                        if startMark > -1:
                            foundAttr = True
                            matchPair = "'"
                            currentPos = startMark
                            print matchPair, " ",
                        else:
                            startMark = theBlock.find('"', currentPos)
                            if startMark > -1:
                                foundAttr = True
                                matchPair = '"'
                                currentPos = startMark
                            else:
                                # This is the case when no more attributes are in the section we're searching
                                currentPos = endMark+1
                        
                        if foundAttr:
                            # advance currentPos and search for the end mark
                            currentPos = startMark
                            endMarkAttr = theBlock.find(matchPair, currentPos+1, endMark-1)
                            if endMarkAttr > -1:
                                self.setFormat(currentPos, endMarkAttr+1-currentPos, self.AttributeHighlight() )
                                currentPos = endMarkAttr+1
                            else:
                                # This is the case when the attribute isn't cut off befre the end of the line
                                self.setFormat(currentPos, endMark-currentPos, self.AttributeHighlight() )
                                currentPos = endMark
                    self.setCurrentBlockState(sourceState['normal'])
                else:
                    # search first for comments, then elements
                    startMark = theBlock.find("<!--", currentPos)
                    if startMark > -1:
                        self.setCurrentBlockState(sourceState['comment'])
                        currentPos = startMark
                    else:
                        startMark = theBlock.find("<", currentPos )
                        if startMark > -1:
                            self.setCurrentBlockState(sourceState['element'])
                            currentPos = startMark
                        else:
                            currentPos = stopTime
                                

