#!/bin/bash

SECRETS_DIR=$PWD/files/secrets

cfssl gencert -ca=$SECRETS_DIR/ca.pem \
    -ca-key=$SECRETS_DIR/ca-key.pem \
    -config=$PWD/files/cfssl/ca-config.json \
    -profile=client $PWD/files/cfssl/client.json | cfssljson -bare $SECRETS_DIR/client-$1
