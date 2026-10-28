MPIN1 BIT P1.0 	;Motor pin number 1
MPIN2 BIT P1.1 	;Motor pin number 2
RS BIT P1.2 	;LCD Register Select pin 
EN BIT P1.3 	;LCD Enable pin
lcd_port EQU P2	;LCD data pin connected to port 2
;LCD commands
LCD_INIT		EQU 38H	;LCD 2 lines mode
LCD_DISPLAY_ON 		EQU 0CH	;LCD display on and cursor off
LCD_CLEAR 		EQU 01H ;clear LCD

; ------ START ------ 0000
ORG 0
	JMP MAIN
	
; ------ Main ------ 0035
ORG 0035H	
MAIN:
	MOV TMOD, #21H 	;timer 0 -> mode 01, timer 1 -> mode 02 
	MOV TH1, #0FDH 	;set baud rate to 9600
	MOV SCON, #50H	;8 bit-uart, enable Reception
	SETB TR1	;start timer 1
	SETB EA		;enable global interrupt
	SETB ES		;enable serial interrupt
	CALL INITLCD 
	;Infinity loop ------ 0047
	LOOP:
		JMP LOOP
	
; ------ Delay for 50 ms ------ 005D
SDELAY:
	;make timer 0 start counting from 3CB0H (15536D) 
	MOV TH0, #3CH
	MOV TL0, #0B0H
	SETB TR0 	;start timer 0 
	JNB TF0, $	;wait for timer 0 finish counting
	CLR TF0
	CLR TR0		;stop timer0
	RET
		
; ------ Delay for 1 second ------ 0049
DELAY:
	;repeat delay of 50 ms for 20 times to get a delay of 1 second
	MOV R0, #20D
	DELAYLOOP:
		;make timer 0 start counting from 3CB0H (15536D)
		MOV TH0, #3CH
		MOV TL0, #0B0H
		SETB TR0 	;start timer 0 
		JNB TF0, $	;wait for timer 0 finish counting
		CLR TF0
		CLR TR0		;stop timer0
		DJNZ R0, DELAYLOOP
	RET
		
; ------ initialize LCD ------ 006D
INITLCD:
	CLR RS
	CLR EN
	MOV lcd_port, #0

	MOV lcd_port, #LCD_INIT
	CALL SENDCMD
	MOV lcd_port, #LCD_DISPLAY_ON
	CALL SENDCMD
	MOV lcd_port, #LCD_CLEAR
	CALL SENDCMD
	RET
	
; ------ send command to LCD ------ 0087
SENDCMD:
	CLR RS
	SETB EN
	CALL SDELAY	;small delay
	CLR EN
	RET
	
; ------ send data to LCD ------ 0090
SENDDATA:
	SETB RS
	SETB EN
	CALL SDELAY 	;small delay
	CLR EN
	RET
	
; ------ send door open message to LCD ------ 0099
DISPLAY_DOOROPEN:
	SETB MPIN1 
	CLR MPIN2
	
	CLR RS
	CLR EN
	MOV lcd_port, #0
	MOV lcd_port, #LCD_CLEAR
	CALL SENDCMD
	
	MOV DPTR, #DOOROPENSTR
	DISPLOOP:
		CLR A	
		MOVC A, @A+DPTR		;BT7OT ELHARF FL AX
		MOV lcd_port, A
		CALL SENDDATA
		INC DPTR
		JNZ CONTINUESTRING 	;jump if character not equal 0
		CALL DELAY 		;DELAY 1 SEC
		CLR MPIN1
		CLR MPIN2
		CALL DELAY 		;DELAY 1 SEC
		RET
	CONTINUESTRING:
		JMP DISPLOOP
		
; ------ send door closed message to LCD ------
DISPLAY_DOORCLOSED:
	CJNE A, #'C', DONOTHING
	SETB MPIN2
	CLR MPIN1 
		
	CLR RS
	CLR EN
	MOV lcd_port, #0
	MOV lcd_port, #LCD_CLEAR
	CALL SENDCMD
	
	MOV DPTR, #DOORCLOSESTR
	DISP_LOOP:
		CLR A	
		MOVC A, @A+DPTR		;BT7OT ELHARF FL AX
		MOV lcd_port, A
		CALL SENDDATA
		INC DPTR
		JNZ CONTINUE_STRING 	;jump if character not equal 0
		CALL DELAY		;DELAY 1 SEC
		CLR MPIN2
		CLR MPIN1
		CALL DELAY 		;DELAY 1 SEC
		RET
	CONTINUE_STRING:
		JMP DISP_LOOP
		
; ------ Do nothing ------
DONOTHING:
       	CLR MPIN2
       	CLR MPIN1
	RET
	
; ------ serial port receive ISR ------
ORG 0023H
	MOV A, SBUF
	CJNE A, #'O', CLOSE
	CALL DISPLAY_DOOROPEN
	SJMP EXIT_ISR
	
	CLOSE:
		CALL DISPLAY_DOORCLOSED
		JMP EXIT_ISR
	;exit ISR ------
	EXIT_ISR:
		CLR RI ;clear Receiver Interrupt Flag
		RETI
		
; ------ Door open string address ------	
ORG 300H
	DOOROPENSTR: DB "DOOR OPEN", 0
; ------ Door closed string address ------
ORG 400H
	DOORCLOSESTR: DB "DOOR CLOSE", 0

END