#!/usr/bin/env python
# *-* coding: utf-8 *-*

import irc.bot
import irc.strings
import re
import time
import sys
from subprocess import Popen, PIPE
from threading import Thread
from urllib import urlencode
from urllib2 import urlopen, URLError

import logging
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    level=logging.DEBUG)

timeout = 6
triggers = {
    u"+": u"setsid bash+ -l",
    u"1": u"setsid bash1 -login",
    u"2": u"setsid bash2 -l",
    u"3": u"setsid bash3 -l",
    u"4": u"setsid bash -l",
    u"b": u"PS1= TIMEOUT=1 exec -l bsh -i",
    u"d": u"setsid dash -l",
    u"j": u"PS1= TIMEOUT=1 exec -l jsh -i",
    u"k": u"setsid ksh -l",
    u"m": u"setsid mksh -l",
    u"mk": u"setsid mksh -l",
    u"sh": u"setsid sh -l",
}

class CommandThread(Thread):
    def __init__(self, shell, cmd):
        super(CommandThread, self).__init__()
        self.shell = shell.encode("utf-8", "replace")
        self.cmd = cmd.encode("utf-8", "replace")
        self.proc = None
        self.output = None
    
    def run(self):
        args = [ "./runqemu", self.shell, self.cmd ]
        self.proc = Popen(args, stdout=PIPE, universal_newlines=True)
        self.output = self.proc.stdout.read(10000)
        

def paste_ix(data):
    body = { "f:1" : data, }
    try:
        return unicode(urlopen("http://ix.io", urlencode(body)).read().strip())
    except URLError:
        return u"but now ix.io is sick of me"

def evalcmd(trigger, cmd):
    global triggers, timeout
    if trigger == u"":
        trigger = u"4"
    if trigger not in triggers:
        return None
    killed = False
    exit_code = -1
    thread = CommandThread(triggers[trigger], cmd)
    thread.start()

    thread.join(timeout)
    if thread.isAlive():
        thread.proc.terminate()
        exit_code = thread.proc.wait()
        killed = True
        thread.join()

    output = unicode(thread.output, "utf-8", "replace").rstrip('\n')
    del thread

    if not output:
        if killed:
            return [u"No output within the timelimit"]
        else:
            return [u"No output"]

    lines = output.split('\n')
    url = None
    if len(lines) > 3:
        url = paste_ix(output)
    result = []
    for line in lines[:3]:
        result.extend( line[i:i+100] for i in range(0, len(line), 100) )
    if url:
        if len(result) > 2:
            result[2] += u' …( '+url+u' )'
        else:
            result.append(u' …( '+url+u' )')
            
    return result[:3]

class Shbot(irc.bot.SingleServerIRCBot):
    def __init__(self, channel_list, nickname, server, port=6667, password=None):
        irc.bot.SingleServerIRCBot.__init__(self, [(server, port, password)], nickname, nickname)
        self.channel_list = channel_list

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_privmsg(self, c, e):
        if e.source.nick == c.get_nickname():
            return
        if e.arguments[0] == u"# botsnack":
            c.privmsg(e.source.nick, u"Core dumped")
            return
        elif e.arguments[0] == u"# botsmack":
            c.privmsg(e.source.nick, u"Segmentation fault")
            return
        m = re.match("^([^#]*)# (.*)", e.arguments[0])
        result = None
        if m:
            result = evalcmd(m.group(1), m.group(2))
        else:
            result = evalcmd(u"", e.arguments[0])
        if result:
            for line in result:
                c.privmsg(e.source.nick, line)

    def on_pubmsg(self, c, e):
        if e.source.nick == c.get_nickname():
            return
        if e.arguments[0] == u"# botsnack":
            c.privmsg(e.target, u"Core dumped")
            return
        elif e.arguments[0] == u"# botsmack":
            c.privmsg(e.target, u"Segmentation fault")
            return
        m = re.match("^([^#]*)# (.*)", e.arguments[0])
        result = None
        if m:
            result = evalcmd(m.group(1), m.group(2))
        if result:
            for line in result:
                c.privmsg(e.target, e.source.nick+u": "+line)

    def on_privnotice(self, c, e):
        if irc.strings.lower(e.source) == "nickserv!nickserv@services.":
            if e.arguments[0].startswith(u"You are now identified"):
                logging.info("Identified with nickserv")
                c.execute_delayed(60, self._ping_self, (c,))
                for channel in self.channel_list:
                    c.join(channel)
                    logging.info("Joining %s", channel)

    def _ping_self(self, c):
        """Send a notice to self to make sure the connection is active"""
        logging.debug("pinging self")
        try:
            c.notice(c.get_nickname(), "ping")
        except irc.client.ServerNotConnectedError, e:
            logging.error(e)
            logging.info("Reconnecting in 60 seconds")
            try:
                time.sleep(60)
                c.reconnect()
            except irc.client.ServerConnectionError, e:
                logging.error(e)
                logging.info("Giving up")
                sys.exit(2)
        c.execute_delayed(60, self._ping_self, (c,))
