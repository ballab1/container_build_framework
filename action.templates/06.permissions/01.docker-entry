#!/bin/bash

if [ -f /usr/local/bin/docker-entrypoint.sh ]; then
    chmod u+rwx /usr/local/bin/docker-entrypoint.sh
    [ -h /docker-entrypoint.sh ] || ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh 
fi