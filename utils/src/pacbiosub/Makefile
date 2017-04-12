#
#	 Makefile
#
CC=g++
SOURCES= pacbiosub.cpp

INCLUDES = 
LIBS =  

CFLAGS= -c  $(INCLUDES) 
COMPILE = $(CC)  -std=c++11 $(CFLAGS)  

OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=$(SOURCES:.cpp=)

all: cleanall iprint $(SOURCES) $(EXECUTABLE) clean oprint
#all: clean

iprint:
	@echo '+++ compiling all ... '
oprint:
	@echo 'Done '

# compile source	
$(EXECUTABLE): $(OBJECTS) 
	$(CC) -std=c++11 $(OBJECTS) -lz -o $@


# create *.o
.cpp.o:
	$(COMPILE) $< -o $@

cleanall:
	@echo -n '+++ Cleaning all object files ... '
	@rm -f $(EXECUTABLE) $(OBJECTS)
	@echo 'Done.'
clean:
	@rm -f $(OBJECTS)


