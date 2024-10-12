#!/bin/env bash

# Builds and watches files, loads dev environment from WSL

# Requirements:
#   1. (in WSL) Install tmux, npm, npm browser-sync, npm nodemon,
#   2. (Windows) Install firefox and ensure it is in your Windows PATH
#                - you may need to add its path to your WSL shell profile
#   3. Start a tmux session in your project root.
#   4. Run this script from your project root directory

SYNCEXT="html"    # browser-sync will watches changes with this extension
WATCHEXT="adoc"   # nodemon will run the BUILDCMD when these files change
BUILDCMD="make"   # the command that runs when WATCHEXT files change
BROWSER="firefox.exe"

tmux new-window -d -n dev "browser-sync start --server --files \"*.${SYNCEXT}\" --no-open && killall node"
tmux split-window -t :dev "nodemon -L -e ${WATCHEXT} -x \"${BUILDCMD} && browser-sync reload\""
exec "${BROWSER}" localhost:3000 # then access your e.g.: localhost:3000/build/index.html
