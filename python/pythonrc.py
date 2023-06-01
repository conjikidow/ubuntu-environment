import atexit
import os
import readline
import sys


# Support colored console

class TerminalColors(dict):

    def __init__(self):
        if os.environ.get('TERM') in ('xterm-color', 'xterm-256color', 'linux', 'screen', 'screen-256color', 'screen-bce'):
            self.update(dict([(k, self.__base % v) for k, v in self.__color_db]))
        else:
            self.update(dict([(k, self.__no_color) for k, v in self.__color_db]))

    __color_db = (
        ("Black", "0;30"),
        ("Red", "0;31"),
        ("Green", "0;32"),
        ("Brown", "0;33"),
        ("Blue", "0;34"),
        ("Purple", "0;35"),
        ("Cyan", "0;36"),
        ("LightGray", "0;37"),
        ("DarkGray", "1;30"),
        ("LightRed", "1;31"),
        ("LightGreen", "1;32"),
        ("Yellow", "1;33"),
        ("LightBlue", "1;34"),
        ("LightPurple", "1;35"),
        ("LightCyan", "1;36"),
        ("White", "1;37"),
        ("Normal", "0"),
    )

    __no_color = ''
    __base = '\001\033[%sm\002'


__terminal_color = TerminalColors()

sys.ps1 = f"{__terminal_color['Purple']}>>> {__terminal_color['Normal']}"
sys.ps2 = f"{__terminal_color['Brown']}... {__terminal_color['Normal']}"


# Enable tab completion

import rlcompleter
readline.parse_and_bind("tab: complete")


# Enable history

__histfile = f"{os.environ['ENVDIR']}/python/.python_history"
__histsize = 10000

if os.path.exists(__histfile):
    readline.read_history_file(__histfile)

readline.set_history_length(__histsize)

def savehist():
    readline.write_history_file(__histfile)

atexit.register(savehist)


# Enable pretty printing for stdout

from pprint import pprint

def my_displayhook(value):
    if value is not None:
        try:
            import __builtin__
            __builtin__._ = value
        except ImportError:
            __builtins__._ = value

        pprint(value, indent=1, width=90, compact=True, depth=2)

sys.displayhook = my_displayhook


# Start an external editor with \e
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/438813/

from code import InteractiveConsole
from tempfile import mkstemp

class EditableBufferInteractiveConsole(InteractiveConsole):

    def __init__(self, *args, **kwargs):
        self.last_buffer = []  # This holds the last executed statement
        InteractiveConsole.__init__(self, *args, **kwargs)

    def runsource(self, source, *args):
        self.last_buffer = [source.encode('utf-8')]
        return InteractiveConsole.runsource(self, source, *args)

    def raw_input(self, *args):
        line = InteractiveConsole.raw_input(self, *args)
        if line == self.__edit_cmd:
            fd, tmpfl = mkstemp('.py')
            os.write(fd, b'\n'.join(self.last_buffer))
            os.close(fd)
            os.system('%s %s' % (self.__editor, tmpfl))
            line = open(tmpfl).read()
            os.unlink(tmpfl)
            tmpfl = ''
            lines = line.split('\n')
            for i in range(len(lines) - 1):
                self.push(lines[i])
            line = lines[-1]
        return line

    __editor = os.environ.get('EDITOR', 'vim')
    __edit_cmd = r'\e'

__editable_console = EditableBufferInteractiveConsole(locals=locals())


__login_message = """%(Normal)sType \"\e\" to edit with Vim.\n""" % __terminal_color
__exit_message = """%(Normal)s\nExited from python.\n""" % __terminal_color
atexit.register(lambda: sys.stdout.write(__exit_message))
__editable_console.interact(banner=__login_message)
sys.exit()
