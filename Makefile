BUILDDIR := build
SRCDIR := src
OBJDIR := $(BUILDDIR)/obj
ARCHDIR := $(SRCDIR)/arch/i686

CC := i686-elf-gcc
CFLAGS := -O2 -g -ffreestanding -Wall -Wextra -m32 -Iinclude/kernel
LDFLAGS := -T $(ARCHDIR)/linker.ld
AS := nasm
LDLIBS := -nostdlib -lgcc
BINARY := $(BUILDDIR)/canoos.kernel

KERNEL_SRC := $(wildcard $(SRCDIR)/kernel/*/*.c)
KERNEL_SRC += $(wildcard $(SRCDIR)/kernel/*.c)
KERNEL_OBJ := $(patsubst $(SRCDIR)/kernel/%.c,$(OBJDIR)/%.o,$(KERNEL_SRC))

ARCH_SRC := $(wildcard $(ARCHDIR)/*.asm)
ARCH_OBJ := $(patsubst $(ARCHDIR)/%.asm,$(OBJDIR)/%.o,$(ARCH_SRC))

canoos-all: build

build: $(ARCH_OBJ) $(KERNEL_OBJ) link

$(ARCH_OBJ): $(OBJDIR)/%.o : $(ARCHDIR)/%.asm
	mkdir -p $(dir $@)
	$(AS) -felf32 $< -o $@

$(KERNEL_OBJ): $(OBJDIR)/%.o : $(SRCDIR)/kernel/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

link:
	$(CC) $(LDFLAGS) $(ARCH_OBJ) $(KERNEL_OBJ) -o $(BINARY) $(LDLIBS)

run: build
	qemu-system-i386 -kernel build/canoos.kernel

destroy:
	rm -rf $(BUILDDIR)

clean:
	rm -rf $(OBJDIR)

.PHONY: canoos-all build link run destroy clean
