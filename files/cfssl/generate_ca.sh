#!/bin/bash

SECRETS_DIR=$PWD/files/secrets

cfssl gencert -initca $PWD/files/cfssl/ca-csr.json | cfssljson -bare $SECRETS_DIR/ca -
