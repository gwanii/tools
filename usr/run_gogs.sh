#!/bin/bash
GOGS_VER=0.11.43
GOGS_DIR=/var/lib/gogs
docker pull gogs/gogs:"$GOGS_VER"
[[ ! -d $GOGS_DIR ]] && mkdir -p $GOGS_DIR
docker run --name=gogs --restart always -d -p 60022:22 -p 60080:3000 -v $GOGS_DIR:/data gogs/gogs:"$GOGS_VER"
