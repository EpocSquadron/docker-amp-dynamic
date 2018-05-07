#!/bin/bash

docker run \
    -v $HOME/Sites:/var/www \
    -v ramp-database:/var/lib/mysql \
    -v ramp-logs:/var/log \
    -p 127.0.0.1:3306:3306 \
    -p 127.0.0.1:80:80 \
    -p 127.0.0.1:443:443 \
    --name ramp-dynamic \
    -d \
    epocsquadron/ramp-dynamic:15.10
