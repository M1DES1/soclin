; Multiboot2 header
section .multiboot_header
header_start:
    dd 0xe85250d6                ; magic number (multiboot 2)
    dd 0                         ; architecture (i386 protected mode)
    dd header_end - header_start ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; checksum

    ; end tag
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:

; Kernel entry point
section .text
global _start
extern kernel_main

_start:
    ; Set up stack
    mov esp, stack_top

    ; Call C kernel
    call kernel_main

    ; Halt if kernel returns
.hang:
    cli
    hlt
    jmp .hang

; Stack (16KB)
section .bss
align 16
stack_bottom:
    resb 16384
stack_top:
