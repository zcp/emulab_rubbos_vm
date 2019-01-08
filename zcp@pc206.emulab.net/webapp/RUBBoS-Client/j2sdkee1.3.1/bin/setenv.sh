#!/bin/sh

#
# Copyright 2002 Sun Microsystems, Inc. All rights reserved.
# SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
#

# Environment variables needed to run...

BINDIR=`dirname $0`
. $BINDIR/userconfig.sh

HOSTNAME=`uname -n`

if [ -n "$BINDIR" ]
then
    J2EE_HOME=`cd $BINDIR/.. > /dev/null 2>&1 && pwd`
    export J2EE_HOME
fi
if [ -z "$J2EE_HOME" ]
then
        error "Can not set environment variable J2EE_HOME"
fi

if [ -z "$JAVA_HOME" ]
then
        error "Please set JAVA_HOME to the installation directory of Java2, SDK version 1.3"
fi

if [ -z "$JMS_HOME" ]
then
    JMS_HOME=${J2EE_HOME}
fi

LIBDIR=$J2EE_HOME/lib
LOCALEDIR=$J2EE_HOME/lib/locale
CLOUDSCAPE_INSTALL=$LIBDIR/cloudscape

CLASSESDIR=$LIBDIR/classes
JMS_CLASSESDIR=$JMS_HOME/classes

JAVATOOLS=$JAVA_HOME/lib/tools.jar
J2EEJARS=$LIBDIR/j2ee.jar

JAVAHELPJARS=$LIBDIR/jhall.jar

# JMS DB PATH must end in slash to specify a directory
JMS_DB_PATH=${J2EE_HOME}/repository/${HOSTNAME}/db/

SYSTEM_LIB_DIR=${LIBDIR}/system

JMS_RI_JDBC=${SYSTEM_LIB_DIR}/cloudscape.jar:${SYSTEM_LIB_DIR}/cloudutil.jar
CLOUDJARS=$JMS_RI_JDBC:$CLOUDSCAPE_INSTALL/RmiJdbc.jar:$CLOUDSCAPE_INSTALL/cloudclient.jar

J2EETOOL_CLASSES=$LIBDIR/toolclasses
J2EETOOL_JAR=$LIBDIR/j2eetools.jar

CPATH=$CLOUDJARS:$CLASSESDIR:$JMS_CLASSESDIR:$J2EEJARS:$J2EETOOL_CLASSES:$J2EETOOL_JAR:$LOCALEDIR:$J2EE_CLASSPATH:$JAVATOOLS:$JAVAHELPJARS

export CPATH

JAAS_OPTIONS=-Djava.security.auth.policy=$J2EE_HOME/lib/security/jaas.policy
SSL_OPTIONS=-Djavax.net.ssl.trustStore=$J2EE_HOME/lib/security/cacerts.jks
LISTEN_OPTIONS=-Dcom.sun.CORBA.connection.ORBListenSocket=SSL:0,SSL_MUTUALAUTH:0,PERSISTENT_SSL:1060
JAVACMD="$JAVA_HOME/bin/java -Xmx128m $SSL_OPTIONS $JAAS_OPTIONS "
export JAVACMD
