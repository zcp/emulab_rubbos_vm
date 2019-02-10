#!/bin/bash
httpd_ip=$1
ssh zcp@$httpd_ip "cd /tmp; ./install_httpd.sh"
