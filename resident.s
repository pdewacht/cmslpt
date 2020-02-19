	.386

        public _amis_header
        public _amis_id
        public _amis_handler

        public _emm386_table
        public _qemm_handler

        public _config


cmp_ah  macro
        db 0x80, 0xFC
        endm


        RESIDENT segment word use16 public 'CODE'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AMIS API IMPLEMENTATION


;;; IBM Interrupt Sharing Protocol header
iisp_header macro chain
        jmp short $+0x12
chain:  dd 0
        dw 0x424B               ;signature
        db 0                    ;flags
        jmp short _retf         ;hardware reset routine
        db 7 dup (0)            ;unused/zero
        endm


_amis_handler:
        iisp_header amis_next_handler
        cmp_ah
_amis_id: db 0xFF
        je @@amis_match
        jmp dword ptr cs:amis_next_handler
@@amis_match:
        test al, al
        je @@amis_install_check
        cmp al, 4
        je @@amis_hook_table
        xor al, al
        iret
@@amis_install_check:
        mov al, 0xFF
        mov cx, (VERSION_MAJOR * 256 + VERSION_MINOR)
        mov dx, cs
        mov di, offset _amis_header
        iret
@@amis_hook_table:
        mov dx, cs
        mov bx, amis_hook_table
        iret


amis_hook_table:
        db 0x2D
        dw _amis_handler


_retf:
        retf


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMM386 GLUE CODE


        even
_emm386_table:
        dw 0x0220, cms_first_control
        dw 0x0221, cms_first_address
        dw 0x0222, cms_second_control
        dw 0x0223, cms_second_address
        dw 0x0224, cms_constant
        dw 0x0225, cms_unused
        dw 0x0226, cms_write_latch
        dw 0x0227, cms_write_latch
        dw 0x0228, cms_unused
        dw 0x0229, cms_unused
        dw 0x022A, cms_read_latch
        dw 0x022B, cms_read_latch
        dw 0x022C, cms_unused
        dw 0x022D, cms_unused
        dw 0x022E, cms_unused
        dw 0x022F, cms_unused


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; QEMM GLUE CODE


_qemm_handler:
        iisp_header qemm_next_handler
        cmp dx, 0x220
        jl @@qemm_ignore
        cmp dx, 0x230
        jge @@qemm_ignore
        ;; CX and DX are scratch
	and edx, 0xF
        jmp word ptr cs:[4 * edx + _emm386_table + 2]
@@qemm_ignore:
        jmp dword ptr cs:qemm_next_handler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMULATION CODE


CONFIG                  STRUC
lpt_port                dw ?
bios_id                 db ?
psp                     dw ?
emm_type                db ?
emm386_virt_io_handle   dw ?
CONFIG                  ENDS


_amis_header:           db 'SERDACO '           ;8 bytes: manufacturer
                        db 'CMSLPT  '           ;8 bytes: product
                        db 0                    ;no description
;;; Configuration immediately follows AMIS header
_config                 CONFIG <>
cms_latch               db 0


cms_first_control:
ifdef DEBUG
        call debug
endif
        push ax
        mov ah, 1+8+4
        ;; fallthru

cms_lpt:
        test cl, 4
        je cms_lpt_read
        push dx
        mov dx, cs:[_config.lpt_port]
        out dx, al
        inc dx
        inc dx
        mov al, ah
        out dx, al
        sub al, 4
        out dx, al
        add al, 4
        out dx, al
        pop dx
        pop ax
        clc
        retf

cms_first_address:
ifdef DEBUG
        call debug
endif
        push ax
        mov ah, 8+4
        jmp cms_lpt

cms_second_control:
ifdef DEBUG
        call debug
endif
        push ax
        mov ah, 1+2+4
        jmp cms_lpt

cms_second_address:
ifdef DEBUG
        call debug
endif
        push ax
        mov ah, 2+4
        jmp cms_lpt

cms_lpt_read:
        pop ax
        ;; fallthru

cms_unused:
        test cl, 4
        jne unwr
        mov al, 0xFF
unwr:   clc
        retf

cms_constant:
        test cl, 4
        jne cms_unused
        mov al, 0x7F
        clc
        retf

cms_write_latch:
        test cl, 4
        je cms_unused
        mov cs:[cms_latch], al
        clc
        retf

cms_read_latch:
        test cl, 4
        jne cms_unused
        mov al, cs:[cms_latch]
        clc
        retf


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DEBUG CODE


ifdef DEBUG

debug:
        push ax
        mov ah, al
        mov al, dl
        call write1hex
        mov al, '<'
        test cl, 4
        jz debug1
        mov al, '>'
debug1: call writechar
        mov al, ah
        call write2hex
        mov al, 10
        call writechar
        pop ax
        ret

writechar:
        push dx
        mov dx, 0x3F8
        out dx, al
        pop dx
        ret

writeln:
        push ax
        mov al, 10
        call writechar
        pop ax
        ret

write4hex:
        xchg al, ah
        call write2hex
        xchg al, ah
write2hex:
        ror al, 4
        call write1hex
        ror al, 4
write1hex:
        push ax
        and al, 0x0F
        add al, '0'
        cmp al, '9'
        jle wh2
        add al, 'A' - '9' - 1
wh2:    call writechar
        pop ax
        ret

endif

        RESIDENT ends
        end
