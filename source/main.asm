TITLE MASM Piano

; Amon Ratna Sthapit , Anna Tran

; A virtual piano that you can play with the keyboard.

; keyboard key codes : https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes

INCLUDE Irvine32.inc
INCLUDE GraphWin.inc
INCLUDELIB winmm.lib


DTFLAGS = 25h  ; Needed for drawtext

;==================== DATA =======================
.data

	AppLoadMsgTitle BYTE "Application Loaded",0
	AppLoadMsgText  BYTE "This window displays when the WM_CREATE "
					BYTE "message is received",0

	LeftPopupTitle	BYTE "Left Mouse Button Popup Window",0
	LeftPopupText	BYTE "This window was activated by a "
					BYTE "WM_LBUTTONDOWN message",0

	GreetTitle BYTE "Main Window Active",0
	GreetText  BYTE "This window is shown immediately after "
			BYTE "CreateWindow and UpdateWindow are called.",0

	CloseMsg   BYTE "WM_CLOSE message received",0
	str1   BYTE "Paint Message Received",0
	rc RECT <0,0,200,200>
	ps PAINTSTRUCT <?>
	hdc DWORD ?
	ErrorTitle  BYTE "Error",0
	WindowName  BYTE "ASM Windows App",0
	className   BYTE "ASMWin",0

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

	msg	     MSGStruct <>
	winRect   RECT <>
	hMainWnd  DWORD ?
	hInstance DWORD ?





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

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Display a greeting message.
	INVOKE MessageBox, hMainWnd, ADDR GreetText,
	  	ADDR GreetTitle, MB_OK

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
	; GET KEYBOARD INPUT HERE
	.IF eax == WM_KEYDOWN
		mov ebx, 1
		.IF wParam == 41h		;key a = c note
			push OFFSET c3
			call PlayNote
			mov c3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 57h		;key w = c# note
			push OFFSET cs3
			call PlayNote
			mov cs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 53h		;key s = d note
			push OFFSET d3
			call PlayNote
			mov d3_keystat, bl
		jmp WinProcExit
		.ENDIF
		.IF wParam == 45h		;key e = d# note
			push OFFSET ds3
			call PlayNote
			mov ds3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 44h		;key d = e note
			push OFFSET e3
			call PlayNote
			mov e3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 46h		;key f = f note
			push OFFSET f3
			call PlayNote
			mov f3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 54h		;key t = f# note
			push OFFSET fs3
			call PlayNote
			mov fs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 47h		;key g = g note
			push OFFSET g3
			call PlayNote
			mov g3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 59h		;key y = g# note
			push OFFSET gs3
			call PlayNote
			mov gs3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 48h		;key h = a note
			push OFFSET a3
			call PlayNote
			mov a3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 55h		;key u = a# note
			push OFFSET as3
			call PlayNote
			mov as3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Ah		;key j = b note
			push OFFSET b3
			call PlayNote
			mov b3_keystat, bl
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == 4Bh		;key k = c4 note
			push OFFSET c4
			call PlayNote
			mov c4_keystat, bl
	  	jmp WinProcExit
		.ENDIF
	.ENDIF

	.IF eax == WM_KEYUP
		mov ebx, 0
		.IF wParam == 41h		;key a = c note
			call writeInt
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

	.IF eax == WM_LBUTTONDOWN		; left mouse button?
	  	INVOKE MessageBox, hWnd, ADDR LeftPopupText,
	    	ADDR LeftPopupTitle, MB_OK
	  	jmp WinProcExit
	.ELSEIF eax == WM_CREATE		; create window?
	  	; INVOKE MessageBox, hWnd, ADDR AppLoadMsgText,
	    ; 	ADDR AppLoadMsgTitle, MB_OK
	  	; jmp WinProcExit
	.ELSEIF eax == WM_CLOSE		; close window?
	; 	INVOKE MessageBox, hWnd, ADDR CloseMsg,
	; 		ADDR WindowName, MB_OK
	; 	INVOKE PostQuitMessage,0
	;   jmp WinProcExit
	.ENDIF
	.IF eax == WM_PAINT		; window needs redrawing? 
		INVOKE BeginPaint, hWnd, ADDR ps 
		mov hdc, eax
	  
		; DRAW THE PIANO KEYS (rectangles) -----------------------------------------------------------------------------------------------------------
		
		; Create an RGB value in ebx  32 BITS: { BLANK, BLUE, GREEN,  RED }; each of the four values is one byte; The RGB value is needed to set the color of the brush
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
		INVOKE Rectangle, hdc, 300, 100, 400, 425 		;c
		INVOKE Rectangle, hdc, 300, 425, 400, 450
		INVOKE Rectangle, hdc, 400, 100, 500, 450 		;d
		INVOKE Rectangle, hdc, 500, 100, 600, 450 		;e
		INVOKE Rectangle, hdc, 600, 100, 700, 450 		;f
		INVOKE Rectangle, hdc, 700, 100, 800, 450 		;g
		INVOKE Rectangle, hdc, 800, 100, 900, 450 		;a
		INVOKE Rectangle, hdc, 900, 100, 1000, 450 		;b
		INVOKE Rectangle, hdc, 1000, 100, 1100, 450 	;c4

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
		
		
		; INVOKE MoveToEx, hdc, 0, 0, 0
		; INVOKE LineTo, hdc, 200, 200
		; INVOKE LineTo, hdc, 200, 0
		; INVOKE LineTo, hdc, 0,   200
		; INVOKE LineTo, hdc, 0,   0
		; INVOKE DrawTextA, hdc, ADDR str1, -1, ADDR rc, DTFLAGS 
		; INVOKE EndPaint, hWnd, ADDR ps
		jmp WinProcExit
	.ELSE		; other message?
		INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
		jmp WinProcExit
	.ENDIF

	
WinProcExit:
	ret
WinProc ENDP



PlayNote PROC fname:DWORD
	; 
	call writeInt
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