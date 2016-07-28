# coding: utf-8

import SimpleHTTPServer
import SocketServer

PORT = 10000

class Handler(SimpleHTTPServer.SimpleHTTPRequestHandler, object):

    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Length', 2)
            self.end_headers()
            self.wfile.write('OK')
            return 
        return super(Handler, self).do_GET()

httpd = SocketServer.TCPServer(('0.0.0.0', PORT), Handler)

print "serve at port", PORT
httpd.serve_forever()
