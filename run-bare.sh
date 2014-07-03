#!/bin/bash

docker run \
-v $HOME/Sites:/var/www \
-v $HOME/Sites/.coreos-databases/mysql:/var/lib/mysql \
-p 127.0.0.1:3306:3306 \
-p 127.0.0.1:80:80 \
-p 127.0.0.1:443:443 \
--name amp-dynamic \
-d \
epocsquadron/amp-dynamic
