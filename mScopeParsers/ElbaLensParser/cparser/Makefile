# makefile for compiling the parsers

JAVAC = $(JAVA_HOME)/bin/javac
JFLAGS = -g
CC = g++
CFLAGS = -Wall -g -mcmodel=medium
RM = rm

default: TomcatParser.class Clientparser Apacheparser CJDBCparser

#default: Tomcatparser Clientparser Apacheparser CJDBCparser

TomcatParser.class: TomcatParser.java
	$(JAVAC) $(JFLAGS) TomcatParser.java

#Tomcatparser: Tomcatparser.cpp
#	$(CC) $(CFLAGS) -o Tomcatparser Tomcatparser.cpp

Clientparser: Clientparser.cpp
	$(CC) $(CFLAGS) -o Clientparser Clientparser.cpp

Apacheparser: Apacheparser.cpp
	$(CC) $(CFLAGS) -o Apacheparser Apacheparser.cpp

CJDBCparser: CJDBCparser.cpp
	$(CC) $(CFLAGS) -o CJDBCparser CJDBCparser.cpp

clean:
	$(RM) *.class
	$(RM) Clientparser
	$(RM) Apacheparser
	#$(RM) Tomcatparser
	$(RM) CJDBCparser

