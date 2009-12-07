#!/usr/local/bin/macruby

# Copyright (c) 2009 Steve Ross
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

######### Overview #########
#
# MacRuby is still young -- 0.5, as of this writing -- and the
# way underlying Cocoa or native types map onto Ruby objects
# can be the source of some confusion.
#
# This example demonstrates a quick way to get an XML document,
# locate an interesting group of nodes in it, and extract the
# data from those nodes.
#
# To run it from the command line:
#
# macruby nsxmldocument_example.rb
#
# or open it in Textmate, make sure its type is Ruby and press
# Cmd+R.
#
######### Overview #########

# Drag in the linkages to Cocoa framework
framework "Cocoa"

s = '
<people>
  <person importance="high">
    <name>steve</name>
    <address>123 main</address>
  </person>
  <person importance="low">
    <name>bob</name>
    <address>345 First</address>
  </person>
</people>'

# Create a new NSXMLDocument from a string, tidying goofed up
# XML. This follows the Objective-C/Cocoa [[Class alloc] init]
# pattern. A more Rubyish way to do this is to replace alloc
# with new.
#
# Note that there are three -- count 'em, 3 -- initWithXMLString
# methods defined in Cocoa. Only one returns an NSXMLDocument
# object. That's initWithXMLString:options:error, shown below.
xmlDoc = NSXMLDocument.alloc.initWithXMLString(s, options:NSXMLDocumentTidyXML, error:nil)

# The logging statements use NSLog but could just as easily
# have used puts and Ruby string interpolation. Heck, more
# easily used Ruby string interpolation.
NSLog("Created XML Document %@", xmlDoc)
NSLog("Root element is %@", xmlDoc.rootElement)

# Perform an XPath query for all "person" nodes. This returns
# an NSArray of NSXMLElement objects. In Ruby, this is
# semantically the same as an array of objects.
nodes = xmlDoc.nodesForXPath("//person", error:nil)

# Iterate the array using incredibly cool Ruby iterators. If
# you don't believe me, try it in Objective-C.
nodes.each do |node|
  NSLog("Node is %@", node)
  
  # Note that XML allows for only one unique value to be
  # associated with a given attribute. Thus, the result is
  # a scalar NSXMLNamedNode. To extract the value, use the
  # getter, stringValue.
  importance = node.attributeForName('importance').stringValue
  
  # Now, get any child nodes for the current person node
  # that match "name". Note that the result is an NSArray
  # of NSXMLElement objects.
  name = node.nodesForXPath("./name", error:nil)
  address = node.nodesForXPath("./address", error:nil)
  
  # Remember, name and address are arrays because XML does
  # not care how many sibling nodes of the same name exist.
  # This example simply models a table, so there can only
  # be one entry for name and one for address. Assuming the
  # XML was parsed correctly, take the first element and
  # use the getter (stringValue) to display it.
  NSLog("Name: #{name.empty? ? 'n/a' : name[0].stringValue}")
  NSLog("Address: #{address.empty? ? 'n/a' : address[0].stringValue}")
  
  NSLog("Importance: #{importance}")
end
