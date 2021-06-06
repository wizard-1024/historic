TARGET=wsping32a

all: $(TARGET).exe


$(TARGET).exe: $(TARGET).c
	cl /O2 /Fe$(TARGET).exe $(TARGET).c 

unicode:
        cl -D_UNICODE -DUNICODE /O2 /Fe$(TARGET)u.exe $(TARGET).c 

clean: 
	del $(TARGET).exe
