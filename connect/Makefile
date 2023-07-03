CC = cc
CFLAGS = -Os -pipe -fno-plt -fexceptions -flto=auto -g0
LDFLAGS = -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now


all: clean connect

connect:
	${CC} ${CFLAGS} ${LDFLAGS} connect.c -o connect

clean:
	rm -f connect

static:
	${CC} ${CFLAGS} -static ${LDFLAGS} connect.c -o connect.static
