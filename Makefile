BUILD := build/
srcs := $(wildcard src/*/*.c src/tup/mozilla-sha1/*.c src/tup/tup/*.c)
objs := $(addprefix $(BUILD),$(srcs:.c=.o))
deps := $(objs:.o=.d)

PROGS := tup wrapper config
SHLIBS := ldpreload.so make.so

all: $(PROGS) $(SHLIBS)

Q=@

tup: LDFLAGS := -lsqlite3
wrapper: LDFLAGS := -lpthread
ldpreload.so: CCFLAGS := -fpic
ldpreload.so: LDFLAGS := -ldl
libtup.a: CCFLAGS := -fpic
updater: LDFLAGS := -ldl
make.so: CCFLAGS := -fpic

tup: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/tup/tup/*.c)) libtup.a
wrapper: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/wrapper/*.c)) libtup.a
updater: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/updater/*.c)) libtup.a
make.so: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/make/*.c)) libtup.a
ldpreload.so: $(filter $(BUILD)src/ldpreload/%,$(objs)) libtup.a
create_dep: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/create_dep/*.c)) libtup.a
config: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/config/*.c)) libtup.a
tuptouch: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/tuptouch/*.c)) libtup.a

$(PROGS):
	$Qecho "  LD      $@";\
	gcc -o $@ $^ $(LDFLAGS)

$(SHLIBS): %.so:
	$Qecho "  LD.so   $@";\
	gcc $(CCFLAGS) $(LDFLAGS) -shared -o $@ $^

libtup.a: $(patsubst %.c,$(BUILD)%.o,$(wildcard src/tup/*.c) $(wildcard src/tup/mozilla-sha1/*.c))
	$Qecho "  AR      $@";\
	rm -f $@ ;\
	ar cru $@ $^

$(objs): $(BUILD)%.o: %.c Makefile
	$Qecho "  CC      $<";\
	mkdir -p $(@D);\
	gcc -MMD $(CCFLAGS) -Isrc -c $< -o $@ -W -Wall -Werror -Wbad-function-cast -Wcast-align -Wcast-qual -Wchar-subscripts -Winline -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wredundant-decls -Wshadow -Wstrict-prototypes -Wwrite-strings -fno-common

-include $(deps)
