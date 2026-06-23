/* Linker script for the kernel */
ENTRY(_start)

SECTIONS
{
    /* Load kernel at 1MB mark */
    . = 1M;

    /* Multiboot header must come first */
    .multiboot_header : ALIGN(8)
    {
        *(.multiboot_header)
    }

    /* Text section (code) */
    .text : ALIGN(4K)
    {
        *(.text)
    }

    /* Read-only data */
    .rodata : ALIGN(4K)
    {
        *(.rodata)
    }

    /* Read-write data (initialized) */
    .data : ALIGN(4K)
    {
        *(.data)
    }

    /* Read-write data (uninitialized) and stack */
    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }
}
