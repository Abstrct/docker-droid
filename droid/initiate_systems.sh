#!/usr/bin/env bash

wget https://static.coindroids.com/defcoin-bootstrap.dat.tgz 
tar -zxf defcoin-bootstrap.dat.tgz
mv bootstrap.dat /src/droid/client/data/bootstrap.dat
chown droid /src/droid/client/data/bootstrap.dat
rm -rf defcoin-bootstrap.dat.tgz

su droid -c '/src/droid/client/bin/defcoind -conf=/src/droid/client/data/defcoin.conf'
echo 'Defcoin Node initiating'


echo 'Monitoring Log' > /src/droid/logs.txt

/bin/bash /src/droid/droid.sh &

tail -f /src/droid/logs.txt


