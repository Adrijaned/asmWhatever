;; Returns the xy coordinates of cursor
;; IN:
;; OUT:
;; - rdx The X coordinate of the cursor
;; - rax The Y coordinate of the cursor
;; DIRTY:
;; - rdi
;; - rsi
;; - r10
;; ERR:
extern	getCursorPos

;; Parses string as unsigned doubleword int
;; IN:
;; - rax Location of the first digit of the int
;; - rdi Length of the string with the number
;; OUT:
;; - eax The parsed int
;; DIRTY:
;; - rdi 0
;; ERR:
;; - EINVAL If rdi is 0 or less
;; - E_ENOTSUP If non-digit is encountered while parsing 
extern	strToDW

;; Converts unsigned doubleword int to string
;; IN:
;; - eax The int to convert
;; - rdx Pointer to memory to store the result to.
;; Caller is responsible for ensuring the validity
;; and sufficient length of this memory.
;; OUT:
;; - rax Length of the resulting string
;; DIRTY:
;; ERR:
extern	DWToStr

;; Returns the index of char in string
;; IN:
;; - al The char to find
;; - rdx Pointer to the searched-through string
;; - rsi Length of the searched-through string
;; OUT:
;; - rax Index of the first occurence of target char in string.
;; Contains -1 if char was not found.
;; DIRTY:
;; ERR:
extern	findChar

;; Sets up console into non-canonical mode.
;; Must be called as first thing in the program.
;; Also clears screen.
;; IN:
;; OUT:
;; DIRTY:
;; - rax
;; - rdi
;; - rsi
;; - rdx
;; ERR:
;; - E_LOGERROR When called while terminal is already set up.
extern	setIoctl

;; Resets console to original settings.
;; Must be called as last thing in the program.
;; IN:
;; OUT:
;; DIRTY:
;; - rdi
;; - rsi
;; - rax
;; - rdx
;; ERR:
;; - E_LOGERROR When called without prior call to setIoctl.
extern resetIoctl

;; Returns the current size of the terminal
;; IN:
;; OUT:
;; - rax The width of the terminal
;; - rdx The height of the terminal
;; DIRTY:
;; - rdi
;; - rsi
;; - r10
;; ERR:
extern getScreenDimensions

;; Prints string to terminal position.
;; Moves cursor after the printed text.
;; IN:
;; - rax Terminal column, one indexed
;; - rdx Terminal row, one indexed
;; - rdi Pointer to the text
;; - rsi Length of the text
;; OUT:
;; DIRTY:
;; - r10
;; - r11
;; - rdi
;; - rsi
;; - rax
;; - rdx
;; - r8
;; - r9
;; ERR:
extern printToPos

;; Handles an input key. Assumes input processing has been done (ANSI
;; escapes converted to respective symbols, and TODO unicode UTF-8
;; values handled as single value.
;; IN:
;; - rax The key pressed, UTF-8
;; OUT:
;; DIRTY:
;; - rax
;; - rsi
;; - rdi
;; - rdx
;; - r8
;; - r9
;; - r10
;; - r11
;; ERR:
extern processKey

;; Resets the terminal and exits with code.
;; IN:
;; - rax The exit code
;; OUT:
;; DIRTY:
;; ERR:
extern properExit

;; Provides pre-fetched size of the screen.
;; width, height are aliases of x, y
extern screenDimensions.x, screenDimensions.y
extern screenDimensions.width, screenDimensions.height

;; Initializes the first level of the game from file.
;; IN:
;; OUT:
;; DIRTY:
;; - rax
;; - rdi
;; - rsi
;; - rdx
;; - r8
;; - r9
;; - r10
;; ERR:
;; - E_WRONGDIR if the level file was not found
extern initWorld
