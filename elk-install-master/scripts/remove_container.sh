#!/bin/bash

want_to_clear=`docker ps -a | grep -v STATUS | grep -v Up | awk '{print $1}'`

if [ -n "$want_to_clear" ]; then
    for to_clear in $want_to_clear
    do
        printf "Clear container: "
        docker rm $to_clear
    done
else
    echo "No container to clear ."
fi
