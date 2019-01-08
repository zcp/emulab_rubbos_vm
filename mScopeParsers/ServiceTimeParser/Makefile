# makefile for compiling the downstream service time parser

CC = g++
CFLAGS = -Wall -g
RM = rm

default: WaitTime


WaitTime: WaitTime.cpp
	$(CC) $(CFLAGS) -o WaitTime WaitTime.cpp

clean:
	#$(RM) *.class
	$(RM) WaitTime

