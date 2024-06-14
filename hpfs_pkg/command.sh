#!/bin/bash

# Execute the command
nohup ./hpfs-srvr -v=1 -logtostderr -port "$1" -server_id "$2" >/dev/null 2>&1 &

