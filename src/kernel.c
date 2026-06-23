/*
 * Minimalny kernel - wyswietla "siema to ja" na ekranie
 * Wykorzystuje VGA text mode buffer pod adresem 0xB8000
 */

#include <stdint.h>

/* VGA text mode constants */
#define VGA_WIDTH  80
#define VGA_HEIGHT 25
#define VGA_BUFFER ((volatile uint16_t*)0xB8000)

/* Colors */
#define VGA_COLOR_BLACK     0
#define VGA_COLOR_WHITE     15
#define VGA_COLOR_LIGHT_GREEN 10
#define VGA_COLOR_LIGHT_CYAN 11

static inline uint8_t vga_entry_color(uint8_t fg, uint8_t bg) {
    return fg | (bg << 4);
}

static inline uint16_t vga_entry(unsigned char c, uint8_t color) {
    return (uint16_t)c | (uint16_t)color << 8;
}

/* Clear entire screen */
void clear_screen(uint8_t color) {
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        VGA_BUFFER[i] = vga_entry(' ', color);
    }
}

/* Print string at given row and column */
void print_at(const char* str, int row, int col, uint8_t color) {
    int offset = row * VGA_WIDTH + col;
    for (int i = 0; str[i] != '\0'; i++) {
        VGA_BUFFER[offset + i] = vga_entry(str[i], color);
    }
}

/* Kernel entry point */
void kernel_main(void) {
    uint8_t bg_color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);

    /* Clear screen */
    clear_screen(bg_color);

    /* Display main message in the center */
    uint8_t title_color = vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    uint8_t sub_color   = vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    uint8_t hint_color  = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);

    /*
     * "siema to ja" = 11 chars
     * Center on 80-col screen: col = (80 - 11) / 2 = 34
     * Center vertically: row ~12
     */
    print_at("siema to ja", 11, 34, title_color);
    print_at("Minimalny System Operacyjny v1.0", 13, 24, sub_color);
    print_at("Wcisnij Ctrl+C lub zamknij VM aby wyjsc", 20, 20, hint_color);

    /* Hang forever */
    for (;;) {
        __asm__ volatile ("hlt");
    }
}
