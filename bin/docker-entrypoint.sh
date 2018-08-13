#!/bin/bash

EXECUTABLE=/opt/terracoin/bin/terracoind
DIR=$HOME/.terracoincore
FILENAME=terracoin.conf
FILE=$DIR/$FILENAME

# create directory and config file if it does not exist yet
if [ ! -e "$FILE" ]; then
    mkdir -p $DIR

    echo "Creating $FILENAME"

    # Seed a random password for JSON RPC server
    cat <<EOF > $FILE
printtoconsole=${PRINTTOCONSOLE:-1}
rpcbind=127.0.0.1
rpcallowip=10.0.0.0/8
rpcallowip=172.16.0.0/12
rpcallowip=192.168.0.0/16
server=1
rpcuser=${RPCUSER:-terracoinrpc}
rpcpassword=${RPCPASSWORD:-`dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64`}
EOF

fi

cat $FILE
ls -lah $DIR/

echo "Initialization completed successfully"
MODIFIED_STARTUP=`eval echo $(echo ${EXECUTABLE} | sed -e 's/{{/${/g' -e 's/}}/}/g
echo ":/home/container$ ${MODIFIED_STARTUP}"
exec ${MODIFIED_STARTUP}
