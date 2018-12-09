TITLE MASM Piano

; Amon Ratna Sthapit , Anna Tran
; A virtual piano that you can play with the keyboard.

; keyboard key codes : https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
; irvine32 help : http://programming.msjc.edu/asm/help/index.html



INCLUDE Irvine32.inc
INCLUDE GraphWin.inc
INCLUDELIB winmm.lib


DTFLAGS = 25h  ; Needed for drawtext

;==================== DATA =======================
.data

	AppLoadMsgTitle BYTE "Application Loaded",0
	AppLoadMsgText  BYTE "This window displays when the WM_CREATE "
								BYTE "message is received",0

	PopupTitle BYTE "Popup Window",0
	PopupText  BYTE "This window was activated by a "
					BYTE "WM_LBUTTONDOWN message",0

	GreetTitle BYTE "Main Window Active",0
	GreetText  BYTE "This window is shown immediately after "
					BYTE "CreateWindow and UpdateWindow are called.",0

	CloseMsg   BYTE "WM_CLOSE message received",0
	leftleft BYTE "left <.<",0
	rightright BYTE "right >.>",0

	HelloStr   BYTE "Hello World",0
	rc RECT <0,0,200,200>
	ps PAINTSTRUCT <?>
	hdc DWORD ?

	ErrorTitle  BYTE "Error",0
	WindowName  BYTE "ASM Windows App",0
	className   BYTE "ASMWin",0

	msg	     MSGStruct <>
	winRect   RECT <>
	hMainWnd  DWORD ?
	hInstance DWORD ?


	; FILE PATHS FOR SOUND FILES
		;SFPATH TEXTEQU <"C:\Users\atran19\MASM-Piano\source\">
		SFPATH TEXTEQU <"Z:\CS-278-1\MASM-Piano\source\">

		c3 BYTE SFPATH,"C3ff.wav",0
		cs3 BYTE SFPATH,"Cs3ff.wav",0
		d3 BYTE SFPATH,"D3ff.wav",0
		ds3 BYTE SFPATH,"Ds3ff.wav",0
		e3 BYTE SFPATH,"E3ff.wav",0
		f3 BYTE SFPATH,"F3ff.wav",0
		fs3 BYTE SFPATH,"Fs3ff.wav",0
		g3 BYTE SFPATH,"G3ff.wav",0
		gs3 BYTE SFPATH,"Gs3ff.wav",0
		a3 BYTE SFPATH,"A3ff.wav",0
		as3 BYTE SFPATH,"As3ff.wav",0
		b3 BYTE SFPATH,"B3ff.wav",0
		c4 BYTE SFPATH,"C4ff.wav",0

	; KEY STATUS (pressed or not)
		; key pressed : 1
		; key not pressed : 0
		c3_keystat BYTE 0
		cs3_keystat BYTE 0
		d3_keystat BYTE 0
		ds3_keystat BYTE 0
		e3_keystat BYTE 0
		f3_keystat BYTE 0
		fs3_keystat BYTE 0
		g3_keystat BYTE 0
		gs3_keystat BYTE 0
		a3_keystat BYTE 0
		as3_keystat BYTE 0
		b3_keystat BYTE 0
		c4_keystat BYTE 0

	SND_FILENAME DWORD 00020000h
	SND_ASYNC DWORD 1



	; Define the Application's Window class structure.
	MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
		COLOR_WINDOW,NULL,className>



;=================== CODE =========================
.code
main PROC
; Get a handle to the current process.
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	mov MainWin.hInstance, eax

; Load the program's icon and cursor.
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov MainWin.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov MainWin.hCursor, eax

; Register the window class.
	INVOKE RegisterClass, ADDR MainWin
	.IF eax == 0
	  call ErrorHandler
	  jmp Exit_Program
	.ENDIF

; Create the application's main window.
; Returns a handle to the main window in EAX.
	INVOKE CreateWindowEx, 0, ADDR className,
	  ADDR WindowName,MAIN_WINDOW_STYLE,
	  CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
	  CW_USEDEFAULT,NULL,NULL,hInstance,NULL
	mov hMainWnd,eax

; If CreateWindowEx failed, display a message & exit.
	.IF eax == 0
	  call ErrorHandler
	  jmp  Exit_Program
	.ENDIF

; Display a greeting message.
	; INVOKE MessageBox, hMainWnd, ADDR GreetText,
	;   ADDR GreetTitle, MB_OK

; Setup a timer
	INVOKE SetTimer, hMainWnd, 0, 30, 0

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Begin the program's message-handling loop.
Message_Loop:
	; Get next message from the queue.
	INVOKE GetMessage, ADDR msg, NULL,NULL,NULL

	; Quit if no more messages.
	.IF eax == 0
	  jmp Exit_Program
	.ENDIF

	; Relay the message to the program's WinProc.
	INVOKE DispatchMessage, ADDR msg
    jmp Message_Loop

Exit_Program:
	INVOKE ExitProcess,0
main ENDP

;-----------------------------------------------------
WinProc PROC,
	hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
;-----------------------------------------------------
	LOCAL hBrush:DWORD  ; Hold a brush for drawing a filled rectangle
	mov eax, localMsg
	
	.IF eax == WM_LBUTTONDOWN		; mouse button?
		; don't do anything
	.ENDIF

	; GET KEYBOARD INPUT HERE
	.IF eax == WM_KEYDOWN
		mov ebx, 1
		.IF wParam == 41h		;key a = c note
			mov eax, ebx
			.IF c3_keystat == 0
				push OFFSET c3
				call PlayNote
			.ENDIF
			mov c3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 57h		;key w = c# note
			.IF cs3_keystat == 0
				push OFFSET cs3
				call PlayNote
			.ENDIF
			mov cs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 53h		;key s = d note
			.IF d3_keystat == 0
				push OFFSET d3
				call PlayNote
			.ENDIF
			mov d3_keystat, bl
		jmp WinProcExit
		.ENDIF
		.IF wParam == 45h		;key e = d# note
			.IF ds3_keystat == 0
				push OFFSET ds3
				call PlayNote
			.ENDIF
			mov ds3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 44h		;key d = e note
			.IF e3_keystat == 0
				push OFFSET e3
				call PlayNote
			.ENDIF
			mov e3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 46h		;key f = f note
			.IF f3_keystat == 0
				push OFFSET f3
				call PlayNote
			.ENDIF
			mov f3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 54h		;key t = f# note
			.IF fs3_keystat == 0
				push OFFSET fs3
				call PlayNote
			.ENDIF
			mov fs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 47h		;key g = g note
			.IF g3_keystat == 0
				push OFFSET g3
				call PlayNote
			.ENDIF
			mov g3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 59h		;key y = g# note
			.IF gs3_keystat == 0
				push OFFSET gs3
				call PlayNote
			.ENDIF
			mov gs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 48h		;key h = a note
			.IF a3_keystat == 0
				push OFFSET a3
				call PlayNote
			.ENDIF
			mov a3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 55h		;key u = a# note
			.IF as3_keystat == 0
				push OFFSET as3
				call PlayNote
			.ENDIF
			mov as3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Ah		;key j = b note
			.IF b3_keystat == 0
				push OFFSET b3
				call PlayNote
			.ENDIF
			mov b3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Bh		;key k = c4 note
			.IF c4_keystat == 0
				push OFFSET c4
				call PlayNote
			.ENDIF
			mov c4_keystat, bl
	  	jmp WinProcExit
		.ENDIF
	.ENDIF
	.IF eax == WM_KEYUP
		mov ebx, 0
		.IF wParam == 41h		;key a = c note
			mov c3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 57h		;key w = c# note
			mov cs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 53h		;key s = d note
			mov d3_keystat, bl
		jmp WinProcExit
		.ENDIF
		.IF wParam == 45h		;key e = d# note
			mov ds3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 44h		;key d = e note
			mov e3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 46h		;key f = f note
			mov f3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 54h		;key t = f# note
			mov fs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 47h		;key g = g note
			mov g3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 59h		;key y = g# note
			mov gs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 48h		;key h = a note
			mov a3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 55h		;key u = a# note
			mov as3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Ah		;key j = b note
			mov b3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Bh		;key k = c4 note
			mov c4_keystat, bl
	  	jmp WinProcExit
		.ENDIF
	.ENDIF

	.IF eax == WM_CLOSE		; close window?
	  	; dont do anything
	  	jmp WinProcExit
	.ELSEIF eax == WM_TIMER     ; did a timer fire?
	  	INVOKE InvalidateRect, hWnd, 0, 1
	  	jmp WinProcExit
	.ENDIF


	.IF eax == WM_PAINT		; window needs redrawing? 
		call writeInt
		INVOKE BeginPaint, hWnd, ADDR ps  
	  	mov hdc, eax

		; DRAW THE PIANO KEYS (rectangles) -------------------------------------------------------------------------------------------------------------------------
		
			; CHANGE BRUSH COLOR TO WHITE
			; Create an RGB value in ebx  32 BITS: { BLANK, BLUE, GREEN,  RED }; values are one byte; needed to set the color of the brush
			xor ebx, ebx  					; Clear out ebx								; ebx = { 0, 0, 0,  0 }
			mov bl, 255						;150   ; This will be the blue color		; ebx = { 0, 0, 0, 150 }
			shl ebx, 8    					; Make room in ebx to add the green			; ebx = { 0, 0, 150, 0 }
			mov bl, 255						;100   ; This sets the green color			; ebx = { 0, 0, 150, 100 }
			shl ebx, 8    					; Make room for the red color'				; ebx = { 0,150, 100, 0 }  
			mov bl, 255						;50    ; This sets the red color			; ebx = { 0,150, 100, 50 } 
			INVOKE CreateSolidBrush, ebx
			mov hBrush, eax  				; Mov the brush handle into hBrush
			INVOKE SelectObject, hdc, hBrush
			
			; DRAW WHITE KEYS
			INVOKE Rectangle, hdc, 300, 100, 400, 450 		;c
			.IF c3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 300, 425, 400, 450
			.ENDIF
			INVOKE Rectangle, hdc, 400, 100, 500, 450 		;d
			.IF d3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 400, 425, 500, 450
			.ENDIF
			INVOKE Rectangle, hdc, 500, 100, 600, 450 		;e
			.IF e3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 500, 425, 600, 450
			.ENDIF
			INVOKE Rectangle, hdc, 600, 100, 700, 450 		;f
			.IF f3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 600, 425, 700, 450
			.ENDIF
			INVOKE Rectangle, hdc, 700, 100, 800, 450 		;g
			.IF g3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 700, 425, 800, 450
			.ENDIF
			INVOKE Rectangle, hdc, 800, 100, 900, 450 		;a
			.IF a3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 800, 425, 900, 450
			.ENDIF
			INVOKE Rectangle, hdc, 900, 100, 1000, 450 		;b
			.IF b3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 900, 425, 1000, 450
			.ENDIF
			INVOKE Rectangle, hdc, 1000, 100, 1100, 450 	;c4
			.IF c4_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 1000, 425, 1100, 450
			.ENDIF

			; CHANGE BRUSH COLOR TO BLACK
			xor ebx, ebx  			; Clear ebx
			mov bl, 50				; blue color
			shl ebx, 8    			; Make room in ebx to add the green
			mov bl, 50				; green color
			shl ebx, 8    			; Make room for the red color'
			mov bl, 50				; red color
			INVOKE CreateSolidBrush, ebx
			mov hBrush, eax  		; Mov the brush handle into hBrush
			INVOKE SelectObject, hdc, hBrush

			; DRAW BLACK KEYS
			INVOKE Rectangle, hdc, 375, 100, 425, 300 		;c#
			INVOKE Rectangle, hdc, 475, 100, 525, 300 		;d#
			INVOKE Rectangle, hdc, 675, 100, 725, 300 		;f#
			INVOKE Rectangle, hdc, 775, 100, 825, 300 		;g#
			INVOKE Rectangle, hdc, 875, 100, 925, 300 		;a#

			; BLACK KEY HIGHLIGHTS
			xor ebx, ebx  			; Clear ebx
			mov bl, 80				; blue color
			shl ebx, 8    			; Make room in ebx to add the green
			mov bl, 80				; green color
			shl ebx, 8    			; Make room for the red color'
			mov bl, 80				; red color
			INVOKE CreateSolidBrush, ebx
			mov hBrush, eax  		; Mov the brush handle into hBrush
			INVOKE SelectObject, hdc, hBrush
			.IF cs3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 375, 290, 425, 300
			.ENDIF
			.IF ds3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 475, 290, 525, 300
			.ENDIF
			.IF fs3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 675, 290, 725, 300
			.ENDIF
			.IF gs3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 775, 290, 825, 300
			.ENDIF
			.IF as3_keystat == 0
				call writeInt
				INVOKE Rectangle, hdc, 875, 290, 925, 300
			.ENDIF

		mov eax, 50
		call Delay

	  	jmp WinProcExit
	.ELSE		; other message?
	  	INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
	  	jmp WinProcExit
	.ENDIF

WinProcExit:
	ret
WinProc ENDP



;--------------------------------------------------------------------------------
PlayNote PROC fname:DWORD
; 
	mov eax, SND_FILENAME
	or eax, SND_ASYNC
	invoke PlaySound, fname, 0, eax

	ret 
PlayNote ENDP


;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
	.data
	pErrorMsg  DWORD ?		; ptr to error message
	messageID  DWORD ?
	.code
		INVOKE GetLastError	; Returns message ID in EAX
		mov messageID,eax

		; Get the corresponding message string.
		INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
			FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
			ADDR pErrorMsg,NULL,NULL

		; Display the error message.
		INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
			MB_ICONERROR+MB_OK

		; Free the error message string.
		INVOKE LocalFree, pErrorMsg
		ret
ErrorHandler ENDP



END