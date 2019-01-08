#!bin/bash
export CJDBC_HOME=/usr/local/c-jdbc

cd $CJDBC_HOME/bin

echo "Waiting for mysql servers to finish start up"

echo "Starting Controller"
./controller.sh -f ../config/controller/uud-controller-distributed.xml &
