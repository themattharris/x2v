#!/usr/bin/env python
# Quick and dirty server script for 4XSLT
#
# Copyright 2007 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

import socket
import sys
import os

from Ft.Xml.Xslt import Processor
from Ft.Xml import InputSource
from Ft.Lib.Uri import OsPathToUri

class FourXsltTransformationServer:

    def __init__(self, quiet):
        self.xslt_processor = Processor.Processor()
        self.xslt_params = {}
        self.quiet = quiet

    def run(self, ip, port):
        self.say("Starting server at %s:%d" % (ip, port))
        
        c = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        c.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        c.bind((IP, PORT))
        c.listen(1)
    
        serve = True
        while serve:
            self.say("Waiting for connections")
            
            csock, caddr = c.accept() 
            
            self.say("Accepted a connection")
            
            cfile = csock.makefile('rw', 0)
            
            serve = self.handle_client(cfile)
            
            cfile.close() 
            csock.close()

    def handle_client(self, cfile):
        response = ''
        while True:
            try:
                line = cfile.readline().strip()
            except:
                return True
            
            if line == '':
                continue
            
            #self.say('Recived "%s" from client' % (line) )
            
            response = self.handle_request(line)
            
            if response == 'CLOSE':
                return True
            if response == 'QUIT':
                return False
            
            try:
                cfile.write(response + "\n\0\0\0\0")
            except:
                return True
        
        return

    def handle_request(self, req):
        # Request looks like this:
        #   <COMMAND> <space> <ARGUMENTS>
        # 

        if req.upper() == 'CLOSE' or req.upper() == 'QUIT':
            self.say(req.upper())
            return req.upper()
        
        pos = req.find(' ')
        if pos == -1:
            return 'ERROR malformed request'
        
        cmd = req[:pos].upper()
        arg = req[pos+1:]
        
        if cmd == 'LOAD_XSLT':
            # LOAD_XSLT filename
            self.say("Loading XSLT file '%s'" % (arg))
            try:
                self.load_xslt(arg)
            except Exception, e:
                print "Exception: ", e
            return 'OK'
        
        elif cmd == 'SET_PARAM':
            # SET_PARAM name=value
            
            pos = arg.find('=')
            if pos == -1:
                return 'ERROR malformed request'
            name  = arg[:pos]
            value = arg[pos+1:]
            
            self.say("Setting param '%s' to '%s'" %(name,value))
            self.xslt_params[name] = value
            
            return 'OK'
        
        elif cmd == 'TRANSFORM':
            # TRANSFORM filename
            self.say("Transforming '%s'\n" %(arg))
            try:
                result = self.transform(arg)
            except Exception, e:
                return "ERROR " + e

            return "OK " + result
        
        else:
            return 'ERROR unknown command'
        
        return

    def say(self, msg):
        if not self.quiet:
            print msg

    def load_xslt(self, xslt_filename):
        # reset processor
        self.xslt_processor.reset()
        
        # load xslt
        xslt_uri = OsPathToUri(xslt_filename)
        xslt_src = InputSource.DefaultFactory.fromUri(xslt_uri)
        self.xslt_processor.appendStylesheet(xslt_src)
        
        # reset params
        self.xslt_params.clear() 

    def transform(self, input_filename):
        # load input
        input_uri = OsPathToUri(input_filename)
        input_src = InputSource.DefaultFactory.fromUri(input_uri)
        
        # transform
        result = self.xslt_processor.run(
                    input_src, topLevelParams=self.xslt_params)
        return result

    # end of FourXsltTransformationServer


def daemonize():
    # Adapted from: 
    # http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66012

    try: 
        pid = os.fork() 
        if pid > 0:
            # exit first parent
            sys.exit(0) 
    except OSError, e: 
        print >>sys.stderr, "fork #1 failed: %d (%s)" % (e.errno, e.strerror) 
        sys.exit(1)

    # decouple from parent environment
    os.chdir("/") 
    os.setsid() 
    os.umask(0) 

    # do second fork
    try: 
        pid = os.fork() 
        if pid > 0:
            sys.exit(0) 
    except OSError, e: 
        print >>sys.stderr, "fork #2 failed: %d (%s)" % (e.errno, e.strerror) 
        sys.exit(1) 


if __name__ == '__main__':
    IP      = '127.0.0.1'
    PORT    = 40800

    if len(sys.argv) > 1 and sys.argv[1] == '--daemonize':
        daemonize()
        obj = FourXsltTransformationServer(quiet = True)
        obj.run(IP, PORT)
    else:
        obj = FourXsltTransformationServer(quiet = False)
        obj.run(IP, PORT)
