# SiemaOS - Minimalny System Operacyjny
# Cross-compiler prefix (change if needed)
CC = gcc
ASM = nasm
LD = ld

# Flags
CFLAGS = -m32 -ffreestanding -fno-pie -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -c
ASMFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T src/linker.ld -nostdlib

# Directories
SRC_DIR = src
BUILD_DIR = build
ISO_DIR = iso

# Files
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
ISO_FILE = $(BUILD_DIR)/siemaos.iso

# Object files
OBJS = $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o

.PHONY: all clean iso

all: iso

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble boot.asm
$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Compile kernel.c
$(BUILD_DIR)/kernel.o: $(SRC_DIR)/kernel.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@

# Link kernel
$(KERNEL_BIN): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

# Build ISO
iso: $(KERNEL_BIN)
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/kernel.bin
	grub-mkrescue -o $(ISO_FILE) $(ISO_DIR)
	@echo ""
	@echo "========================================="
	@echo "  ISO zbudowane: $(ISO_FILE)"
	@echo "  Uruchom w VirtualBox!"
	@echo "========================================="

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(ISO_DIR)/boot/kernel.bin
