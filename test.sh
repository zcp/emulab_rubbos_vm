#!/bin/bash
sudo sed -i 's/^log4j.appender.file.File.*/log4j.appender.file.File=\/var\/log\/tomcat8\/rubbos-servlets.log/' /home/zcp/mysqld.cnf
