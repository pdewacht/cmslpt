	.386

        public _amis_header
        public _amis_id
        public _amis_handler

        public _emm386_table
        public _qemm_handler

        extern _config : near
        extern cmslpt_left_address_ : proc
        extern cmslpt_left_data_ : proc
        extern cmslpt_right_address_ : proc
        extern cmslpt_right_data_ : proc


cmp_ah  macro
        db 0x80, 0xFC
        endm


        _TEXT segment word use16 public 'CODE'
        assume ds:_text


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AMIS API IMPLEMENTATION


_amis_header:
        db 'SERDACO '           ;8 bytes: manufacturer
        db 'CMSLPT  '           ;8 bytes: product
        db 0                    ;no description
;;; Configuration pointer immediately follows AMIS header
        dw _config


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
;;; EMM386 DISPATCH TABLE


        even
_emm386_table:
        dw 0x0220, emm386_handler
        dw 0x0221, emm386_handler
        dw 0x0222, emm386_handler
        dw 0x0223, emm386_handler
        dw 0x0224, emm386_handler
        dw 0x0225, emm386_handler
        dw 0x0226, emm386_handler
        dw 0x0227, emm386_handler
        dw 0x0228, emm386_handler
        dw 0x0229, emm386_handler
        dw 0x022A, emm386_handler
        dw 0x022B, emm386_handler
        dw 0x022C, emm386_handler
        dw 0x022D, emm386_handler
        dw 0x022E, emm386_handler
        dw 0x022F, emm386_handler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMULATION CODE

_qemm_handler:
        iisp_header qemm_next_handler
        cmp dx, 0x220
        jl @@qemm_ignore
        cmp dx, 0x230
        jge @@qemm_ignore
        ;; CX and DX are scratch
        push ds
        push cs
        pop ds
        call dispatch
        pop ds
        retf
@@qemm_ignore:
        jmp dword ptr cs:qemm_next_handler


emm386_handler:
        push dx
        call dispatch
        pop dx
        clc
        retf


dispatch:
        and edx, 0xF
        test cl, 4
        je read
        cmp dx, 8
        jnb ignore_write
        push ax
        call word ptr [2 * edx + write_table]
        pop ax
ignore_write:
        ret
read:
        mov al, [read_table + edx]
        ret


write_table:
        dw cmslpt_left_data_     ; 2X0h
        dw cmslpt_left_address_  ; 2X1h
        dw cmslpt_right_data_    ; 2X3h
        dw cmslpt_right_address_ ; 2X3h
        dw ignore_write          ; 2X4h
        dw ignore_write          ; 2X5h
        dw write_latch           ; 2X6h
        dw write_latch           ; 2X7h


read_table:
        db 0xFF, 0xFF
        db 0xFF, 0xFF
        db 0x7F, 0xFF
        db 0xFF, 0xFF
        db 0xFF, 0xFF
latch:  db 0x00, 0x00
        db 0xFF, 0xFF
        db 0xFF, 0xFF

write_latch:
        mov [latch], al
        mov [latch+1], al
        ret


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

        _TEXT ends
        end
