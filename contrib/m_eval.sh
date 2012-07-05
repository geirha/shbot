#!/usr/bin/bash
# -*- coding: utf-8 -*-
###########################################################################
#                                                                         #
#  This is a module for envbot, http://sourceforge.net/projects/envbot/   #
#                                                                         #
#  envbot - an IRC bot in bash                                            #
#  Copyright (C) 2007-2008  Arvid Norlander                               #
#  Copyright (C) 2007-2008  Vsevolod Kozlov                               #
#                                                                         #
#  This program is free software: you can redistribute it and/or modify   #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation, either version 3 of the License, or      #
#  (at your option) any later version.                                    #
#                                                                         #
#  This program is distributed in the hope that it will be useful,        #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#  GNU General Public License for more details.                           #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.  #
#                                                                         #
###########################################################################
#---------------------------------------------------------------------
## Bot's eval command.
#---------------------------------------------------------------------

module_eval_INIT() {
	modinit_API='2'
	modinit_HOOKS='on_PRIVMSG'
	commands_register "$1" 'eval' || return 1
	helpentry_module_eval_description="Provides a command to evaluate bash commands in qemu."

	helpentry_eval_eval_syntax='<command>'
	helpentry_eval_eval_description='Runs <command> in a bash shell.'
}

module_eval_UNLOAD() {
	return 0
}

module_eval_REHASH() {
	return 0
}

module_eval_handler_eval() {
		local sender="$1"
		local target=
		if [[ $2 =~ ^"# " ]]; then
			target="$2"
		else
			parse_hostmask_nick "$sender" target
		fi
		parse_hostmask_nick "$sender" sender
		local IFS=$'\n'
		for i in $(cd evalbot; ./evalcmd "$3"); do
			send_msg "$target" "$sender: $i"
		done
}

module_eval_on_PRIVMSG() {
	if [[ "$3" =~ ^(# )(.*) ]]; then
		local query="${BASH_REMATCH[2]}"
		local sender="$1"
		local target=
		if [[ $2 =~ ^# ]]; then
			target="$2"
		else
			parse_hostmask_nick "$sender" target
		fi
		parse_hostmask_nick "$sender" sender
		local IFS=$'\n'
		for i in $(cd evalbot; ./evalcmd "$query"); do
			send_msg "$target" "$sender: $i"
		done
	fi
}
