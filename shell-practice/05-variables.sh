#!/bin/bash

echo "all args are passed to the script: $@"
echo "Number of variables are passed to the script: $#"
echo "script name: $0"
echo "present directory: $PWD"
echo "Who is running: $USER"
echo "home directory of current user: $HOME"
echo "PID of the script: $$"
echo "PID of recently executed background process: $!"
echo "all args passed to the script: $*"
echo "exit status of previous command: $?"