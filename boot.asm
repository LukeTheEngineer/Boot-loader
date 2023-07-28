;/////////////////////////////////////////////////////////////////////////////
; Name:        boot.asm
; Purpose:     Main boot sector code
; Author:      Lukas Jackson
; Modified by:
; Created:     7/22/2023
; Copyright:   (c) [2023] Lukas Jackson
; Licence:     GNU Public License (GPL)
;/////////////////////////////////////////////////////////////////////////////

;Define the bit mode and set the starting address. [Boot->0x7c00]
[bits 16]
[org 0x7c00]


section .text
    global _start

    ; -----------------------------------------------------------------------
    ; Memory Segments:
    ; -----------------------------------------------------------------------
    ; 0x0000  |-----------------|
    ;         |                 |
    ;         |                 |
    ;         |                 |
    ;         |   Bootloader    |    ; The bootloader is loaded at address 0x0000
    ;         |                 |
    ;         |                 |
;0x7C00/CS:IP |-----------------|    ; The CS:IP register points to 0x0000:0x7C00 CS = Code Segment & IP = Instruction Pointer.
    ;         |   Code Segment  |    ; The code segment starts at 0x0000:0x7C00
    ; 0x7C00  |                 |
    ;         |                 |
    ;         |-----------------|
    ;         |     Reserved    |    ; Reserved memory region, may vary by system
    ;         |-----------------|
    ;         |   Data Segment  |    ; The data segment starts at 0x0000:0x10000
    ; 0x10000 |                 |
    ;         |                 |
    ;         |-----------------|
    ;         |  Extra Segment  |    ; The extra segment starts at 0x0000:0x20000
    ; 0x20000 |                 |
    ;         |                 |
    ;         |-----------------|
    ;         |  Stack Segment  |    ; The stack segment starts at 0x0000:0xFFFF0
    ; 0xFFFF0 |                 |
    ;         |                 |
    ;         |-----------------|
    ;         |     BIOS        |    ; BIOS and system-specific regions
    ;         |                 |
    ; 1MB+    |-----------------|
    ; -----------------------------------------------------------------------

_start:
    ;Set up the segment registers
    xor ax, ax      ;Use bitwise XOR to compare ax with itself. AX = 0x0000
    mov ds, ax      ;Set ds(Data Segment) to the value of ax(Which is 0 or 0x0000)
    mov es, ax      ;Set ex(Extra Segment) to the same as both ds and ax.

    ;Set up the stack.
    mov ax, 0x9000  ;Loads 0x9000 into ax where 0x9000 is the address for the stack
    mov ss, ax      ;Set the ss(Stack Segment) to the value of ax
    mov sp, 0xFFFF  ;Set the sp(Stack Pointer) to to 0xFFFF to initialize the stack

;Call the print_noun function
    call print_noun

    ;Activate an infinite loop to prevent crashes.
    cli             ;Disables interrupts
    hlt             ;Halts the processor


;Create the print_noun function
print_noun:
    ;Print the operating system's name on the screen

    ;To be safe, we will set up the segment registers again.
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, msg
    mov ah, 0x0E

.repeat:
    lodsb           ;Loads the byte pointed to by SI into AL and increments SI
    cmp al, 0       ;Compares al with 0 to verify if the next increment is null(empty)
    je .done        ;Jumps to .done label if it is empty
    
    int 0x10        ;Call the bios interrupt to print the character
    jmp .repeat     ;Repeat until null terminator is detected

.done:
    ret        ;Return from the function called from

msg db 'Booting into Curtains OS', 0    ;String that is null terminated.

times 510-($-$$) db 0   ;Pad the rest of the sector to reach 510 bytes
dw 0xAA55           ;PC boot signature.