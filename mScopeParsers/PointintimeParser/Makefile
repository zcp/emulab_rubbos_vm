# makefile for compiling the pointintime parsers

JAVAC = $(JAVA_HOME)/bin/javac
JFLAGS = -g
CC = g++
CFLAGS = -Wall -g
RM = rm

default: PointInTimeParser.class

PointInTimeParser.class: PointInTimeParser.java
	$(JAVAC) $(JFLAGS) PointInTimeParser.java

clean:
	$(RM) *.class

