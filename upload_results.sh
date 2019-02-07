#!/bin/bash

cd /users/zcp
sudo install gdrive /usr/local/bin/gdrive
sudo zip -r /tmp/results.zip /tmp/results
sudo gdrive upload /tmp/results.zip

