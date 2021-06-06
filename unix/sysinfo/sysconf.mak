# $Id: sysconf.mak,v 1.1 2002-09-21 13:15:54+04 dstef Exp root $

TARGET=sysconf

all: $(TARGET)

$(TARGET): $(TARGET).c
	cc -o $(TARGET) $(TARGET).c

clean:
	rm $(TARGET)