OS   =  $(shell uname)

ifeq (Darwin, $(findstring Darwin, ${OS}))
 LDFLAGS =
 CFLAGS = -Wall 
else
 LDFLAGS =  -lm -pthread 
 CFLAGS = -Wall -pthread 
endif

wrap: wrap.c
	${CC} ${CFLAGS} wrap.c -o wrap ${LDFLAGS}


clean:
	rm -f *~ wrap
