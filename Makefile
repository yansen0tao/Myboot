
include makefile_configure

SSRCS = start.S
SRCS = main.c
LIB_SRCS = lib1.c
LIB_SRCS += driver/mem.S

SOBJS	= $(SSRCS:%.S=%.o$(SUFFIX))
OBJS	= $(SRCS:%.c=%.o$(SUFFIX))
LIB_OBJS = $(LIB_SRCS:%.c=%.o$(SUFFIX))
SLIB_OBJS = $(LIB_SRCS:%.S=%.o$(SUFFIX))

entry:firmware

lib.a: $(LIB_OBJS) $(SLIB_OBJS)
	$(AR) -q $@ $^

firmware.elf:$(SOBJS) $(OBJS) lib.a
	$(LD) -Tfirmware.lds $(LD_FLAGS) -e __start -o $@ $^

firmware.asm:
	$(DUMP) $(DUMP_FLAGS) firmware.elf > $@
	
firmware.map:
	$(READELF) -a firmware.elf > $@

firmware:clean firmware.elf firmware.asm firmware.map
	@echo "start convert..."
	$(OBJCOPY) -O binary firmware.elf firmware.bin
	
#.c.o <==> %.o:%.c
.c.o:
	$(CC) $(CC_FLAGS) $< -o $@
#.S.o <==> %.o:%.S
.S.o:
	$(CC) $(CC_FLAGS) $< -o $@

.PHONY:
clean:
	rm -rf *.bak *.o *.elf *.bin *.asm *.a *.map


