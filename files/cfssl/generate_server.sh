#!/bin/bash

SECRETS_DIR=$PWD/files/secrets

template=$(cat $PWD/files/cfssl/server.json | sed "s/\${SERVERNAME}/$1/g")

echo $template | cfssl gencert -ca=$SECRETS_DIR/ca.pem \
    -ca-key=$SECRETS_DIR/ca-key.pem \
    -config=$PWD/files/cfssl/ca-config.json \
    -profile=server \
    -hostname="$2" - | cfssljson -bare $SECRETS_DIR/$1
